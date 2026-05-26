# 🌿 Crop Doctor

AI-powered crop disease detection for Indian farmers. Photograph a diseased leaf and get an instant diagnosis — disease name, severity, treatment steps, and Indian pesticide recommendations.

**[⬇️ Download APK](https://github.com/raiden597/crop-doctor/releases/latest)**

---

## Features

- **AI diagnosis** — powered by Google Gemini via OpenRouter
- **Offline disease guide** — browse 30 common diseases across 10 crops with no internet
- **8 languages** — English, Hindi, Marathi, Tamil, Telugu, Bengali, Kannada, Punjabi
- **Scan history** — all past analyses saved on your device
- **Share results** — send diagnosis to other farmers or agronomists
- **Low-end device support** — optimised for phones like Moto G96

**Supported crops:** Rice, Wheat, Tomato, Cotton, Sugarcane, Maize, Potato, Onion, Chilli, Groundnut

---

## Getting Started

### 1. Get a free API key
1. Sign up at [openrouter.ai](https://openrouter.ai) (free)
2. Go to **Keys** → create a new key
3. Free tier gives ~50 analyses per day

### 2. Install the app
Download the APK from the [Releases](https://github.com/raiden597/crop-doctor/releases) page and install it on your Android phone.

> Enable "Install from unknown sources" in your phone settings if prompted.

### 3. Enter your key
On first launch, paste your OpenRouter key. The app verifies it before saving — your key stays on your device only.

---

## Privacy

- No account required
- Images go directly from your phone to the AI model
- Scan history is stored locally on your device only
- No data is sent to any server we control

---

## Build from Source

```bash
git clone https://github.com/raiden597/crop-doctor.git
cd crop-doctor
flutter pub get
flutter run
```

Requirements: Flutter 3.0+, Android SDK

```bash
# Release APK
flutter build apk --release
```

---

## Disclaimer

AI diagnosis is a guide, not a substitute for expert advice. For serious outbreaks, consult your local Krishi Vigyan Kendra or call the Kisan Helpline: **1800-180-1551** (free).

---

Made for Indian farmers 🇮🇳
