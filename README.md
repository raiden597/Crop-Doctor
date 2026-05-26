# 🌿 Crop Doctor - Flutter App

AI-powered crop disease detection for Indian farmers. Built with Flutter for iOS & Android.

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** (3.0+): https://flutter.dev/docs/get-started/install
- **Android Studio** (for Android development)
- **Xcode** (Mac only, for iOS development)
- **Free Gemini API Key**: https://aistudio.google.com

### 1️⃣ Create Project & Copy Files

```bash
flutter create crop_doctor
cd crop_doctor
```

Copy all files from this folder into your project, replacing the defaults.

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure API Key

Open `lib/services/ai_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

with your actual Gemini API key from https://aistudio.google.com

**🔐 Production tip:** Use `flutter_dotenv` or `flutter_secure_storage` instead of hardcoding!

### 4️⃣ Add Permissions

**iOS** — Open `ios/Runner/Info.plist`, add contents from `ios_permissions.txt`

**Android** — Open `android/app/src/main/AndroidManifest.xml`, add from `android_permissions.txt`

### 5️⃣ Run It

```bash
# Android
flutter run

# iOS (Mac only)
flutter run -d ios

# Build release versions
flutter build apk --release           # Android APK
flutter build appbundle --release     # Google Play upload
flutter build ipa --release           # Apple App Store
```

---

## 📱 Publishing

### Google Play Store ($25 one-time)
1. Create developer account: https://play.google.com/console
2. Run `flutter build appbundle --release`
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Fill listing details (screenshots, description, content rating)
5. Submit for review (1–3 days)

### Apple App Store ($99/year)
1. Enroll: https://developer.apple.com/programs/
2. Run `flutter build ipa --release` (Mac required)
3. Upload via Xcode or Transporter app
4. Configure in App Store Connect
5. Submit for review (1–7 days)

---

## 📂 Project Structure

```
crop_doctor/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── crop_result.dart         # Data model + AI response parser
│   ├── services/
│   │   ├── ai_service.dart          # Gemini Vision API calls
│   │   └── translations.dart        # English/Hindi strings
│   ├── screens/
│   │   ├── home_screen.dart         # Upload + analyze screen
│   │   └── result_screen.dart       # Disease results display
│   └── widgets/
│       └── info_card.dart           # Reusable card components
├── pubspec.yaml                     # Dependencies
├── ios_permissions.txt              # iOS Info.plist additions
└── android_permissions.txt          # Android Manifest additions
```

---

## 🎯 Features

✅ Camera + Gallery image upload
✅ AI-powered disease detection (Gemini Vision)
✅ Image compression for fast API calls
✅ Hindi + English with persistence
✅ Severity levels with color coding
✅ Step-by-step treatment instructions
✅ Prevention tips
✅ Indian pesticide recommendations
✅ Demo mode (works without API key)
✅ Beautiful dark green theme
✅ Production-ready architecture

---

## 🔮 Next Features to Add

- 📴 **Offline mode** — Add `tflite_flutter` + train model on PlantVillage dataset
- 🗣️ **Voice narration** — `flutter_tts` for illiterate farmers
- 📍 **Nearby agri-shops** — `google_maps_flutter` + Places API
- 💾 **History tracking** — `sqflite` for past analyses
- 📤 **WhatsApp sharing** — `share_plus` package
- 🌐 **More languages** — Tamil, Telugu, Marathi, Bengali, Punjabi
- 📞 **Kisan Helpline integration** — One-tap call to 1800-180-1551

---

## 💰 Cost Estimates

| Service | Cost |
|---------|------|
| Gemini Vision API | Free tier: 1,500 requests/day |
| Google Play Store | $25 one-time |
| Apple Developer | $99/year |
| Domain (optional) | ~₹800/year |
| **Total to launch** | **~₹10,000 (~$120)** |

---

## 📚 Resources

- Flutter Docs: https://flutter.dev/docs
- Gemini API: https://ai.google.dev/docs
- PlantVillage Dataset: https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset
- PM-KISAN Portal: https://pmkisan.gov.in
- Kisan Call Center: 1800-180-1551

---

Made with 💚 for Indian Farmers
