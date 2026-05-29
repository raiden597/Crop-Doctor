import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/crop_result.dart';
import '../services/history_service.dart';
import '../services/translations.dart';
import '../widgets/info_card.dart';

class ResultScreen extends StatefulWidget {
  final CropAnalysisResult result;
  final Uint8List imageBytes;
  final String lang;
  final bool isDemo;
  final bool skipSave;
  final String? demoReason;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageBytes,
    required this.lang,
    this.isDemo = false,
    this.skipSave = false,
    this.demoReason,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  CropAnalysisResult get result => widget.result;
  Uint8List get imageBytes => widget.imageBytes;
  String get lang => widget.lang;
  bool get isDemo => widget.isDemo;
  bool get skipSave => widget.skipSave;
  String? get demoReason => widget.demoReason;

  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  static const Map<String, String> _ttsLangCode = {
    'en': 'en-IN',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'bn': 'bn-IN',
    'kn': 'kn-IN',
    'pa': 'pa-IN',
  };

  @override
  void initState() {
    super.initState();
    if (!isDemo && !skipSave) {
      HistoryService().save(imageBytes, result, lang);
    }
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleSpeak() async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
      return;
    }
    await _tts.setLanguage(_ttsLangCode[lang] ?? 'en-IN');
    await _tts.setSpeechRate(0.45);
    final text = _buildSpeechText();
    final result = await _tts.speak(text);
    if (result == 1 && mounted) setState(() => _speaking = true);
  }

  String _buildSpeechText() {
    final buf = StringBuffer();
    buf.write('${result.cropName}. ');
    buf.write('${result.diseaseName}. ');
    buf.write('${_t('severity')}: ${result.severity}. ');
    if (result.symptoms.isNotEmpty) buf.write('${result.symptoms}. ');
    for (final step in result.treatment) {
      buf.write('$step. ');
    }
    if (result.pesticide.isNotEmpty) buf.write('${result.pesticide}.');
    return buf.toString();
  }

  String _t(String key) => AppTranslations.get(lang, key);

  void _shareResult() {
    final buf = StringBuffer();
    buf.writeln('🌿 Sasya AI — Analysis Report');
    buf.writeln();
    buf.writeln('🌾 Crop: ${result.cropName}');
    buf.writeln('${result.isHealthy ? "✅" : "⚠️"} Disease: ${result.diseaseName}');
    buf.writeln('📊 Severity: ${result.severity}');
    buf.writeln('🎯 Confidence: ${result.confidence}');
    if (result.symptoms.isNotEmpty) {
      buf.writeln();
      buf.writeln('🔍 Symptoms: ${result.symptoms}');
    }
    if (result.treatment.isNotEmpty) {
      buf.writeln();
      buf.writeln('💊 Treatment:');
      for (int i = 0; i < result.treatment.length; i++) {
        buf.writeln('${i + 1}. ${result.treatment[i]}');
      }
    }
    if (result.prevention.isNotEmpty) {
      buf.writeln();
      buf.writeln('🛡️ Prevention:');
      for (final tip in result.prevention) {
        buf.writeln('✓ $tip');
      }
    }
    if (result.pesticide.isNotEmpty) {
      buf.writeln();
      buf.writeln('🧪 Recommended: ${result.pesticide}');
    }
    buf.writeln();
    buf.writeln('📱 Diagnosed by Sasya AI');
    Share.share(buf.toString(), subject: 'Sasya AI — ${result.cropName} Analysis');
  }

  Color _severityColor() {
    final s = result.severity.toLowerCase();
    if (s.contains('low') || s.contains('कम')) return const Color(0xFF4ADE80);
    if (s.contains('medium') || s.contains('मध्यम')) return const Color(0xFFFACC15);
    if (s.contains('high') || s.contains('अधिक')) return const Color(0xFFF87171);
    return const Color(0xFF74C69D);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: Text(
          _t('disease'),
          style: const TextStyle(color: Color(0xFFB7E4C7)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFB7E4C7)),
        actions: [
          IconButton(
            icon: Icon(
              _speaking ? Icons.stop_circle : Icons.volume_up,
              color: _speaking ? const Color(0xFF4ADE80) : const Color(0xFFB7E4C7),
            ),
            tooltip: _speaking ? 'Stop' : 'Read aloud',
            onPressed: _toggleSpeak,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFB7E4C7)),
            tooltip: _t('share'),
            onPressed: _shareResult,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDemo) _buildDemoBanner(),
                  _buildSummaryCard(),
                  const SizedBox(height: 14),
                  if (!result.isHealthy && result.symptoms.isNotEmpty)
                    InfoCard(
                      title: '🔍 ${_t('symptoms')}',
                      accentColor: const Color(0xFFFBBF24),
                      child: Text(
                        result.symptoms,
                        style: const TextStyle(
                          color: Color(0xFFFEF3C7),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  if (!result.isHealthy && result.treatment.isNotEmpty)
                    _buildTreatmentCard(),
                  if (result.prevention.isNotEmpty) _buildPreventionCard(),
                  if (result.isHealthy) _buildHealthyCard(),
                  const SizedBox(height: 14),
                  _buildBackButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF60A5FA)),
      ),
      child: Text(
        demoReason ?? '🎭 Demo Mode — Tap the key icon in the home screen to add your OpenRouter API key.',
        style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 11, height: 1.5),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3525).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D6A4F)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              imageBytes,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              cacheWidth: 144,
              cacheHeight: 144,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.cropName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB7E4C7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.isHealthy ? "✅" : "⚠️"} ${result.diseaseName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: result.isHealthy
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFCA5A5),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Pill(
                      label: _t('severity'),
                      value: result.severity,
                      color: _severityColor(),
                    ),
                    Pill(
                      label: _t('confidence'),
                      value: result.confidence,
                      color: const Color(0xFF60A5FA),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard() {
    return InfoCard(
      title: '💊 ${_t('treatment')}',
      accentColor: const Color(0xFFF87171),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...result.treatment.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 1, right: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB91C1C),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Color(0xFFFECACA),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (result.pesticide.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF87171).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '🧪 ${_t('recommended')}: ${result.pesticide}',
                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreventionCard() {
    return InfoCard(
      title: '🛡️ ${_t('prevention')}',
      accentColor: const Color(0xFF4ADE80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: result.prevention.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ ',
                  style: TextStyle(color: Color(0xFF4ADE80)),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: Color(0xFFBBF7D0),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHealthyCard() {
    return InfoCard(
      title: '✅ ${_t('greatNews')}',
      accentColor: const Color(0xFF4ADE80),
      child: Text(
        _t('healthyMsg'),
        style: const TextStyle(
          color: Color(0xFFBBF7D0),
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        '← ${_t('tryAnother')}',
        style: const TextStyle(color: Color(0xFF74C69D), fontSize: 15),
      ),
    );
  }
}
