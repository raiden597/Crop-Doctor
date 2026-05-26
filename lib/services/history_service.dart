import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';
import '../models/crop_result.dart';

class HistoryService {
  static const String _key = 'scan_history';
  static const int _maxEntries = 10;

  Future<void> save(Uint8List imageBytes, CropAnalysisResult result, String lang) async {
    final entries = await loadAll();
    entries.insert(0, HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
      result: result,
      lang: lang,
    ));
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<List<HistoryEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> delete(String id) async {
    final entries = await loadAll();
    entries.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
