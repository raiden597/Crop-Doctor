import 'dart:convert';
import 'dart:typed_data';
import 'crop_result.dart';

class HistoryEntry {
  final String id;
  final DateTime timestamp;
  final Uint8List imageBytes;
  final CropAnalysisResult result;
  final String lang;

  HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.imageBytes,
    required this.result,
    required this.lang,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'image': base64Encode(imageBytes),
        'lang': lang,
        'cropName': result.cropName,
        'diseaseName': result.diseaseName,
        'isHealthy': result.isHealthy,
        'severity': result.severity,
        'confidence': result.confidence,
        'symptoms': result.symptoms,
        'treatment': result.treatment,
        'prevention': result.prevention,
        'pesticide': result.pesticide,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      imageBytes: base64Decode(json['image'] as String),
      lang: json['lang'] ?? 'en',
      result: CropAnalysisResult(
        cropName: json['cropName'] ?? '',
        diseaseName: json['diseaseName'] ?? '',
        isHealthy: json['isHealthy'] ?? false,
        severity: json['severity'] ?? '',
        confidence: json['confidence'] ?? '',
        symptoms: json['symptoms'] ?? '',
        treatment: List<String>.from(json['treatment'] ?? []),
        prevention: List<String>.from(json['prevention'] ?? []),
        pesticide: json['pesticide'] ?? '',
      ),
    );
  }
}
