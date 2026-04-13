# 🎨 GlowUp AI - Flutter App Setup Guide

## Project Overview

**GlowUp** is a professional AI-powered makeup transfer application built with Flutter. This guide covers local development and Docker-based team development.

---

## 📋 Prerequisites

### Option 1: Local Development (Manual)
- **Flutter SDK**: 3.24.0 or higher
- **Dart SDK**: 3.4.0+
- **Android SDK**: API 21+
- **Java JDK**: 11 or 17
- **IDE**: Android Studio / VS Code / IntelliJ

### Option 2: Docker Development (Recommended for Teams)
- **Docker**: 24.0+
- **Docker Compose**: 2.20+

---

## 🚀 Quick Start with Docker (RECOMMENDED)

### Step 1: Clone/Navigate to Project
```bash
cd glowup_ai_ar
```

### Step 2: Build Docker Image
```bash
docker-compose build
```

### Step 3: Start Development Container
```bash
docker-compose up -d
```

### Step 4: Enter Container
```bash
docker-compose exec flutter_dev bash
```

### Step 5: Run Flutter App (inside container)
```bash
# Connect device or start emulator first
flutter devices

# Run on device
flutter run

# Or build APK
flutter build apk --release
```

### Step 6: Stop Container
```bash
docker-compose down
```

---

## 🛠️ Local Development Setup

### Step 1: Install Flutter
```bash
# Windows
choco install flutter

# macOS
brew install flutter

# Linux
mkdir -p ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

### Step 2: Install Dependencies
```bash
cd glowup_ai_ar

# Get all packages
flutter pub get

# Check setup
flutter doctor
```

### Step 3: Android Setup
```bash
# Accept Android SDK licenses
flutter doctor --android-licenses

# Check Android SDK location
flutter config --android-sdk-path <path-to-android-sdk>
```

### Step 4: Run the App

#### On Physical Device
```bash
# Connect device via USB (with USB debugging enabled)
flutter devices

flutter run
```

#### On Emulator
```bash
# Start Android emulator first
emulator -avd <avd-name>

# Then run
flutter run
```

#### Build APK (Release)
```bash
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
glowup_ai_ar/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   └── theme.dart            # Professional theme & colors
│   ├── models/
│   │   └── makeup_style.dart     # Data models
│   ├── services/
│   │   └── api_service.dart      # Backend API client
│   └── screens/
│       ├── home_screen.dart      # Main UI
│       ├── processing_screen.dart # Loading screen
│       └── results_screen.dart    # Results display
├── android/                       # Android native config
├── ios/                          # iOS native config
├── pubspec.yaml                  # Dependencies & config
├── Dockerfile                    # Docker image definition
├── docker-compose.yml            # Docker orchestration
├── .dockerignore                 # Docker ignore rules
└── SETUP_GUIDE.md               # This file
```

---

## 🎯 Key Features Built

### ✅ Home Screen
- Image picker (Camera/Gallery)
- Makeup style selector (5 default styles)
- Professional UI with custom fonts

### ✅ Processing Screen
- Real-time progress animation
- Status updates
- Error handling

### ✅ Results Screen
- Full-resolution image display
- Before/After comparison toggle
- Share functionality
- Processing statistics

### ✅ API Integration
- RESTful API client (Dio)
- Error handling & retries
- Upload/Download support

---

## 🎨 Design System

### Colors
```
Primary Purple:   #8B5CF6
Secondary Pink:   #EC4899
Tertiary Teal:    #06B6D4
Text Primary:     #1A1A1A
Text Secondary:   #6B7280
Background:       #FAFAFA
Surface:          #FFFFFF
```

### Typography
- **Headlines**: Poppins (Bold/SemiBold)
- **Body**: Inter (Regular/Medium)
- **Professional, modern aesthetic**

---

## 🔧 Configuration

### API Server Connection
Edit `lib/services/api_service.dart` - Line 12:
```dart
static String _serverIp = '192.168.1.100:5000';
```

Change `192.168.1.100` to your Python backend server IP.

### Timeouts
- **Connect**: 30 seconds
- **Receive**: 5 minutes (large image processing)

Adjust in `lib/services/api_service.dart` if needed.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| image_picker | 1.0.0 | Image selection |
| dio | 5.3.0 | HTTP requests |
| google_fonts | 6.1.0 | Typography |
| share_plus | 7.2.0 | Share functionality |
| permission_handler | 11.4.0 | Permissions |

---

## 🐛 Troubleshooting

### "Flutter not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:<flutter-sdk-path>/bin"
```

