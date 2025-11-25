# 🎨 Detský Pas - Flutter App

Krásna, moderná mobilná aplikácia pre zbieranie pečiatok s gamifikáciou.

## ✨ Vlastnosti

### 🎮 Pre Deti:
- 🌈 **Krásny moderný dizajn** s živými farbami a gradientmi
- ✨ **Plynulé animácie** - každý pohyb je potešením pre oči
- 🎊 **Konfety pri úspechoch** - oslavuj každý dosiahnutý cieľ!
- 📊 **Interaktívne grafy** pokroku
- 🏆 **Motivačné prvky** - emoji, odznaky, body
- 📱 **Intuitívne ovládanie** - veľké, ľahko klikateľné tlačidlá

### 👔 Pre Zamestnancov:
- 📷 QR skenovanie (pripravené)
- ✏️ Manuálne pridávanie pečiatok
- 🔄 Offline režim
- 📊 Prehľadný, funkčný dizajn

### 🛡️ Pre Adminov:
- 👥 Správa používateľov
- 📋 Správa úloh
- 📊 Štatistiky
- ⚙️ Kompletná kontrola

## 🚀 Inštalácia

### 1. Nainštalujte závislosti

```bash
cd pas_flutter
flutter pub get
```

### 2. Nastavte API URL

Upravte `lib/config/constants.dart`:

```dart
// Pre rôzne platformy:
static const String apiBaseUrl = 'http://127.0.0.1:8000/api';  // Windows/Mac
// static const String apiBaseUrl = 'http://10.0.2.2:8000/api';  // Android Emulator
// static const String apiBaseUrl = 'http://YOUR_IP:8000/api';   // Physical Device
```

### 3. Spustite aplikáciu

```bash
# Android
flutter run

# iOS (na Macu)
flutter run -d ios

# Web (pre testovanie)
flutter run -d chrome
```

## 📦 Použité Balíčky

### UI & Design:
- `google_fonts` - Krásne fonty
- `flutter_animate` - Jednoduché, výkonné animácie
- `confetti` - Konfety pri úspechoch
- `shimmer` - Shimmer efekty
- `lottie` - Komplexné animácie

### Funkčnosť:
- `provider` - State management
- `dio` / `http` - API komunikácia
- `sqflite` - Lokálna databáza
- `shared_preferences` - Ukladanie nastavení
- `mobile_scanner` - QR skenovanie
- `connectivity_plus` - Detekcia internetu

## 🎨 Dizajn

### Farby:
- **Primary**: Vibrant Purple (#6C63FF)
- **Secondary**: Pink (#FF6B9D)
- **Accent**: Golden (#FFC107)
- **Success**: Green (#4CAF50)

### Gradienty:
- Každá karta má vlastný gradient
- Hladké prechody
- Tiene a elevácie

### Animácie:
- Fade in/out
- Slide animations
- Scale effects
- Shimmer efekty
- Konfety pri úspechoch

## 📱 Screens

1. **SplashScreen** - Animovaný splash s logom
2. **LoginScreen** - Moderné prihlásenie s gradientom
3. **RegisterScreen** - Registrácia s validáciou
4. **ChildHomeScreen** - Hlavná stránka s prehľadom a quick actions
5. **TasksScreen** - Zoznam úloh s vyhľadávaním
6. **StampsScreen** - História pečiatok
7. **EmployeeHomeScreen** - Interface pre zamestnancov
8. **AdminHomeScreen** - Admin panel
9. **SettingsScreen** - Nastavenia a odhlásenie

## 🔄 Offline Režim

- ✅ SQLite lokálna databáza
- ✅ Automatická synchronizácia
- ✅ Funkčnosť bez internetu
- ✅ Detekcia online/offline stavu

## 🎯 Použitie

### Prvé spustenie:

1. Uistite sa že backend beží (`cd server && php artisan serve`)
2. Spustite Flutter app (`flutter run`)
3. Prihlás te sa:
   - **Dieťa**: child@example.com / password
   - **Zamestnanec**: employee@example.com / password
   - **Admin**: admin@example.com / password

### Features:

- **Pull-to-refresh** na hlavnej stránke
- **Tapni na úlohu** pre detail
- **Swipe** pre navigáciu
- **Automatické** načítanie dát

## 🔧 Konfigurácia

### Android Permissions

V `android/app/src/main/AndroidManifest.xml` pridajte:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS Permissions

V `ios/Runner/Info.plist` pridajte:

```xml
<key>NSCameraUsageDescription</key>
<string>Potrebujeme prístup ku kamere na skenovanie QR kódov</string>
```

## 🎨 Prispôsobenie

### Zmena farieb:

Upravte `lib/config/theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6C63FF);
static const Color secondaryColor = Color(0xFFFF6B9D);
```

### Pridanie animácií:

```dart
import 'package:flutter_animate/flutter_animate.dart';

Widget.animate()
  .fadeIn(duration: 600.ms)
  .scale(delay: 200.ms)
  .slideY(begin: 0.2, end: 0);
```

## 🐛 Debug

### Zapnite debug výpisy:

V `lib/services/api_service.dart` sú už zabudované debug logy:
```dart
import 'dart:developer' as developer;
developer.log('Message here');
```

### Spustite v debug režime:
```bash
flutter run --debug
```

### Pozrite logy:
```bash
flutter logs
```

## 🚀 Build pre produkciu

### Android APK:
```bash
flutter build apk --release
```

### iOS:
```bash
flutter build ios --release
```

### Web:
```bash
flutter build web --release
```

## 📄 Licencia

MIT License

---

**Vytvorené s ❤️ a Flutter!** 🦋✨
