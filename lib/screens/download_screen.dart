// lib/screens/download_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/download_info.dart';
import '../services/api_service.dart';
import '../widgets/error_widget.dart';

class DownloadScreen extends StatefulWidget {
  final String itemId;

  const DownloadScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final ApiService _apiService = ApiService();
  DownloadInfo? _downloadInfo;
  bool _isLoading = true;
  String? _error;
  Map<String, bool> _downloadingFormats = {};

  @override
  void initState() {
    super.initState();
    _loadDownloadInfo();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadDownloadInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final downloadInfo = await _apiService.getDownloadInfo(widget.itemId);
      
      setState(() {
        _downloadInfo = downloadInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(String format) async {
    try {
      setState(() {
        _downloadingFormats[format] = true;
      });

      final directDownload = await _apiService.getDirectDownloadUrl(widget.itemId, format);
      
      final uri = Uri.parse(directDownload.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch download URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingFormats[format] = false;
        });
      }
    }
  }

  IconData _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return Icons.book;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'mp3':
      case 'audio':
        return Icons.audiotrack;
      case 'mobi':
        return Icons.tablet;
      default:
        return Icons.file_download;
    }
  }

  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return Colors.blue;
      case 'pdf':
        return Colors.red;
      case 'mp3':
      case 'audio':
        return Colors.purple;
      case 'mobi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Options'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadDownloadInfo,
                )
              : _downloadInfo == null
                  ? const Center(child: Text('No download information available'))
                  : _buildDownloadOptions(),
    );
  }

  Widget _buildDownloadOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _downloadInfo!.type == ItemType.audiobook 
                        ? Icons.headphones 
                        : Icons.book,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _downloadInfo!.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_downloadInfo!.formats.length} formats available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Available Formats
          Text(
            'Available Formats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Format List
          ...(_downloadInfo!.formats.map((format) => _buildFormatCard(format))),
          
          const SizedBox(height: 24),
          
          // Info Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Download Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Downloads will open in your default browser or download manager\n'
                    '• EPUB files work best with e-reader apps like Apple Books or Google Play Books\n'
                    '• PDF files can be opened with any PDF reader\n'
                    '• Audio files can be played with any media player',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatCard(String format) {
    final isDownloading = _downloadingFormats[format] ?? false;
    final formatColor = _getFormatColor(format);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isDownloading ? null : () => _downloadFile(format),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: formatColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFormatIcon(format),
                  color: formatColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      format.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormatDescription(format),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isDownloading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.download,
                  color: formatColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormatDescription(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return 'Best for e-readers and mobile devices';
      case 'pdf':
        return 'Universal format, preserves layout';
      case 'mp3':
      case 'audio':
        return 'Audio format for listening';
      case 'mobi':
        return 'Kindle-compatible format';
      default:
        return 'Digital download';
    }
  }
}