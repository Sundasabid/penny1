import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiReceiptProcessor {
  final String apiKey;

  GeminiReceiptProcessor({required this.apiKey});

  Future<Map<String, dynamic>> extractReceiptData(String imagePath, List<String> availableCategories) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();

    final categoriesString = availableCategories.join(', ');

    final prompt = '''
      Analyze this receipt image for "Penny", a financial app in Pakistan.
      Printed or Handwritten - extract accurately even if blurred.
      Focus on PKR (Rs) currency symbols and localized merchants.

      --- INSTRUCTIONS ---
      1. Carefully identify the Merchant Name (the store or person paid). 
      2. Find the Total Amount paid. Usually the largest number after "Total", "Rs", or "PKR".
      3. Identify the Date. Formats like DD/MM/YY or DD-MM-YYYY are common. 
      4. Select the most appropriate category from the following list ONLY: [$categoriesString].

      Return ONLY a raw JSON object:
      {
        "merchantName": "Name",
        "totalAmount": 0.0,
        "category": "Selected Category",
        "date": "YYYY-MM-DD"
      }

      No markdown markers. If missing, use "Unknown", 0.0, or today's date.
    ''';

    // 2026 Resilient Model Strategy - Aligned with Penny Chat for high reliability
    final modelsToTry = [
      'gemini-1.5-flash',        // Legacy stable (most reliable for vision endpoints)
      'gemini-2.0-flash',        // Latest 2026 stable
      'gemini-flash-latest',     // Alias
      'gemini-pro-vision',       // Legacy vision path
    ];

    Object? lastError;

    for (var modelName in modelsToTry) {
      try {
        debugPrint("🔍 Penny Scanner: Trying model $modelName...");
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        
        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ]),
        ];

        final response = await model.generateContent(content);
        final responseText = response.text;

        if (responseText == null || responseText.isEmpty) continue;

        try {
          final cleanedResponse = _cleanJson(responseText);
          return jsonDecode(cleanedResponse);
        } catch (jsonErr) {
          debugPrint("⚠️ Penny Scanner: JSON parse failed for $modelName: $jsonErr. Raw: $responseText");
          continue; // Try next model if JSON is mangled
        }

      } catch (e) {
        lastError = e;
        debugPrint("⚠️ Penny Scanner: Model $modelName failed: $e");
        
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains("429") || errorStr.contains("503") || errorStr.contains("quota")) {
          // Wait briefly before trying a different model
          await Future.delayed(const Duration(milliseconds: 500));
        }
        continue;
      }
    }

    // If all models fail
    String userFriendlyMessage = "Receipt extraction is temporarily unavailable due to high AI demand.";
    final errorStr = lastError.toString().toLowerCase();

    if (errorStr.contains("429") || errorStr.contains("quota")) {
      userFriendlyMessage = "API Quota exceeded. Please try again in a few minutes.";
    } else if (errorStr.contains("503") || errorStr.contains("overloaded")) {
      userFriendlyMessage = "Google AI servers are currently overloaded. Retrying shortly...";
    }

    throw Exception("$userFriendlyMessage (Details: $lastError)");
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
