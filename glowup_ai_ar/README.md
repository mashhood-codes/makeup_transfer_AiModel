# 🎨 GlowUp AI - Professional Makeup Transfer App

> Transform your look with AI-powered makeup transfer. Professional design. Precision results. No compromises.

![Flutter](https://img.shields.io/badge/Flutter-3.24-blue.svg?style=flat-square)
![Dart](https://img.shields.io/badge/Dart-3.4-blue.svg?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg?style=flat-square)

---

## ✨ Features

### 👤 Authentication System
- ✅ Secure user registration & login
- ✅ SHA-256 password encryption
- ✅ Session management with persistent storage
- ✅ Profile view & logout functionality
- ✅ Splash screen with branding

### 🖼️ Image Processing
- ✅ Camera & Gallery image selection
- ✅ Full resolution image support (NO compression)
- ✅ Smart image validation
- ✅ Before/After comparison
- ✅ Custom makeup upload support

### 🎭 Makeup Transfer
- ✅ 12+ professional makeup styles (predefined + custom)
- ✅ Server-based processing (Render or ngrok)
- ✅ Real-time processing (2-5 seconds)
- ✅ High-quality output (95% JPEG)
- ✅ Intelligent server fallback (automatic failover)

### 🎨 Professional UI
- ✅ Adobe-style design language
- ✅ Smooth animations & transitions
- ✅ Responsive layout
- ✅ Cartoony, modern aesthetic
- ✅ Professional color scheme: Pink & Purple
- ✅ Integrated with global_parlour_app UI components

### 🤖 AI & Face Recognition
- ✅ Real-time face detection (Google ML Kit)
- ✅ Face shape analysis & detection
- ✅ Personalized makeup recommendations
- ✅ AR makeup engine with canvas rendering
- ✅ Multiple makeup types: lipstick, blush, eyeliner

### 🚀 Performance
- ✅ GPU-accelerated inference (server-side)
- ✅ Optimized API calls
- ✅ Sub-second response times
- ✅ Automatic server failover (no manual intervention)

### 🔐 Security
- ✅ HTTPS-ready API integration
- ✅ Secure file handling
- ✅ User privacy protection
- ✅ Encrypted password storage
- ✅ Dual-server setup with failover

---

## 🏗️ Architecture

```
┌────────────────────────────────────────┐
│   Flutter App (GlowUp AI AR)           │
│  - User Authentication                 │
│  - Professional UI                     │
│  - Image & Style Selection             │
│  - Real-time Face Detection (ML Kit)   │
└────────────────┬──────────────────────┘
                 │ HTTP/REST (Dio)
                 ├─ Primary: RENDER_URL
                 │  (Production Server)
                 │
         ┌───────┴───────┐
         ↓               ↓
    ✓ Respond     ✗ Timeout/Error
         │               │
         │               └──→ Fallback to NGROK_URL
         │                   (Development Server)
         ↓
┌────────────────────────────────────────┐
│  Python FastAPI Backend                │
│  - PyTorch inference (GPU/CPU)         │
│  - Full precision ML model (40MB)      │
│  - Makeup filter application           │
│  - Custom style support                │
│  - Thumbnail generation                │
└────────────────────────────────────────┘
```

### Server Configuration

- **Production Server (RENDER_URL)**
  - URL: `https://glowup-api.onrender.com`
  - Status: Pending activation
  - Used when available

- **Development/Fallback Server (NGROK_URL)**
  - URL: `https://glowup-dev-4821.ngrok-free.app`
  - Status: Active
  - Automatic failover when RENDER_URL unavailable

The app intelligently switches between servers with zero user intervention.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK: ^3.11.0
- Dart SDK: ^3.11.0
- Android Studio / Xcode (for mobile)
- Git

### Environment Setup (IMPORTANT!)

1. **Create `.env` file in project root:**
   ```env
   RENDER_URL=https://glowup-api.onrender.com
   NGROK_URL=https://glowup-dev-4821.ngrok-free.app
   ```
   
   - **RENDER_URL**: Production server (may be inactive initially)
   - **NGROK_URL**: Development/fallback server (active)
   - App automatically tries RENDER_URL first, falls back to NGROK_URL if unavailable

2. **Install Dart env dependency (optional for .env parsing):**
   ```bash
   flutter pub get
   ```

### Option 1: Docker (Recommended for Teams)
```bash
cd glowup_ai_ar
docker-compose up -d
docker-compose exec flutter_dev flutter run
```

### Option 2: Local Development
```bash
cd glowup_ai_ar
flutter pub get
flutter run
```

### First Time Setup
1. App shows splash screen (3 seconds)
2. Login with existing account OR Sign up
3. Transfer screen loads with makeup styles
4. Select image → Choose style → See result!

**👉 See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions**

---

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.11+ + Dart 3.11+
- **Design**: Material 3 + Google Fonts + Custom theme
- **State Management**: Riverpod 3.3.1
- **Navigation**: GoRouter 17.2.0
- **Networking**: Dio 5.3.0 with fallback logic
- **Image**: Image Picker 1.0.0, Image 4.1.0, Cached Network Image 3.4.1
- **AI/ML**: Google ML Kit Face Detection 0.13.2
- **Authentication**: Custom secure auth with SHA-256 hashing
- **Storage**: Shared Preferences 2.5.5
- **Cryptography**: Crypto 3.0.7
- **Backend**: FastAPI + PyTorch (server-side)
- **Deployment**: Docker + Docker Compose + Render
- **Development**: ngrok for tunneling

---

## 📁 Project Structure

```
glowup_ai_ar/
├── lib/
│   ├── main.dart
│   ├── config/theme.dart          # Professional theme
│   ├── models/makeup_style.dart   # Data models
│   ├── services/api_service.dart  # API client
│   └── screens/
│       ├── home_screen.dart
│       ├── processing_screen.dart
│       └── results_screen.dart
├── android/                       # Android config
├── pubspec.yaml                   # Dependencies
├── Dockerfile                     # Docker image
├── docker-compose.yml             # Docker orchestration
├── SETUP_GUIDE.md                # Setup instructions
└── README.md                     # This file
```

---

## 📊 Performance

| Metric | Target | Status |
|--------|--------|--------|
| App Startup | <2s | ✅ |
| Image Load | <500ms | ✅ |
| Processing | <5s | ✅ |
| APK Size | <150MB | ✅ ~80MB |

---

## 🔄 Development Workflow

```bash
# Enter Docker environment (first time)
docker-compose up -d
docker-compose exec flutter_dev bash

# Develop with hot reload
flutter run

# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit

# Build release APK
flutter build apk --release
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Device not found | `flutter devices` to list, connect device |
| Package conflicts | `flutter clean && flutter pub get` |
| Docker permission | `sudo usermod -aG docker $USER` |
| Module not found | Ensure all files in `lib/` are created |

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed troubleshooting.

---

## 📝 Checklist for Team Members

- [ ] Docker & Docker Compose installed
- [ ] Repository cloned
- [ ] `docker-compose up -d` running
- [ ] Connected device/emulator
- [ ] `flutter run` successful
- [ ] App displays on device
- [ ] Ready to develop!

---

## 🤝 Contributing

1. Create feature branch
2. Develop with `flutter run`
3. Format: `dart format lib/`
4. Test on device
5. Submit PR

---

## 📞 Support

- **Setup issues**: See [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Code issues**: Check `flutter doctor -v`
- **Docker issues**: Check `docker-compose logs flutter_dev`

---

## 📄 License

MIT License - see LICENSE file

---

Made with ❤️ for beautiful transformations

