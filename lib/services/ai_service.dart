import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/crop_result.dart';
import 'key_service.dart';

// Top-level so compute() can send it to an isolate
String _compressAndEncode(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) throw Exception('Could not decode image');
  img.Image resized = image;
  const maxDim = 512;
  if (image.width > maxDim || image.height > maxDim) {
    final scale =
        maxDim / (image.width > image.height ? image.width : image.height);
    resized = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
    );
  }
  return base64Encode(Uint8List.fromList(img.encodeJpg(resized, quality: 70)));
}

class AIService {
  static String get _apiKey => KeyService.currentKey ?? '';

  static const String _model = 'google/gemini-3.1-flash-lite';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static bool isApiKeyMissing() => !KeyService.hasKey;

  // Cached max_tokens: fetched from account balance, refreshed every 5 min
  static int _cachedMaxTokens = 400;
  static DateTime? _cacheTime;

  static int _tokensFromBudget(dynamic remaining) {
    if (remaining == null) return 400; // no cap info, use safe default
    // On OpenRouter, 1 credit = 1 affordable output token
    // Keep a 10-token buffer and cap at 500
    return ((remaining as num).toDouble() - 2).clamp(10.0, 500.0).toInt();
  }

  Future<int> _getOptimalMaxTokens() async {
    final now = DateTime.now();
    if (_cacheTime != null && now.difference(_cacheTime!) < const Duration(minutes: 5)) {
      return _cachedMaxTokens;
    }
    try {
      final res = await http.get(
        Uri.parse('https://openrouter.ai/api/v1/auth/key'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      ).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        final remaining = data?['limit_remaining'];
        _cachedMaxTokens = _tokensFromBudget(remaining);
        _cacheTime = now;
      }
    } catch (_) {}
    return _cachedMaxTokens;
  }

  Future<http.Response> _postToAI(String base64Image, String prompt, int maxTokens) {
    return http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': maxTokens,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          }
        ],
      }),
    ).timeout(const Duration(seconds: 30));
  }

  Future<CropAnalysisResult> analyzeCropBytes(Uint8List bytes, String language) async {
    // Run in isolate — avoids blocking the UI thread on low-end devices
    final base64Image = await compute(_compressAndEncode, bytes);
    final prompt = _buildPrompt(language);
    int maxTokens = await _getOptimalMaxTokens();

    var response = await _postToAI(base64Image, prompt, maxTokens);

    // On 402: extract exact affordable amount and retry once inline
    if (response.statusCode == 402) {
      final errorMsg =
          (jsonDecode(response.body)['error']?['message'] as String?) ?? '';
      final m = RegExp(r'can only afford (\d+)').firstMatch(errorMsg);
      if (m != null) {
        maxTokens = (int.parse(m.group(1)!) - 2).clamp(10, 500);
        _cachedMaxTokens = maxTokens;
        _cacheTime = DateTime.now();
        response = await _postToAI(base64Image, prompt, maxTokens);
      }
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final text = body['choices']?[0]?['message']?['content'] as String? ?? '';
    if (text.isEmpty) throw Exception('Empty response from AI');

    // If truncated, bump cache so next call requests more
    final completionTokens =
        (body['usage']?['completion_tokens'] as num?)?.toInt() ?? 0;
    if (completionTokens > 0 && completionTokens >= maxTokens) {
      _cachedMaxTokens = (maxTokens + 50).clamp(50, 500);
      _cacheTime = null;
    }

    return CropAnalysisResult.fromAIResponse(text);
  }

  static bool isImageTooBlurry(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return false;
      final small = img.copyResize(img.grayscale(image), width: 200);
      double laplacianVariance = 0;
      int count = 0;
      for (int y = 1; y < small.height - 1; y++) {
        for (int x = 1; x < small.width - 1; x++) {
          final c = small.getPixel(x, y).r.toDouble();
          final t = small.getPixel(x, y - 1).r.toDouble();
          final b = small.getPixel(x, y + 1).r.toDouble();
          final l = small.getPixel(x - 1, y).r.toDouble();
          final r = small.getPixel(x + 1, y).r.toDouble();
          final lap = (4 * c - t - b - l - r).abs();
          laplacianVariance += lap * lap;
          count++;
        }
      }
      return count > 0 && (laplacianVariance / count) < 80;
    } catch (_) {
      return false;
    }
  }

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'Hindi',
    'mr': 'Marathi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'bn': 'Bengali',
    'kn': 'Kannada',
    'pa': 'Punjabi',
  };

  String _buildPrompt(String language) {
    final langName = _languageNames[language] ?? 'English';
    return '''Analyze this crop/plant image as an Indian agricultural expert. Respond in EXACTLY this format. Keep each field brief (one short phrase or sentence). Separate list items with |. ALL values in $langName:

CROP: [crop name]
DISEASE: [disease name or "Healthy"]
HEALTHY: [yes/no]
SEVERITY: [Low/Medium/High/None]
CONFIDENCE: [e.g. 85%]
SYMPTOMS: [key symptom, brief]
TREATMENT: [action 1 | action 2]
PREVENTION: [tip 1 | tip 2]
PESTICIDE: [product name and dose]''';
  }

  CropAnalysisResult getDemoResult(String language) {
    if (language == 'hi') {
      return CropAnalysisResult(
        cropName: 'टमाटर',
        diseaseName: 'पत्ती झुलसा रोग',
        isHealthy: false,
        severity: 'मध्यम',
        confidence: '87%',
        symptoms: 'पत्तियों पर भूरे धब्बे और पीले किनारे, फफूंद संक्रमण का संकेत',
        treatment: [
          'संक्रमित पत्तियों को तुरंत हटाएं',
          'कॉपर ऑक्सीक्लोराइड स्प्रे करें (2g/L)',
          'सप्ताह में 2 बार सुबह सिंचाई करें',
        ],
        prevention: [
          'पौधों के बीच उचित दूरी रखें',
          'पत्तियों पर पानी लगने से बचें',
        ],
        pesticide: 'Mancozeb 75% WP (Indofil M-45) - 2 ग्राम प्रति लीटर पानी',
      );
    }
    return CropAnalysisResult(
      cropName: 'Tomato',
      diseaseName: 'Early Blight',
      isHealthy: false,
      severity: 'Medium',
      confidence: '87%',
      symptoms: 'Brown spots with yellow halos on leaves, indicating fungal infection',
      treatment: [
        'Remove infected leaves immediately',
        'Spray Copper Oxychloride (2g/L water)',
        'Water at base of plant, not on leaves',
      ],
      prevention: [
        'Maintain proper spacing between plants',
        'Avoid overhead watering',
      ],
      pesticide: 'Mancozeb 75% WP (Indofil M-45) - 2g per litre of water',
    );
  }
}
