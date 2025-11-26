# 🔧 Inštalácia Flutter na Windows

## ⚡ Quick Install (10 minút)

### Krok 1: Stiahnutie Flutter (2 min)

1. Otvorte: https://docs.flutter.dev/get-started/install/windows
2. Kliknite na **"Download Flutter SDK"**
3. Stiahne sa ZIP súbor (~1GB)

**ALEBO použite priamy link:**
```
https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip
```

---

### Krok 2: Rozbaľte Flutter (1 min)

1. Rozbaľte ZIP do `C:\src\flutter`
   (alebo ľubovoľný priečinok BEZ medzier v názve!)

Výsledok:
```
C:\src\flutter\
  ├── bin\
  ├── packages\
  └── ...
```

---

### Krok 3: Pridajte do PATH (2 min)

**Windows 10/11:**

1. Stlačte **Win + X** → **"System"**
2. Kliknite **"Advanced system settings"** vpravo
3. Kliknite **"Environment Variables"**
4. V **"User variables"** nájdite **"Path"**
5. Kliknite **"Edit"**
6. Kliknite **"New"**
7. Zadajte: `C:\src\flutter\bin` (alebo kde ste rozbalili)
8. Kliknite **OK**, **OK**, **OK**

**ALEBO cez PowerShell (Admin):**

```powershell
[System.Environment]::SetEnvironmentVariable(
  'Path',
  [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';C:\src\flutter\bin',
  'User'
)
```

---

### Krok 4: Overenie (1 min)

**Zatvorte všetky PowerShell okná a otvorte NOVÉ!**

Potom:
```cmd
flutter --version
```

Mali by ste vidieť:
```
Flutter 3.24.5 • channel stable
```

✅ **Flutter je nainštalovaný!**

---

### Krok 5: Flutter Doctor (2 min)

```cmd
flutter doctor
```

Uvidíte:
```
[✓] Flutter
[✗] Android toolchain    ← Normálne ak nemáte Android Studio
[✗] Chrome               ← Voliteľné
[✓] VS Code
```

**Pre Android development potrebujete Android Studio.**

---

### Krok 6: Spustite aplikáciu! (2 min)

```cmd
cd pas_flutter
flutter pub get
flutter run
```

Ak máte Android emulátor:
```
[1]: Android SDK (emulator)
Select device: 1
```

Ak nemáte emulátor:
```
[2]: Chrome (web)
Select device: 2
```

**HOTOVO!** 🎉

---

## 🔧 Android Studio (voliteľné, pre Android development)

### Ak chcete Android app:

1. Stiahnte Android Studio: https://developer.android.com/studio
2. Nainštalujte
3. Otvorte Android Studio
4. Tools → SDK Manager → Install SDK
5. Tools → AVD Manager → Create Virtual Device
6. Vytvorte emulátor

Potom:
```cmd
flutter doctor --android-licenses
flutter doctor
```

Všetko by malo byť ✓

---

## 🌐 Najrýchlejší spôsob (Chrome - 1 minúta!)

Ak chcete len rýchlo otestovať:

```cmd
flutter run -d chrome
```

Aplikácia sa otvorí v Chrome! 🌐

**Poznámka:** Niektoré features nebudú fungovať (kamera, offline DB),
ale uvidíte dizajn a animácie!

---

## ✅ Po inštalácii:

```cmd
cd pas_flutter
flutter pub get
flutter run
```

Vyberte zariadenie:
```
[1] Android emulator
[2] Chrome (web)
[3] Windows (desktop) - ak Windows app
```

---

## 🆘 Problémy?

### "flutter not recognized" po pridaní do PATH

**Riešenie:**
- Zatvorte **VŠETKY** PowerShell/CMD okná
- Otvorte **NOVÉ** okno
- Skúste znova

### Android emulátor nejde spustiť

**Použite Chrome:**
```cmd
flutter run -d chrome
```

### VS Code

**Nainštalujte extensions:**
1. Flutter
2. Dart

Potom:
```
F5 - Run & Debug
```

---

**Po inštalácii sa vráťte do `pas_flutter/` a spustite `flutter run`!** 🚀







