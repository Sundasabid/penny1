import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  bool _busy = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _scan() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final XFile? x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (x == null) return;

      final File file = File(x.path);

      // OCR
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFile(file);
      final result = await recognizer.processImage(input);
      await recognizer.close();

      // Parse what you need (merchant, amount, category)
      final parsed = _parseReceipt(result.text);

      if (!mounted) return;

      Navigator.of(context).pop({
        'imagePath': file.path,
        'merchantName': parsed.merchantName,
        'amount': parsed.amount,
        'category': parsed.category,
        'dateTime': DateTime.now(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _busy ? null : _scan,
          icon: const Icon(Icons.document_scanner),
          label: Text(_busy ? 'Scanning...' : 'Open Scanner'),
        ),
      ),
    );
  }
}

class _Parsed {
  final String merchantName;
  final double amount;
  final String category;

  const _Parsed({
    required this.merchantName,
    required this.amount,
    required this.category,
  });
}

_Parsed _parseReceipt(String text) {
  final lines = text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  String merchant = 'Unknown Merchant';
  if (lines.isNotEmpty) {
    merchant = lines.take(8).firstWhere(
          (l) {
        final low = l.toLowerCase();
        if (low.contains('total') || low.contains('thank') || low.contains('invoice')) return false;
        if (RegExp(r'^\d').hasMatch(l)) return false;
        return l.length >= 3;
      },
      orElse: () => lines.first,
    );
  }

  double total = 0;

  final totalMatch = RegExp(
    r'(total|grand\s*total|amount)\s*[:\-]?\s*([0-9][0-9,]*\.?[0-9]{0,2})',
    caseSensitive: false,
  ).firstMatch(text);

  if (totalMatch != null) {
    total = _toMoney(totalMatch.group(2) ?? '0');
  } else {
    final matches = RegExp(r'([0-9][0-9,]*\.?[0-9]{0,2})').allMatches(text);
    double maxV = 0;
    for (final m in matches) {
      final v = _toMoney(m.group(1) ?? '0');
      if (v > maxV) maxV = v;
    }
    total = maxV;
  }

  final category = _guessCategory(merchant, text);

  return _Parsed(merchantName: merchant, amount: total, category: category);
}

double _toMoney(String raw) {
  final cleaned = raw.replaceAll(',', '');
  return double.tryParse(cleaned) ?? 0;
}

String _guessCategory(String merchant, String text) {
  final s = ('$merchant $text').toLowerCase();

  bool has(List<String> k) => k.any(s.contains);

  if (has(['imtiaz', 'market', 'mart', 'grocery', 'super'])) return 'Grocery';
  if (has(['shell', 'petrol', 'fuel', 'gas', 'station'])) return 'Transport';
  if (has(['gloria', 'jeans', 'coffee', 'cafe', 'restaurant'])) return 'Dining';
  if (has(['outfit', 'clothes', 'apparel', 'store'])) return 'Shopping';
  if (has(['pharmacy', 'medical', 'drug'])) return 'Health';
  if (has(['daraz', 'online', 'order', 'delivery'])) return 'Online';
  return 'Other';
}
