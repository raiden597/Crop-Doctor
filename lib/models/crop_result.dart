class CropAnalysisResult {
  final String cropName;
  final String diseaseName;
  final bool isHealthy;
  final String severity;
  final String confidence;
  final String symptoms;
  final List<String> treatment;
  final List<String> prevention;
  final String pesticide;

  CropAnalysisResult({
    required this.cropName,
    required this.diseaseName,
    required this.isHealthy,
    required this.severity,
    required this.confidence,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.pesticide,
  });

  // Parse the tagged format from AI response
  factory CropAnalysisResult.fromAIResponse(String response) {
    String getField(String tag) {
      final regex = RegExp('$tag\\s*:\\s*(.+)', caseSensitive: false);
      final match = regex.firstMatch(response);
      return match?.group(1)?.trim().replaceAll(RegExp(r'^\[|\]$'), '').trim() ?? '';
    }

    List<String> getList(String fieldValue) {
      return fieldValue
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final healthy = getField('HEALTHY').toLowerCase();
    final isHealthy = healthy.startsWith('y') || healthy.contains('स्वस्थ');

    return CropAnalysisResult(
      cropName: getField('CROP').isEmpty ? 'Unknown plant' : getField('CROP'),
      diseaseName: getField('DISEASE').isEmpty ? 'Unknown' : getField('DISEASE'),
      isHealthy: isHealthy,
      severity: getField('SEVERITY').isEmpty ? 'Unknown' : getField('SEVERITY'),
      confidence: getField('CONFIDENCE').isEmpty ? 'N/A' : getField('CONFIDENCE'),
      symptoms: getField('SYMPTOMS'),
      treatment: getList(getField('TREATMENT')),
      prevention: getList(getField('PREVENTION')),
      pesticide: getField('PESTICIDE'),
    );
  }
}
