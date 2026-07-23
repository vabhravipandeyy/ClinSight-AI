# ClinSight AI — Flutter App

> Patient Case Sheet Intelligence Agent — Mobile Frontend

A full-featured Flutter mobile app that mirrors the ClinSight AI web dashboard with clinical-grade UI.

---

## 📱 Screens Overview

| Screen | Description |
|--------|-------------|
| **Login** | Doctor sign-in with animated entry |
| **Dashboard** | Stats, HbA1c charts, patient list, drug alerts |
| **Patients** | Searchable + filterable patient list |
| **Patient Detail** | Vitals, Labs with trend charts, Medications, Body Map |
| **AI Assistant** | Chat interface with clinical AI responses |

---

## 🚀 How to Run

### Prerequisites

Make sure you have Flutter installed. Check with:
```bash
flutter doctor
```

If not installed, follow: https://docs.flutter.dev/get-started/install

**Required Flutter version:** `>=3.0.0`

---

### Step 1 — Clone / Extract the project

```bash
# If you extracted the zip, navigate into the folder:
cd clinsight_flutter
```

---

### Step 2 — Get dependencies

```bash
flutter pub get
```

---

### Step 3 — Run on a device/emulator

**Android (emulator or physical device):**
```bash
flutter run
```

**iOS (requires macOS + Xcode):**
```bash
flutter run -d iphone
```

**Specific device:**
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

---

### Step 4 — Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

### Step 5 — Build for iOS (macOS only)

```bash
flutter build ios --release
```

---

## 🗂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, fonts, theme config
├── models/
│   └── mock_data.dart           # Patient data models + mock data
├── widgets/
│   └── common_widgets.dart      # Reusable UI components
└── screens/
    ├── login_screen.dart        # Login / auth screen
    ├── main_shell.dart          # Bottom nav shell
    ├── dashboard_screen.dart    # Main dashboard
    ├── patients_screen.dart     # Patient list
    ├── patient_detail_screen.dart  # Patient tabs view
    └── assistant_screen.dart    # AI chat interface
```

---

## 🎨 Design System

| Token | Value | Usage |
|-------|-------|-------|
| `navyBg` | `#0A1628` | App background |
| `navyCard` | `#0F2044` | Card surfaces |
| `cyan` | `#00D4FF` | Primary accent |
| `danger` | `#EF4444` | Critical alerts |
| `warning` | `#F59E0B` | Warning states |
| `success` | `#22C55E` | Normal / stable |

**Font:** Google Fonts — Sora

---

## 📦 Dependencies

```yaml
fl_chart: ^0.68.0          # Line charts for lab trends
google_fonts: ^6.2.1       # Sora font family
provider: ^6.1.2           # State management
percent_indicator: ^4.2.3  # Progress indicators
flutter_svg: ^2.0.10+1     # SVG rendering
intl: ^0.19.0              # Date formatting
```

---

## 🔑 Login Credentials (Demo)

```
Email:    dr.verma@hospital.com
Password: (any value)
```

Tap **Sign In** → enters the dashboard directly (mock auth).

---

## ✨ Features

- 🌙 **Dark Navy Theme** — Clinical, professional look
- 📊 **Live Charts** — fl_chart powered trend lines
- 🗂 **4-Tab Patient View** — Vitals, Labs, Medications, Body Map
- 🫀 **Body Organ Visualization** — Custom painted organ health map
- 🤖 **AI Chat Assistant** — Keyword-based clinical responses
- 🔍 **Search + Filter** — Patient list with status filters
- ⚠️ **Drug Interaction Alerts** — Visual warning system
- 💊 **60-Second AI Brief** — Bottom sheet pre-consultation summary

---

## 🛠 Troubleshooting

**`flutter pub get` fails:**
```bash
flutter clean
flutter pub get
```

**Fonts not loading:**
```bash
flutter pub cache repair
flutter pub get
```

**iOS build fails:**
```bash
cd ios && pod install && cd ..
flutter run
```

**Android SDK not found:**
- Open Android Studio → SDK Manager → Install Android SDK 33+
- Set `ANDROID_HOME` environment variable

---

## 📋 Next Steps (Backend Integration)

To connect to a real backend, replace mock data in `lib/models/mock_data.dart` with:

```dart
// HTTP service example
import 'package:http/http.dart' as http;

Future<List<Patient>> fetchPatients() async {
  final res = await http.get(Uri.parse('https://your-api.com/patients'));
  // parse JSON → Patient objects
}
```

---

Built with ❤️ using Flutter + ClinSight AI design system
