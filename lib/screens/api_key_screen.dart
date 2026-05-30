import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/key_service.dart';
import 'home_screen.dart';

class ApiKeyScreen extends StatefulWidget {
  final bool isEditing;
  const ApiKeyScreen({super.key, this.isEditing = false});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _successInfo;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && KeyService.currentKey != null) {
      _controller.text = KeyService.currentKey!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verifyAndSave() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Please enter your API key.');
      return;
    }
    if (!key.startsWith('sk-or-')) {
      setState(() => _error = 'OpenRouter keys start with "sk-or-". Check your key.');
      return;
    }

    setState(() { _loading = true; _error = null; _successInfo = null; });

    try {
      final res = await http.get(
        Uri.parse('https://openrouter.ai/api/v1/auth/key'),
        headers: {'Authorization': 'Bearer $key'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        final label = data?['label'] as String? ?? 'API key';
        final remaining = data?['limit_remaining'];
        final info = remaining != null
            ? '$label · ${(remaining as num).toStringAsFixed(0)} credits remaining'
            : label;
        await KeyService.saveKey(key);
        if (mounted) {
          setState(() { _successInfo = '✅ Verified: $info'; _loading = false; });
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            if (widget.isEditing) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          }
        }
      } else if (res.statusCode == 401) {
        setState(() { _error = 'Invalid key — not recognised by OpenRouter.'; _loading = false; });
      } else {
        setState(() { _error = 'Verification failed (${res.statusCode}). Try again.'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Could not reach OpenRouter. Check your connection.'; _loading = false; });
    }
  }

  void _useDemo() {
    KeyService.clearKey();
    if (widget.isEditing) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text('🌿', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  const Text(
                    'Sasya AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB7E4C7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your free OpenRouter API key to enable AI analysis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF74C69D), fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _buildSteps(),
                  const SizedBox(height: 28),
                  _buildKeyField(),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    _buildBanner(_error!, const Color(0xFFF87171), const Color(0xFFFCA5A5)),
                  ],
                  if (_successInfo != null) ...[
                    const SizedBox(height: 10),
                    _buildBanner(_successInfo!, const Color(0xFF4ADE80), const Color(0xFFBBF7D0)),
                  ],
                  const SizedBox(height: 16),
                  _buildVerifyButton(),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _loading ? null : _useDemo,
                    child: const Text(
                      'Skip — use demo mode',
                      style: TextStyle(color: Color(0xFF40916C), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3525).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D6A4F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How to get a free key:',
              style: TextStyle(color: Color(0xFFB7E4C7), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          _step('1', 'Go to openrouter.ai and sign up for free'),
          _step('2', 'Open "Keys" from your account menu'),
          _step('3', 'Create a new key and paste it below'),
          const SizedBox(height: 6),
          const Text(
            'Free tier gives ~50 analyses/day with Gemini Flash.',
            style: TextStyle(color: Color(0xFF40916C), fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.open_in_browser, size: 16, color: Color(0xFF74C69D)),
              label: const Text(
                'Go to openrouter.ai →',
                style: TextStyle(color: Color(0xFF74C69D), fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2D6A4F)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => launchUrl(
                Uri.parse('https://openrouter.ai/keys'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String n, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            margin: const EdgeInsets.only(top: 1, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF2D6A4F), shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(n, style: const TextStyle(color: Color(0xFFB7E4C7), fontSize: 11)),
            ),
          ),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Color(0xFF74C69D), fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyField() {
    return TextField(
      controller: _controller,
      obscureText: _obscure,
      style: const TextStyle(color: Color(0xFFB7E4C7), fontSize: 13, fontFamily: 'monospace'),
      decoration: InputDecoration(
        hintText: 'sk-or-v1-...',
        hintStyle: const TextStyle(color: Color(0xFF2D6A4F)),
        filled: true,
        fillColor: const Color(0xFF1D3525).withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D6A4F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D6A4F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF40916C), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF40916C), size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _verifyAndSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF40916C),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _loading
          ? const SizedBox(
              height: 18, width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFFB7E4C7)),
              ),
            )
          : const Text('Verify & Save',
              style: TextStyle(color: Color(0xFFD8F3DC), fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBanner(String msg, Color border, Color text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: border.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border.withValues(alpha: 0.6)),
      ),
      child: Text(msg, style: TextStyle(color: text, fontSize: 12, height: 1.4)),
    );
  }
}
