import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<String> appLang = ValueNotifier<String>('en');

Future<void> initLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  appLang.value = prefs.getString('language') ?? 'en';
}

Future<void> setLanguage(String lang) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', lang);
  appLang.value = lang;
}
