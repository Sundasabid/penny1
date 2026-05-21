import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class SmsParsingException implements Exception {
  final String message;
  final Object? cause;
  SmsParsingException(this.message, [this.cause]);
  @override
  String toString() => 'SmsParsingException: $message${cause != null ? ' ($cause)' : ''}';
}

class SmsParsingService {
  final String apiKey;

  SmsParsingService({required this.apiKey});

  /// Extracts transaction data from a raw SMS string.
  /// Uses Gemini to handle diverse bank formats in Pakistan.
  ///
  /// Returns:
  ///   - `Map<String, dynamic>` with parsed transaction fields when the SMS is a transaction
  ///   - `null` when the AI determines this SMS is not a transaction (OTP, marketing, etc.)
  ///
  /// Throws [SmsParsingException] on transient or recoverable errors (network failure,
  /// empty AI response, malformed JSON). Callers should treat these as retryable.
  Future<Map<String, dynamic>?> parseFinancialSms(String smsBody, List<String> availableCategories) async {
    final categoriesString = availableCategories.join(', ');

    final prompt = '''
      Analyze this SMS for "Penny", a personal finance app in Pakistan.
      This SMS is likely a transaction alert from a bank or mobile wallet.

      --- SMS BODY ---
      "$smsBody"
      ----------------

      --- INSTRUCTIONS ---
      1. Identify if this is a financial transaction (Debit, Credit, Purchase, Transfer).
      2. If it is NOT a transaction (e.g., OTP, marketing, login alert), return {"isTransaction": false}.
      3. If it IS a transaction:
         - "merchantName": The store, person, or bank involved.
         - "amount": The transaction amount (numeric).
         - "isIncome": true if money was received/credited, false if spent/debited.
         - "category": Select one from: [$categoriesString].
         - "date": The date of transaction (if mentioned, else use today's date in YYYY-MM-DD).

      Return ONLY a raw JSON object:
      {
        "isTransaction": true,
        "merchantName": "Name",
        "amount": 0.0,
        "isIncome": false,
        "category": "Selected Category",
        "date": "YYYY-MM-DD"
      }
    ''';

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    
    debugPrint("🤖 SmsParsingService: Sending message to Gemini...");
    final String responseText;
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw SmsParsingException('Gemini returned an empty response');
      }
      responseText = text;
    } catch (e) {
      if (e is SmsParsingException) rethrow;
      debugPrint("❌ SmsParsingService: Gemini call failed: $e");
      throw SmsParsingException('Gemini call failed', e);
    }

    debugPrint("🤖 SmsParsingService: Received response: $responseText");

    final Map<String, dynamic> data;
    try {
      final cleanedResponse = _cleanJson(responseText);
      data = jsonDecode(cleanedResponse) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("❌ SmsParsingService: JSON parse failed for response: $responseText");
      throw SmsParsingException('Malformed JSON from AI', e);
    }

    if (data['isTransaction'] == true) {
      return data;
    }
    debugPrint("ℹ️ SmsParsingService: SMS was determined NOT to be a transaction.");
    return null;
  }

  String _cleanJson(String text) {
    var cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return cleaned.substring(start, end + 1);
    }
    return cleaned;
  }
}
