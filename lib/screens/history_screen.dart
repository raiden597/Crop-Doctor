import 'package:flutter/material.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';
import '../services/translations.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String lang;
  const HistoryScreen({super.key, required this.lang});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = HistoryService();
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  String _t(String key) => AppTranslations.get(widget.lang, key);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.loadAll();
    if (mounted) setState(() { _entries = entries; _loading = false; });
  }

  Future<void> _delete(String id) async {
    await _service.delete(id);
    if (mounted) setState(() => _entries.removeWhere((e) => e.id == id));
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return _t('today');
    if (diff.inDays == 1) return _t('yesterday');
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: Text(_t('historyTitle'), style: const TextStyle(color: Color(0xFFB7E4C7))),
        iconTheme: const IconThemeData(color: Color(0xFFB7E4C7)),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Color(0xFFB7E4C7)),
              tooltip: _t('clearHistory'),
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF40916C)))
          : _entries.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (_, i) => _buildEntry(_entries[i]),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _t('noScans'),
            style: const TextStyle(color: Color(0xFF74C69D), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _t('noScansDesc'),
            style: const TextStyle(color: Color(0xFF40916C), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(HistoryEntry entry) {
    final isHealthy = entry.result.isHealthy;
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _delete(entry.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: entry.result,
              imageBytes: entry.imageBytes,
              lang: entry.lang,
              skipSave: true,
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D3525).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D6A4F)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  entry.imageBytes,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  cacheWidth: 128,
                  cacheHeight: 128,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.result.cropName,
                      style: const TextStyle(
                        color: Color(0xFFB7E4C7),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isHealthy ? "✅" : "⚠️"} ${entry.result.diseaseName}',
                      style: TextStyle(
                        color: isHealthy ? const Color(0xFF4ADE80) : const Color(0xFFFCA5A5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.result.severity,
                            style: const TextStyle(color: Color(0xFF74C69D), fontSize: 11),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(entry.timestamp),
                          style: const TextStyle(color: Color(0xFF40916C), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF40916C), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D3525),
        title: Text(_t('clearHistory'), style: const TextStyle(color: Color(0xFFB7E4C7))),
        content: Text(_t('deleteAllConfirm'), style: const TextStyle(color: Color(0xFF74C69D))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('cancel'), style: const TextStyle(color: Color(0xFF74C69D))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.clearAll();
              if (mounted) setState(() => _entries = []);
            },
            child: Text(_t('clearAll'), style: const TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }
}
