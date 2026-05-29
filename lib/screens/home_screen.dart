import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/crop_result.dart';
import '../services/ai_service.dart';
import '../services/language_provider.dart';
import '../services/translations.dart';
import 'api_key_screen.dart';
import 'history_screen.dart';
import 'offline_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _imageBytes;
  bool _loading = false;
  bool _imageBlurry = false;
  bool _networkError = false;
  String? _error;
  final _aiService = AIService();

  String get _lang => appLang.value;
  String _t(String key) => AppTranslations.get(_lang, key);

  void _showLanguagePicker() {
    final langs = AppTranslations.supportedLanguages;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D3525),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language / भाषा चुनें',
              style: TextStyle(
                color: Color(0xFFB7E4C7),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: langs.map((code) {
                final selected = _lang == code;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    setLanguage(code); // updates notifier → rebuilds whole app
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF40916C)
                          : const Color(0xFF2D6A4F).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF74C69D)
                            : const Color(0xFF2D6A4F),
                      ),
                    ),
                    child: Text(
                      AppTranslations.get(code, 'langName'),
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF74C69D),
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final blurry = await compute(AIService.isImageTooBlurry, bytes);
        setState(() {
          _imageBytes = bytes;
          _imageBlurry = blurry;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Could not access ${source.name}: $e');
    }
  }

  Future<void> _analyzeCrop() async {
    if (_imageBytes == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      CropAnalysisResult result;
      bool isDemo = false;

      // Use demo data if API key not configured
      if (AIService.isApiKeyMissing()) {
        await Future.delayed(const Duration(seconds: 1));
        result = _aiService.getDemoResult(_lang);
        isDemo = true;
      } else {
        result = await _aiService.analyzeCropBytes(_imageBytes!, _lang);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: result,
              imageBytes: _imageBytes!,
              lang: _lang,
              isDemo: isDemo,
            ),
          ),
        );
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('quota') || msg.contains('RESOURCE_EXHAUSTED') || msg.contains('rate')) {
        final result = _aiService.getDemoResult(_lang);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                result: result,
                imageBytes: _imageBytes!,
                lang: _lang,
                isDemo: true,
                demoReason: 'API rate limit reached. Showing demo — wait a minute and try again.',
              ),
            ),
          );
        }
      } else if (e is TimeoutException ||
          msg.contains('SocketException') ||
          msg.contains('ClientException') ||
          msg.contains('Network is unreachable') ||
          msg.contains('Connection refused')) {
        if (mounted) setState(() => _networkError = true);
      } else {
        if (mounted) setState(() => _error = 'Analysis failed: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageBlurry = false;
      _networkError = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      children: [
                        _buildUploadZone(),
                        const SizedBox(height: 20),
                        if (_imageBlurry) _buildBlurWarning(),
                        if (_networkError) _buildNetworkError(),
                        if (_error != null) _buildErrorBanner(),
                        _buildAnalyzeButton(),
                        const SizedBox(height: 28),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF40916C), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('title'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB7E4C7),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _t('subtitle'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF74C69D),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFFB7E4C7)),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryScreen(lang: _lang),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.key, color: Color(0xFFB7E4C7)),
            tooltip: 'API Key',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ApiKeyScreen(isEditing: true),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showLanguagePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF74C69D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF52B788)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Color(0xFFB7E4C7), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    AppTranslations.get(_lang, 'langName'),
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB7E4C7)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3525).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D6A4F), width: 2),
      ),
      child: _imageBytes != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _imageBytes!,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _clearImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const Text('📸', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Text(
                  _t('upload'),
                  style: const TextStyle(
                    color: Color(0xFF74C69D),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Camera button - hidden on Web (not supported well)
                    if (!kIsWeb) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: Text(_t('camera')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            foregroundColor: const Color(0xFFD8F3DC),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: Text(_t('gallery')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          foregroundColor: const Color(0xFFD8F3DC),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _t('supported'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF40916C),
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBlurWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _t('blurWarning'),
              style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF87171).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF87171)),
      ),
      child: Text(
        _error!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
      ),
    );
  }

  Widget _buildNetworkError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF78350F).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('📡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t('noConnection'),
                  style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.menu_book, size: 16),
              label: Text(_t('browseOffline')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF92400E),
                foregroundColor: const Color(0xFFFDE68A),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfflineScreen(
                    imageBytes: _imageBytes!,
                    lang: _lang,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final enabled = _imageBytes != null && !_loading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _analyzeCrop : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? const Color(0xFF40916C)
              : const Color(0xFF52B788).withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: enabled ? 8 : 0,
          shadowColor: const Color(0xFF40916C).withValues(alpha: 0.3),
        ),
        child: _loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF52B788)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _t('analyzing'),
                    style: const TextStyle(
                      color: Color(0xFF52B788),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Text(
                '${_t('analyze')} 🔬',
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFFD8F3DC)
                      : const Color(0xFF52B788),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1B4332))),
      ),
      child: Text(
        _t('footer'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: Color(0xFF2D6A4F)),
      ),
    );
  }
}
