import 'dart:io';
import 'package:flutter/material.dart';
import '../services/document_image_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Document Upload Widget - Pick and display document images
class DocumentUploadWidget extends StatefulWidget {
  final String orderId;
  final DocumentType documentType;
  final String? existingPath;
  final Function(String? path) onDocumentChanged;
  final bool readOnly;

  const DocumentUploadWidget({
    super.key,
    required this.orderId,
    required this.documentType,
    this.existingPath,
    required this.onDocumentChanged,
    this.readOnly = false,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final _docService = DocumentImageService.instance;
  String? _currentPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.existingPath;
    _loadExistingDocument();
  }

  Future<void> _loadExistingDocument() async {
    // Load existing document for this order and type
    final docs = await _docService.getOrderDocuments(widget.orderId);
    final matchingDoc =
        docs.where((d) => d.type == widget.documentType).toList();

    if (mounted) {
      setState(() {
        if (matchingDoc.isNotEmpty) {
          _currentPath = matchingDoc.first.path;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: _getColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.documentType.displayName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_currentPath != null && !widget.readOnly)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _deleteDocument,
                  ),
              ],
            ),
          ),

          // Content
          if (_isLoading)
            Container(
              height: 150,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          else if (_currentPath != null)
            _buildDocumentPreview(isDark)
          else
            _buildUploadPlaceholder(isDark),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(bool isDark) {
    return Stack(
      children: [
        // Tappable image to view fullscreen
        GestureDetector(
          onTap: _viewDocumentFullscreen,
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Image.file(
              File(_currentPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image,
                        size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Gambar tidak ditemukan',
                      style:
                          AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // View button
        Positioned(
          bottom: 8,
          left: 8,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _viewDocumentFullscreen,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Lihat',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Saved badge
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Tersimpan',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        if (!widget.readOnly)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _showUploadOptions,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(bool isDark) {
    if (widget.readOnly) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Belum ada dokumen',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: _showUploadOptions,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_rounded,
                color: _getColor(),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap untuk upload',
              style: AppTextStyles.labelMedium.copyWith(
                color: _getColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Kamera atau File',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.documentType) {
      case DocumentType.deliveryNote:
        return Icons.local_shipping_rounded;
      case DocumentType.invoice:
        return Icons.receipt_long_rounded;
      case DocumentType.paymentProof:
        return Icons.payment_rounded;
    }
  }

  Color _getColor() {
    switch (widget.documentType) {
      case DocumentType.deliveryNote:
        return AppColors.info;
      case DocumentType.invoice:
        return AppColors.warning;
      case DocumentType.paymentProof:
        return AppColors.success;
    }
  }

  void _showUploadOptions() {
    // Check if running on Windows (desktop) - no camera available
    final isWindows = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;

    if (isWindows) {
      // On Windows, directly open file picker
      _pickFromFile();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload ${widget.documentType.displayName}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dokumen akan dioptimasi secara otomatis',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      'Kamera',
                      Icons.camera_alt_rounded,
                      AppColors.primary,
                      () {
                        Navigator.pop(context);
                        _pickFromCamera();
                      },
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOptionButton(
                      'File/Galeri',
                      Icons.folder_rounded,
                      AppColors.accent,
                      () {
                        Navigator.pop(context);
                        _pickFromFile();
                      },
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Material(
      color: color.withOpacity(isDark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isLoading = true);

    try {
      final file = await _docService.pickFromCamera();
      if (file != null) {
        await _processAndSave(file);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromFile() async {
    setState(() => _isLoading = true);

    try {
      final file = await _docService.pickFile();
      if (file != null) {
        await _processAndSave(file);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processAndSave(File sourceFile) async {
    final savedPath = await _docService.processAndSaveDocument(
      sourceFile,
      widget.orderId,
      widget.documentType,
    );

    if (savedPath != null) {
      // Delete old document if exists
      if (_currentPath != null) {
        await _docService.deleteDocument(_currentPath!);
      }

      setState(() => _currentPath = savedPath);
      widget.onDocumentChanged(savedPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${widget.documentType.displayName} berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menyimpan dokumen'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteDocument() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokumen'),
        content: Text('Hapus ${widget.documentType.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && _currentPath != null) {
      await _docService.deleteDocument(_currentPath!);
      setState(() => _currentPath = null);
      widget.onDocumentChanged(null);
    }
  }

  void _viewDocumentFullscreen() {
    if (_currentPath == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(widget.documentType.displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(_currentPath!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Gambar tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Document Gallery Widget - Display all documents for an order
class OrderDocumentGallery extends StatefulWidget {
  final String orderId;
  final bool readOnly;

  const OrderDocumentGallery({
    super.key,
    required this.orderId,
    this.readOnly = false,
  });

  @override
  State<OrderDocumentGallery> createState() => _OrderDocumentGalleryState();
}

class _OrderDocumentGalleryState extends State<OrderDocumentGallery> {
  final _docService = DocumentImageService.instance;
  List<OrderDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await _docService.getOrderDocuments(widget.orderId);
    setState(() {
      _documents = docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.folder_open_rounded,
                  size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Belum ada dokumen',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return _buildDocumentCard(doc, isDark);
      },
    );
  }

  Widget _buildDocumentCard(OrderDocument doc, bool isDark) {
    return GestureDetector(
      onTap: () => _viewDocument(doc),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(doc.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 32, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.type.displayName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDocument(OrderDocument doc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(doc.type.displayName),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.file(File(doc.path)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