### "Android SDK not found"
```bash
flutter config --android-sdk-path <path-to-android-sdk>
```

### "Device not found"
```bash
# List connected devices
flutter devices

# For emulator
emulator -list-avds
emulator -avd <name>
```

### "Package conflicts"
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

### Docker Permission Issues
```bash
# On Linux, add current user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

---

## 💻 Development Workflow

### 1. Make Changes
Edit files in `lib/` directory

### 2. Hot Reload (Fast)
```bash
flutter run
# Press 'r' in terminal to hot reload
```

### 3. Hot Restart (Full Restart)
```bash
# Press 'R' in terminal to hot restart
```

### 4. Run with Logging
```bash
flutter run -v
```

### 5. Format Code
```bash
dart format lib/
```

---

## 📱 Building for Production

### APK (Android Standalone)
```bash
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Size: ~50-80 MB
```

### App Bundle (Google Play)
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Size: ~40-60 MB
```

### Signing APK
```bash
# Create keystore
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure signing in android/app/build.gradle
# Then build:
flutter build apk --release
```

---

## 🔐 Security Checklist

- [ ] Change default API IP in `api_service.dart`
- [ ] Use HTTPS for production API
- [ ] Enable ProGuard for Android (automatic)
- [ ] Remove debug symbols from release build
- [ ] Test on real device before publishing
- [ ] Check permissions in `AndroidManifest.xml`

---

## 🚀 Team Development with Docker

### For Team Members

1. **Clone Repository**
```bash
git clone <repo-url>
cd glowup_ai_ar
```

2. **Start Docker Environment**
```bash
docker-compose up -d
```

3. **Enter Development Container**
```bash
docker-compose exec flutter_dev bash
```

4. **Run App**
```bash
flutter run
```

5. **No version conflicts!** ✨
   - Flutter: 3.24.0 (same for everyone)
   - Dart: 3.4.0 (same for everyone)
   - Java: 11 (same for everyone)
   - Android SDK: Managed by Docker

---

## 📊 Performance Tips

1. **Use Release Builds for Testing**
```bash
flutter run --release
```

2. **Profile Performance**
```bash
flutter run --profile
```

3. **Check Package Size**
```bash
flutter analyze
dart pub deps
```

---

## 📚 Useful Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Google Fonts](https://fonts.google.com/)
- [Material Design](https://m3.material.io/)

---

## 👥 Contributing

1. Create a branch: `git checkout -b feature/your-feature`
2. Code with `flutter run`
3. Test thoroughly
4. Commit: `git commit -m "Add feature: description"`
5. Push & create PR

---

## 📞 Support

For issues:
1. Check logs: `flutter logs`
2. Run diagnostics: `flutter doctor -v`
3. Check Docker logs: `docker-compose logs flutter_dev`
4. See troubleshooting section above

---

## ✅ Checklist Before Commit

- [ ] Code formatted with `dart format lib/`
- [ ] No analysis warnings: `flutter analyze`
- [ ] Tests pass (if applicable)
- [ ] App runs on device/emulator
- [ ] Dependencies up to date: `flutter pub upgrade`

---

**Made with ❤️ by GlowUp Team**

Last Updated: 2026-04-10
Flutter SDK: 3.24.0
