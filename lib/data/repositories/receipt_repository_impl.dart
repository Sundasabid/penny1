import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../services/gemini_receipt_processor.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final GeminiReceiptProcessor aiProcessor;
  
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  ReceiptRepositoryImpl({required this.aiProcessor});

  String get _userId => _auth.currentUser?.uid ?? "anonymous";

  @override
  Future<void> saveReceipt(ReceiptEntity receipt) async {
    if (_userId == "anonymous") return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('receipts')
        .doc(receipt.id)
        .set({
          'id': receipt.id,
          'imagePath': receipt.imagePath,
          'merchantName': receipt.merchantName,
          'amount': receipt.amount,
          'category': receipt.category,
          'dateTime': Timestamp.fromDate(receipt.dateTime),
        });
  }

  @override
  Future<List<ReceiptEntity>> getReceipts() async {
    if (_userId == "anonymous") return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('receipts')
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ReceiptEntity(
        id: data['id'] ?? doc.id,
        imagePath: data['imagePath'] ?? '',
        merchantName: data['merchantName'] ?? 'Unknown',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        category: data['category'] ?? 'others',
        dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> deleteReceipt(String id) async {
    if (_userId == "anonymous") return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('receipts')
        .doc(id)
        .delete();
  }

  @override
  Future<Map<String, dynamic>> extractDetailsWithAI(String imagePath, List<String> availableCategories) async {
    try {
      debugPrint("🤖 Penny Scanner: Attempting AI extraction...");
      return await aiProcessor.extractReceiptData(imagePath, availableCategories);
    } catch (e) {
      debugPrint("⚠️ Penny Scanner: AI extraction failed ($e). Falling back to on-device Scanner API...");
      
      // Fallback Strategy: Best Effort using ML Kit locally
      try {
        final rawText = await extractTextFromReceipt(imagePath);
        if (rawText.isEmpty) rethrow;

        // --- Smart On-Device Parsing ---
        final lines = rawText.split('\n');
        
        // 1. Merchant Detection: Look for common business indicators in the first 5 lines
        String merchant = "Unknown Merchant";
        final merchantSuffixes = ['LTD', 'INC', 'MART', 'STORE', 'SHOP', 'BAKERY', 'PHARMACY', 'SUPERVISOR', 'TEL', 'MALL'];
        for (int i = 0; i < lines.length && i < 5; i++) {
          final line = lines[i].trim().toUpperCase();
          if (line.length > 3) {
            bool hasSuffix = merchantSuffixes.any((s) => line.contains(s));
            if (hasSuffix || i == 0) {
              merchant = lines[i].trim();
              if (hasSuffix) break; 
            }
          }
        }
        
        // 2. Amount Detection: Use prioritized regex
        // We look for numbers near keywords like 'TOTAL', 'NET', 'PKR', 'RS'
        double maxAmount = 0.0;
        final totalKeywords = ['TOTAL', 'NET', 'PAYABLE', 'AMOUNT', 'RS', 'PKR', 'SUBTOTAL'];
        
        for (var line in lines) {
          final upLine = line.toUpperCase();
          if (totalKeywords.any((k) => upLine.contains(k))) {
            // Found a line with a keyword - extract numbers from IT specifically
            final numRegex = RegExp(r"(\d+[\.,]\d{2})|(\d{3,})"); 
            final matches = numRegex.allMatches(line);
            for (final m in matches) {
              final amtStr = (m.group(1) ?? m.group(2) ?? "0")
                  .replaceAll(',', ''); // Handle PKR thousands
              final amt = double.tryParse(amtStr) ?? 0.0;
              if (amt > maxAmount) maxAmount = amt;
            }
          }
        }
        
        // Final fallback: just find the largest number anywhere
        if (maxAmount == 0.0) {
          final generalNumRegex = RegExp(r"(\d+[\.,]\d{2})");
          final matches = generalNumRegex.allMatches(rawText);
          for (final m in matches) {
             final amtStr = m.group(1)?.replaceAll(',', '') ?? "0";
             final amt = double.tryParse(amtStr) ?? 0.0;
             if (amt > maxAmount) maxAmount = amt;
          }
        }

        return {
          "merchantName": merchant,
          "totalAmount": maxAmount,
          "category": "others",
          "date": DateTime.now().toIso8601String().split('T')[0],
          "isFallback": true,
        };
      } catch (fallbackError) {
        throw Exception("Both AI and Scanner API failed. (Details: $e)");
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Google ML Kit Implementation (Scanner API)
  // ---------------------------------------------------------------------------

  @override
  Future<String> pickReceiptImage() async {
    try {
      final scanner = DocumentScanner(
        options: DocumentScannerOptions(
          mode: ScannerMode.full,
          isGalleryImport: true,
          pageLimit: 1,
        ),
      );

      final result = await scanner.scanDocument();

      if (result.images.isNotEmpty) {
        return result.images.first;
      } else {
        // User canceled or no image captured
        return ""; 
      }
    } catch (e) {
      throw Exception("Scanner Error: $e");
    }
  }

  @override
  Future<String> extractTextFromReceipt(String imageRef) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imageRef);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      return recognizedText.text;
    } catch (e) {
      throw Exception("Failed to extract text: $e");
    } finally {
      await textRecognizer.close();
    }
  }
}
