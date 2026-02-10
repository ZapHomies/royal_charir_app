import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

/// Document Image Service - Handle document scanning and image processing
class DocumentImageService {
  static final DocumentImageService instance = DocumentImageService._();
  DocumentImageService._();

  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();
  final Logger _logger = Logger();

  /// Get documents directory with robust creation
  Future<Directory> get _documentsDir async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final docDir = Directory(p.join(appDir.path, 'RoyalCharir', 'documents'));

      if (!await docDir.exists()) {
        await docDir.create(recursive: true);
        _logger.i('Documents directory created: ${docDir.path}');
      }

      return docDir;
    } catch (e) {
      _logger.e('Error creating documents directory: $e');
      // Fallback to temp directory
      final tempDir = Directory.systemTemp;
      final fallbackDir =
          Directory(p.join(tempDir.path, 'RoyalCharir', 'documents'));
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      _logger.w('Using fallback directory: ${fallbackDir.path}');
      return fallbackDir;
    }
  }

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      _logger.e('Error picking from camera: $e');
    }
    return null;
  }

  /// Pick image from gallery/file system
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      _logger.e('Error picking from gallery: $e');
    }
    return null;
  }

  /// Pick file using file picker (for Windows)
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      _logger.e('Error picking file: $e');
    }
    return null;
  }

  /// Process and save document image with auto-enhancement
  Future<String?> processAndSaveDocument(
    File sourceFile,
    String orderId,
    DocumentType type,
  ) async {
    try {
      // Generate unique filename and path
      final docDir = await _documentsDir;
      final filename =
          '${orderId}_${type.name}_${_uuid.v4().substring(0, 8)}.jpg';
      final savePath = p.join(docDir.path, filename);

      // Try to process image with enhancement
      try {
        final bytes = await sourceFile.readAsBytes();
        img.Image? image = img.decodeImage(bytes);

        if (image != null) {
          // Apply document enhancement (simulated document scanning)
          image = _enhanceDocument(image);

          // Encode and save
          final jpgBytes = img.encodeJpg(image, quality: 90);
          final savedFile = File(savePath);
          await savedFile.writeAsBytes(jpgBytes);

          _logger.i('Document saved with enhancement: $savePath');
          return savePath;
        }
      } catch (e) {
        _logger.w('Image processing failed, using direct copy: $e');
      }

      // Fallback: Just copy the file directly without processing
      await sourceFile.copy(savePath);
      _logger.i('Document saved (direct copy): $savePath');
      return savePath;
    } catch (e) {
      _logger.e('Error saving document: $e');
      return null;
    }
  }

  /// Enhance document image (document scanning effect)
  img.Image _enhanceDocument(img.Image source) {
    // 1. Auto-crop and straighten simulation
    // For a real implementation, you would use perspective transform

    // 2. Increase contrast for better readability
    source = img.adjustColor(
      source,
      contrast: 1.2,
      brightness: 1.05,
    );

    // 3. Sharpen for text clarity
    source = img.convolution(source, filter: [
      0,
      -1,
      0,
      -1,
      5,
      -1,
      0,
      -1,
      0,
    ]);

    // 4. Slight saturation reduction (more document-like)
    source = img.adjustColor(source, saturation: 0.9);

    return source;
  }

  /// Delete document file
  Future<bool> deleteDocument(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('Document deleted: $path');
        return true;
      }
    } catch (e) {
      _logger.e('Error deleting document: $e');
    }
    return false;
  }

  /// Get document file if exists
  Future<File?> getDocument(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Get all documents for an order
  Future<List<OrderDocument>> getOrderDocuments(String orderId) async {
    final docDir = await _documentsDir;
    final List<OrderDocument> documents = [];

    try {
      await for (var entity in docDir.list()) {
        if (entity is File) {
          final filename = p.basename(entity.path);
          if (filename.startsWith(orderId)) {
            // Parse document type from filename
            DocumentType? type;
            if (filename.contains('_delivery_note_')) {
              type = DocumentType.deliveryNote;
            } else if (filename.contains('_invoice_')) {
              type = DocumentType.invoice;
            } else if (filename.contains('_payment_proof_')) {
              type = DocumentType.paymentProof;
            }

            if (type != null) {
              documents.add(OrderDocument(
                path: entity.path,
                type: type,
                createdAt: await entity.lastModified(),
              ));
            }
          }
        }
      }
    } catch (e) {
      _logger.e('Error getting order documents: $e');
    }

    return documents;
  }
}

/// Document types
enum DocumentType {
  deliveryNote, // Surat Jalan
  invoice, // Nota/Faktur
  paymentProof, // Bukti Pembayaran
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.deliveryNote:
        return 'Surat Jalan';
      case DocumentType.invoice:
        return 'Nota/Faktur';
      case DocumentType.paymentProof:
        return 'Bukti Pembayaran';
    }
  }

  String get name {
    switch (this) {
      case DocumentType.deliveryNote:
        return 'delivery_note';
      case DocumentType.invoice:
        return 'invoice';
      case DocumentType.paymentProof:
        return 'payment_proof';
    }
  }
}

/// Order Document model
class OrderDocument {
  final String path;
  final DocumentType type;
  final DateTime createdAt;

  OrderDocument({
    required this.path,
    required this.type,
    required this.createdAt,
  });
}
