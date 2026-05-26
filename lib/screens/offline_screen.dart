import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/disease_database.dart';
import '../services/language_provider.dart';
import '../services/translations.dart';
import 'result_screen.dart';


class OfflineScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String lang;

  const OfflineScreen({
    super.key,
    required this.imageBytes,
    required this.lang,
  });

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  String? _selectedCrop;

  String _t(String key) => AppTranslations.get(appLang.value, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: Text(_t('offlineGuide'),
            style: const TextStyle(color: Color(0xFFB7E4C7))),
        iconTheme: const IconThemeData(color: Color(0xFFB7E4C7)),
        leading: _selectedCrop != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedCrop = null),
              )
            : null,
      ),
      body: _selectedCrop == null ? _buildCropGrid() : _buildDiseaseList(),
    );
  }

  Widget _buildCropGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOfflineBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            _t('selectCrop'),
            style: const TextStyle(
              color: Color(0xFF74C69D),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: DiseaseDatabase.crops.length,
            itemBuilder: (_, i) {
              final (emoji, name) = DiseaseDatabase.crops[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedCrop = name),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D3525).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D6A4F)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFFB7E4C7),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseList() {
    final diseases = DiseaseDatabase.forCrop(_selectedCrop!);
    final cropEntry = DiseaseDatabase.crops
        .firstWhere((c) => c.$2 == _selectedCrop!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOfflineBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            '${cropEntry.$1} $_selectedCrop — ${_t('commonDiseases')}',
            style: const TextStyle(
              color: Color(0xFF74C69D),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            _t('tapDisease'),
            style: const TextStyle(color: Color(0xFF40916C), fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: diseases.length,
            itemBuilder: (_, i) => _buildDiseaseCard(diseases[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseCard(LocalDisease disease) {
    final severityColor = _severityColor(disease.severity);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: disease.toResult(),
              imageBytes: widget.imageBytes,
              lang: widget.lang,
              isDemo: true,
              skipSave: false,
              demoReason:
                  '📡 Offline reference — AI unavailable. Showing local disease guide.',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1D3525).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D6A4F)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease.diseaseName,
                    style: const TextStyle(
                      color: Color(0xFFB7E4C7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    disease.symptoms,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF74C69D),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: severityColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${AppTranslations.get(widget.lang, 'severity')}: ${disease.severity}',
                      style: TextStyle(color: severityColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF40916C), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF78350F).withValues(alpha: 0.3),
      child: Row(
        children: [
          const Text('📡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _t('noConnection'),
              style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    final s = severity.toLowerCase();
    if (s == 'low') return const Color(0xFF4ADE80);
    if (s == 'medium') return const Color(0xFFFACC15);
    if (s == 'high') return const Color(0xFFF87171);
    return const Color(0xFF74C69D);
  }
}
