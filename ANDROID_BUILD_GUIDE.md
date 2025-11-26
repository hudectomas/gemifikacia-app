# 📱 Android APK Build Guide

## 🚀 RÝCHLY ŠTART

### Option 1: Debug APK (pre testovanie)

```bash
cd pas_flutter
BUILD_APK.bat
```

**Výsledok:** `build\app\outputs\flutter-apk\app-debug.apk`

---

### Option 2: Release APK (produkčná verzia)

```bash
cd pas_flutter
BUILD_APK_RELEASE.bat
```

**Výsledok:** `build\app\outputs\flutter-apk\app-release.apk`

---

## 📋 KROKY

### 1. Príprava

**Skontroluj, že máš:**
- ✅ Flutter SDK nainštalované
- ✅ Android SDK nainštalované
- ✅ Internet pripojenie

**Test:**
```bash
flutter doctor
```

Všetko by malo byť zelené ✅ (okrem iOS ak nie si na Macu)

---

### 2. Build APK

#### A) Debug APK (rýchle, na testovanie)

**Ručne:**
```bash
cd pas_flutter
flutter clean
flutter pub get
flutter build apk --debug
```

**Alebo skripty:**
```bash
BUILD_APK.bat
```

**Výsledok:**
- Súbor: `build\app\outputs\flutter-apk\app-debug.apk`
- Veľkosť: ~40-60 MB
- Rýchlosť: Rýchly build (5-10 min)
- Použitie: Testovanie

#### B) Release APK (optimalizovaný, menší)

**Ručne:**
```bash
cd pas_flutter
flutter clean
flutter pub get
flutter build apk --release
```

**Alebo skripty:**
```bash
BUILD_APK_RELEASE.bat
```

**Výsledok:**
- Súbor: `build\app\outputs\flutter-apk\app-release.apk`
- Veľkosť: ~20-30 MB (menší!)
- Rýchlosť: Pomalší build (10-20 min)
- Použitie: Produkcia, distribúcia

---

### 3. Nainštaluj na Android

#### Spôsob 1: USB kábel

1. Pripoj Android telefón cez USB
2. Povoľ **"USB debugging"** na telefóne:
   ```
   Nastavenia → O telefóne → Ťukni 7x na "Číslo zostavy"
   → Developer options → USB debugging ✅
   ```
3. Spusti:
   ```bash
   flutter install
   ```

#### Spôsob 2: Prenies súbor

1. Skopíruj APK na telefón:
   ```
   build\app\outputs\flutter-apk\app-debug.apk
   ```
   
2. Na telefóne:
   - Otvor **File Manager**
   - Nájdi `app-debug.apk`
   - Ťukni na súbor
   - Povoľ **"Install unknown apps"** ak treba
   - Klikni **"Install"**

#### Spôsob 3: Google Drive / Email

1. Upload APK na Google Drive / pošli emailom
2. Stiahni na telefóne
3. Nainštaluj

---

## ⚙️ NASTAVENIE APP

### Zmena názvu app:

**`android/app/src/main/AndroidManifest.xml`:**
```xml
<application
    android:label="Detský Pas"  <!-- ← Zmena tu -->
    ...>
```

### Zmena ikony app:

1. Vygeneruj ikony:
   ```bash
   flutter pub add flutter_launcher_icons
   ```

2. Pridaj do `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     image_path: "assets/icons/drozdovo.jpg"
   ```

3. Generuj:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Zmena package name:

**`android/app/build.gradle`:**
```gradle
defaultConfig {
    applicationId "sk.drozdovo.detsky_pas"  // ← Zmena tu
    ...
}
```

---

## 🔒 SIGNING (pre produkciu)

### Prečo?

Release APK musí byť **podpísaný** pre:
- ✅ Google Play Store
- ✅ Bezpečnosť
- ✅ Updates

### Krok 1: Vytvor Keystore

```bash
keytool -genkey -v -keystore drozdovo-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias drozdovo
```

**Zadaj:**
- Password: `tvoje_heslo`
- Name: `Drozdovo`
- Organization: `Drozdovo Resort`
- City, Country, atď.

**Výsledok:** `drozdovo-key.jks` súbor

⚠️ **IMPORTANT:** Zálohuj tento súbor a heslo!

### Krok 2: Nakonfiguruj signing

**Vytvor súbor:** `android/key.properties`
```properties
storePassword=tvoje_heslo
keyPassword=tvoje_heslo
keyAlias=drozdovo
storeFile=C:/path/to/drozdovo-key.jks
```

⚠️ **IMPORTANT:** Nepridávaj `key.properties` do GIT!

### Krok 3: Upraviť build.gradle

**`android/app/build.gradle`:**

Pred `android {` pridaj:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

V `android { ... }` pridaj:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### Krok 4: Build signed APK

```bash
flutter build apk --release
```

Teraz je APK **podpísané** a ready pre Play Store!

---

## 📦 BUILD VARIANTS

### 1. Debug APK (testovanie)
```bash
flutter build apk --debug
```
- Veľký súbor
- Obsahuje debug info
- Rýchly build

### 2. Release APK (produkcia)
```bash
flutter build apk --release
```
- Menší súbor
- Optimalizovaný
- Pomalší build

