// lib/screens/download_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../models/download_info.dart';
import '../models/item_model.dart';
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
  final Map<String, bool> _downloadingFormats = {};

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

      final directDownload =
          await _apiService.getDirectDownloadUrl(widget.itemId, format);

      final uri = Uri.parse(directDownload.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          _showMessage('Opened ${directDownload.filename}');
        }
      } else {
        throw Exception('Could not launch download URL');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Download failed. Please try again.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingFormats[format] = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
              color: isError ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return Icons.menu_book_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'mp3':
      case 'm4b':
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'mobi':
        return Icons.tablet_mac_rounded;
      default:
        return Icons.file_download_outlined;
    }
  }

  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return const Color(0xFF2563EB);
      case 'pdf':
        return const Color(0xFFDC2626);
      case 'mp3':
      case 'm4b':
      case 'audio':
        return const Color(0xFF7C3AED);
      case 'mobi':
        return const Color(0xFFD97706);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getFormatDescription(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return 'Reflows beautifully on phones and e-readers';
      case 'pdf':
        return 'Fixed layout — best on larger screens';
      case 'mp3':
        return 'Audio files for any player';
      case 'm4b':
        return 'Chaptered audiobook, great for mobile';
      case 'mobi':
        return 'Kindle-friendly format';
      default:
        return 'Digital download';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Download options'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : _error != null
              ? CustomErrorWidget(message: _error!, onRetry: _loadDownloadInfo)
              : _downloadInfo == null
                  ? const Center(child: Text('No download information available'))
                  : _buildDownloadOptions(),
    );
  }

  Widget _buildDownloadOptions() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(info: _downloadInfo!),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text('Choose a format', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text(
                    '${_downloadInfo!.formats.length} available',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ..._downloadInfo!.formats.map(
                (format) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildFormatCard(format),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.tertiary.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: scheme.onTertiaryContainer,
                      size: 19,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Downloads open in your browser',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EPUB is the best pick for reading on a phone. '
                            'Every title here is public domain, so you can keep '
                            'it and share it freely.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.55,
                              color: scheme.onTertiaryContainer
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatCard(String format) {
    final isDownloading = _downloadingFormats[format] ?? false;
    final formatColor = _getFormatColor(format);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isDownloading ? null : () => _downloadFile(format),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: formatColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _getFormatIcon(format),
                  color: formatColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      format.toUpperCase(),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormatDescription(format),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isDownloading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 18,
                    color: scheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final DownloadInfo info;

  const _HeaderCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAudio = info.type == ItemType.audiobook;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              isAudio ? Icons.headphones_rounded : Icons.menu_book_rounded,
              color: const Color(0xFFFCD34D),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAudio ? 'AUDIOBOOK' : 'E-BOOK',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Fraunces',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Free download · Public domain',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
