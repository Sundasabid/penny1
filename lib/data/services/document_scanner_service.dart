import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerService {
  Future<String?> scanReceipt() async {
    // Configure scanner options
    final options = DocumentScannerOptions(
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.full,
      pageLimit: 1,
      isGalleryImport: false,
    );

    // IMPORTANT: DocumentScanner must be created with options
    final scanner = DocumentScanner(options: options);

    try {
      final result = await scanner.scanDocument();

      // result.images is a List<String> of local file paths
      if (result.images.isEmpty) return null;

      return result.images.first;
    } finally {
      // Always release resources
      await scanner.close();
    }
  }
}
