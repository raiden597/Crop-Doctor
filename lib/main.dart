import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/api_key_screen.dart';
import 'screens/home_screen.dart';
import 'services/key_service.dart';
import 'services/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([initLanguage(), KeyService.init()]);
  runApp(const CropDoctorApp());
}

class CropDoctorApp extends StatelessWidget {
  const CropDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (_, lang, __) => MaterialApp(
        key: ValueKey(lang), // rebuild entire app on language change
        title: 'Sasya AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF2D6A4F),
          scaffoldBackgroundColor: const Color(0xFF0A1A0A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF40916C),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.merriweatherTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: KeyService.hasKey ? const HomeScreen() : const ApiKeyScreen(),
      ),
    );
  }
}
