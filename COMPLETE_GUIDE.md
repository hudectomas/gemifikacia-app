# 🎯 Kompletný Guide - Flutter Detský Pas

## 🚀 Všetko čo potrebujete vedieť

---

## 📋 Obsah

1. [Rýchly Štart](#rýchly-štart)
2. [Dizajn Features](#dizajn-features)
3. [Architektúra](#architektúra)
4. [API Integrácia](#api-integrácia)
5. [Troubleshooting](#troubleshooting)

---

## ⚡ Rýchly Štart

### Prerequisites:
```bash
✓ Flutter SDK 3.9.2+
✓ Dart 3.0+
✓ Android Studio / VS Code
✓ Android Emulator / iOS Simulator
✓ Backend beží na http://127.0.0.1:8000
```

### 3-krokový setup:

```bash
# 1. Závislosti
cd pas_flutter
flutter pub get

# 2. Nastavte API (upravte lib/config/constants.dart)
# apiBaseUrl = 'http://127.0.0.1:8000/api' (alebo 10.0.2.2 pre Android)

# 3. Spustite!
flutter run
```

**HOTOVO!** Aplikácia beží! 🎉

---

## 🎨 Dizajn Features

### 1. Gradienty & Farby

**Každá sekcia má vlastný gradient:**

```dart
// Login - Purple dream
gradient: LinearGradient(
  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
)

// Register - Pink sunset
gradient: LinearGradient(
  colors: [Color(0xFFf093fb), Color(0xFF4facfe)],
)

// Child Home - Golden hour
gradient: LinearGradient(
  colors: [Color(0xFFFEE140), Color(0xFFFA709A)],
)

// Stats Card - Orange cream
gradient: LinearGradient(
  colors: [Color(0xFFFFD89B), Color(0xFFFF9A76)],
)
```

### 2. Animácie (Flutter Animate)

**Staggered animations:**
```dart
// Karty sa objavia jedna po druhej
items.map((item) =>
  ItemCard(item)
    .animate()
    .fadeIn(delay: (index * 100).ms)
    .slideX(begin: 0.2, end: 0)
)
```

**Repeated animations:**
```dart
// Avatar má shimmer efekt
Avatar()
  .animate(onPlay: (controller) => controller.repeat())
  .shimmer(duration: 2000.ms, color: Colors.white24)
```

**Hero transitions:**
```dart
// Logo sa smooth transformuje medzi stránkami
Hero(
  tag: 'logo',
  child: LogoWidget(),
)
```

### 3. Confetti 🎊

```dart
// Pri úspechoch (napr. získanie pečiatky)
ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive,
  colors: [purple, pink, gold, green],
)

// Trigger:
_confettiController.play();
```

### 4. Shapes & Shadows

**Všetky karty:**
```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),  // Zaoblené
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ],
)
```

---

## 🏗️ Architektúra

### State Management - Provider Pattern

**Prečo Provider?**
- ✅ Jednoduchý
- ✅ Výkonný
- ✅ Odporúčaný Flutterom
- ✅ Perfektný pre túto aplikáciu

**Flow:**
```
UI Widget
  ↓ watches
Provider (ChangeNotifier)
  ↓ uses
Service (Business Logic)
  ↓ calls
API / Database
```

**Príklad:**
```dart
// 1. Widget počúva zmeny
final authProvider = context.watch<AuthProvider>();

// 2. Provider má stav
class AuthProvider with ChangeNotifier {
  User? _currentUser;
  
  Future<void> login(...) async {
    // ... logic
    notifyListeners();  // ← UI sa auto-updatne!
  }
}

// 3. Service má business logic
class AuthService {
  Future<bool> login(...) async {
    // API calls, validácie, etc.
  }
}
```

### Services Layer

**4 hlavné services:**

1. **ApiService** - HTTP komunikácia
   ```dart
   - login(), register(), logout()
   - getTasks(), getStamps()
   - Debug logging
   ```

2. **AuthService** - Autentifikácia
   ```dart
   - initialize(), login(), logout()
   - Token management
   - User state
   ```

3. **DatabaseService** - SQLite
   ```dart
   - CRUD pre users, tasks, stamps
   - Offline storage
   - Sync support
   ```

4. **SyncService** - Synchronizácia
   ```dart
   - syncAll()
   - Online detection
   - Conflict resolution
   ```

---

## 🔌 API Integrácia

### Endpoints:

**Auth:**
```dart
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
```

**Tasks:**
```dart
GET /api/tasks?active_only=true
```

**Stamps:**
```dart
GET /api/stamps?user_id=123
POST /api/stamps/give
```

### Error Handling:

```dart
try {
  final response = await http.post(...);
  
  if (response.statusCode == 200) {
    // Success
    return jsonDecode(response.body);
  } else {
    // HTTP error
    throw Exception('HTTP ${response.statusCode}');
  }
} on SocketException {
  // No internet
  return 'Žiadne internetové pripojenie';
} on TimeoutException {
  // Timeout
  return 'Server neodpovedá';
} catch (e) {
  // Other errors
  return 'Chyba: $e';
}
```

### Debug Logging:

Každý API call loguje:
```
POST /api/auth/login
Body: {"email":"...","password":"***"}
Status: 200
Response: {"success":true,...}
```

---

## 🔄 Offline Režim

### SQLite Schema:

```sql
-- Users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT,
  email TEXT,
  role TEXT,
  token TEXT
);

-- Tasks table
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY,
  title TEXT,
  description TEXT,
  points INTEGER,
  category TEXT,
  is_active INTEGER
);

-- Stamps table
CREATE TABLE user_stamps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  task_id INTEGER,
  stamped_at TEXT,
  synced INTEGER,
  UNIQUE(user_id, task_id)
);
```

### Sync Strategy:

**Pri spustení:**
1. Načítaj z local DB
2. Zobraz cached data
3. Skontroluj internet
4. Ak online → sync na pozadí

**Pri pull-to-refresh:**
1. Zobraz loading
2. Fetch z API
3. Updatni local DB
4. Updatni UI

---

## 🐛 Troubleshooting

### Aplikácia crashne pri štarte

**Riešenie:**
```bash
flutter clean
flutter pub get
flutter run
```

### "No devices found"

**Riešenie:**
```bash
# Skontrolujte devices
flutter devices

# Android emulátor
flutter emulators
flutter emulators --launch <emulator_id>

# iOS simulator (Mac only)
open -a Simulator
```

### API connection error

**Skontrolujte:**
```bash
# 1. Backend beží?
curl http://127.0.0.1:8000/api/test

# 2. API URL je správne?
# lib/config/constants.dart

# 3. Pre Android Emulator použite:
# http://10.0.2.2:8000/api (NIE localhost!)
```

### Build errors

**Kompletný reset:**
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter run
```

### Plugin errors

**Riešenie:**
```bash
flutter pub upgrade
flutter pub get
flutter run
```

---

## 🎯 Testing

### Unit tests:
```bash
flutter test
```

### Widget tests:
```bash
flutter test test/widget_test.dart
```

### Integration tests:
```bash
flutter drive
```

---

## 📦 Build & Deploy

### Development:
```bash
flutter run --debug
```

### Testing:
```bash
flutter run --profile
```

### Production:

**Android:**
```bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# AAB: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
# Otvorte Xcode a archivujte
```

---

## 🌟 Best Practices

### 1. Používajte const widgets
```dart
const Text('Hello')  // ✅
Text('Hello')        // ❌ (ak môžete const)
```

### 2. Extract widgets
```dart
// ❌ Veľké build metódy
Widget build(context) {
  return Column(
    children: [
      // 100+ riadkov...
    ],
  );
}

// ✅ Rozdelené na menšie widgety
Widget build(context) {
  return Column(
    children: [
      _buildHeader(),
      _buildContent(),
      _buildFooter(),
    ],
  );
}
```

### 3. Dispose controllers
```dart
@override
void dispose() {
  _controller.dispose();
  _scrollController.dispose();
  super.dispose();
}
```

---

## 🎓 Learning Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)
- [Provider](https://pub.dev/packages/provider)
- [Google Fonts](https://pub.dev/packages/google_fonts)

---

## 💬 Support

**Dokumentácia:**
- `README.md` - Základný prehľad
- `FLUTTER_QUICKSTART.md` - Rýchly štart
- `FLUTTER_FEATURES.md` - Detaily features

**Issues?**
- Skontrolujte console output
- `flutter logs` pre device logy
- Create GitHub issue

---

**Enjoy building with Flutter! 🦋✨**

Happy coding! 🚀