### 3. Split APKs (podľa CPU)
```bash
flutter build apk --split-per-abi
```
Vytvorí 3 APK:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (Intel)

**Výhoda:** Každý APK je menší (~15 MB)

### 4. App Bundle (pre Play Store)
```bash
flutter build appbundle --release
```
Vytvorí: `app-release.aab`

**Výhoda:** Google Play optimalizuje pre každé zariadenie

---

## 🔧 TROUBLESHOOTING

### Chyba: "Android SDK not found"

**Fix:**
```bash
# Set ANDROID_HOME environment variable
set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
```

Alebo nainštaluj:
```bash
flutter doctor --android-licenses
```

### Chyba: "Gradle build failed"

**Fix 1:** Zmaž cache
```bash
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
```

**Fix 2:** Update Gradle
`android/gradle/wrapper/gradle-wrapper.properties`:
```
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

### Chyba: "Signing error"

**Fix:** Skontroluj `key.properties`:
- Správne heslo?
- Správna cesta k `.jks`?
- Súbor existuje?

### Chyba: "Insufficient storage"

**Fix:** Zmaž staré buildy
```bash
flutter clean
```

---

## 📊 BUILD TIMES

**Prvý build:**
- Debug: 10-15 min
- Release: 15-25 min

**Ďalšie buildy:**
- Debug: 2-5 min
- Release: 5-10 min

**Zrýchlenie:**
```bash
flutter build apk --release --no-tree-shake-icons
```

---

## 📱 TESTOVANIE APK

### Na vlastnom telefóne:

1. Nainštaluj APK
2. Otvor app
3. Test všetky features:
   - ✅ Login/Register
   - ✅ Môj QR Kód
   - ✅ Úlohy
   - ✅ Pečiatky
   - ✅ Rebríček
   - ✅ Season selector

### Na inom telefóne:

1. Pošli APK kamarátovi
2. Nech otestuje
3. Feedback

---

## 🚀 DISTRIBÚCIA

### Option 1: Direct APK

**Výhody:**
- ✅ Žiadna registrácia
- ✅ Rýchle
- ✅ Testovanie

**Nevýhody:**
- ❌ Ručné updaty
- ❌ Žiadne štatistiky

**Použitie:**
- Internal testing
- Beta testers
- Klienti (Drozdovo staff)

### Option 2: Google Play Store

**Výhody:**
- ✅ Automatické updaty
- ✅ Štatistiky
- ✅ Reviews
- ✅ Dosah

**Nevýhody:**
- ❌ $25 registračný poplatok
- ❌ Review process (1-3 dni)
- ❌ Musí spĺňať Google policies

**Kroky:**
1. Vytvor [Google Play Console](https://play.google.com/console) účet
2. Zaplať $25 (jednorazovo)
3. Vytvor app listing
4. Upload `app-release.aab`
5. Čakaj na review
6. Publish!

### Option 3: Firebase App Distribution

**Výhody:**
- ✅ Free
- ✅ Easy distribution
- ✅ Testers management
- ✅ Analytics

**Nevýhody:**
- ❌ Nie je public store

**Kroky:**
1. Setup Firebase project
2. Add testers (emails)
3. Upload APK
4. Testers dostanú link

---

## 📋 CHECKLIST PRE PRODUKCIU

Pred release do Play Store:

- [ ] App name správny
- [ ] Icon správna
- [ ] Package name unikátny
- [ ] Version code/name nastavené
- [ ] Signing nakonfigurované
- [ ] Backend API produkčná URL
- [ ] Testované na viacerých telefónoch
- [ ] Všetky features fungujú
- [ ] Žiadne crash bugs
- [ ] Privacy policy vytvorená
- [ ] Screenshots pre Play Store
- [ ] App description napísaný

---

## 🎯 ODPORÚČANIE PRE DROZDOVO

### Fáza 1: Internal Testing (NOW)
```bash
flutter build apk --debug
```
- Zdieľaj s team
- Test na telefónoch zamestnancov
- Zbieraj feedback

### Fáza 2: Beta Testing
```bash
flutter build apk --release
```
- Zdieľaj s vybraným rodičmi/deťmi
- Test v reálnom prostredí
- Fix bugs

### Fáza 3: Production
```bash
flutter build appbundle --release
```
- Upload na Play Store
- Public release
- Marketing

---

## 💡 TIPS

### Menší APK:
```bash
flutter build apk --release --split-per-abi
```

### Rýchlejší build:
```bash
flutter build apk --release --no-tree-shake-icons
```

### Debug na telefóne:
```bash
flutter run --release
```

### Skontroluj veľkosť:
```bash
flutter build apk --analyze-size
```

---

## 📞 SUPPORT

**Ak máš problém:**

1. Skontroluj `flutter doctor`
2. Zmaž cache: `flutter clean`
3. Update Flutter: `flutter upgrade`
4. Google error message
5. Ask me! 😊

---

**READY TO BUILD! 🚀**

Spusti `BUILD_APK.bat` a o 10 minút máš APK! 📱

---

Created: ${new Date().toISOString().substring(0, 10)}  
Author: AI Assistant







