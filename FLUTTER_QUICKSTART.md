# 🚀 Flutter Quick Start - Detský Pas

## ⚡ Spustite za 3 minúty!

### Krok 1: Overte Flutter instaláciu (30 sekúnd)

```bash
flutter doctor
```

Mali by ste vidieť:
```
✓ Flutter (Channel stable, 3.x.x)
✓ Android toolchain
✓ VS Code / Android Studio
```

---

### Krok 2: Nainštalujte závislosti (1 minúta)

```bash
cd pas_flutter
flutter pub get
```

Počkajte kým sa stiahnu všetky balíčky...

---

### Krok 3: Nastavte API URL (30 sekúnd)

Otvorte `lib/config/constants.dart` a upravte:

**Pre Windows/Mac:**
```dart
static const String apiBaseUrl = 'http://127.0.0.1:8000/api';
```

**Pre Android Emulator:**
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
```

**Pre fyzické zariadenie:**
```dart
static const String apiBaseUrl = 'http://192.168.X.X:8000/api';  // Vaša IP!
```

Ako zistiť IP:
```cmd
ipconfig  # Windows
ifconfig  # Mac/Linux
```

---

### Krok 4: Uistite sa že backend beží (10 sekúnd)

V druhom termináli:
```bash
cd server
php artisan serve
```

Mali by ste vidieť:
```
Starting Laravel development server: http://127.0.0.1:8000
```

Otvorte v prehliadači: http://127.0.0.1:8000/api/test

---

### Krok 5: Spustite Flutter app! (1 minúta)

```bash
# V priečinku pas_flutter:

# Android
flutter run

# iOS (len na Macu)
flutter run -d ios

# Chrome (pre testovanie)
flutter run -d chrome
```

---

## 🎉 HOTOVO!

Aplikácia by sa mala spustiť a vidíte krásny splash screen s animáciami!

### Prihlasovacie údaje:

**Dieťa:**
```
Email: child@example.com
Heslo: password
```

**Zamestnanec:**
```
Email: employee@example.com
Heslo: password
```

**Admin:**
```
Email: admin@example.com
Heslo: password
```

---

## 🔧 Časté Problémy

### "Target of URI doesn't exist"

**Riešenie:**
```bash
flutter clean
flutter pub get
flutter run
```

### "MissingPluginException"

**Riešenie:**
```bash
flutter clean
flutter pub get
# Reštartujte emulátor/zariadenie
flutter run
```

### Aplikácia sa nepripojí k API

**Skontrolujte:**
1. ✅ Backend beží? (`php artisan serve`)
2. ✅ API URL je správne? (`lib/config/constants.dart`)
3. ✅ Pre Android Emulator používate `10.0.2.2`?
4. ✅ Firewall neblokuje port 8000?

**Test v prehliadači:**
```
http://127.0.0.1:8000/api/test
```

---

## 📱 Platformy

### Android:

```bash
# Debug
flutter run

# Release APK
flutter build apk --release

# APK bude v: build/app/outputs/flutter-apk/app-release.apk
```

### iOS (vyžaduje Mac):

```bash
# Debug
flutter run -d ios

# Release
flutter build ios --release
```

### Web:

```bash
# Debug
flutter run -d chrome

# Build
flutter build web
```

---

## 🎨 Dizajn Highlights

### Animácie:
- ✅ Fade in/out
- ✅ Slide animations
- ✅ Scale effects
- ✅ Shimmer loading
- ✅ Confetti celebrations
- ✅ Hero transitions

### UI Features:
- ✅ Gradienty na každej karte
- ✅ Tiene a elevácie
- ✅ Rounded corners všade
- ✅ Smooth scrolling
- ✅ Pull-to-refresh
- ✅ Bottom sheets
- ✅ Snackbars s emojis

### Farby:
- 🟣 Purple gradient - Primary
- 🌸 Pink gradient - Secondary  
- 🌟 Gold gradient - Points
- 🟢 Green - Success
- 🔴 Red - Error/Admin
- 🔵 Blue - Info/Employee

---

## 🔍 Debug Mode

### Zapnite verbose logy:

```bash
flutter run --verbose
```

### Pozrite device logy:

**Android:**
```bash
flutter logs
```

**iOS:**
```bash
flutter logs
```

### Debug v kóde:

```dart
import 'dart:developer' as developer;

developer.log('Debug message here');
developer.log('User: ${user.name}');
```

---

## 🌈 Screenshots (Coming Soon)

1. Splash Screen - Animovaný splash
2. Login - Gradient background
3. Child Home - Farebný dashboard
4. Tasks - Kategorizované úlohy
5. Stamps - História s bodmi
6. Employee - Profesionálny UI
7. Admin - Červený panel

---

## 🚀 Hot Reload

Flutter má **NAJLEPŠÍ** hot reload!

Počas vývoja:
- **r** v termináli = Hot reload
- **R** v termináli = Hot restart
- **q** = Quit

Alebo vo VS Code:
- **Ctrl + S** = Auto hot reload
- Zmeny sú viditeľné za sekundu!

---

## 💡 Tipy

1. **Používajte VS Code s Flutter extension**
   - Syntax highlighting
   - Auto-complete
   - Widget inspector

2. **Flutter DevTools**
   ```bash
   flutter run
   # Potom otvorte DevTools URL z outputu
   ```

3. **Emulator shortcuts:**
   - Android: `flutter emulators --launch <id>`
   - iOS: `open -a Simulator`

---

## ✅ Kontrolný zoznam

Pred spustením:
- [ ] Flutter je nainštalovaný (`flutter doctor`)
- [ ] Backend beží (`php artisan serve`)
- [ ] API URL je nastavené v `constants.dart`
- [ ] Závislosti sú nainštalované (`flutter pub get`)
- [ ] Emulátor/zariadenie je pripojené (`flutter devices`)

---

## 🆘 Pomoc

**Chyby pri buildu:**
```bash
flutter clean
flutter pub get
flutter run
```

**API connection issues:**
- Pozrite `lib/services/api_service.dart` - debug logy
- Test API v prehliadači
- Skontrolujte firewall

**UI problémy:**
- Hot reload (r)
- Hot restart (R)
- Reštartujte app úplne

---

## 🎊 Hotovo!

Teraz máte krásnu, modernú Flutter aplikáciu!

**Užite si vývoj s Flutter - je to radosť!** 🦋✨

Pre viac info pozrite `README.md`







