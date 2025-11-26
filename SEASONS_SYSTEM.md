# 🗓️ Systém Sezón/Rokov - Kompletná Implementácia

## ✅ ČO BOLO VYTVORENÉ

Kompletný systém pre správu viacerých rokov/sezón s históriou!

---

## 🏗️ BACKEND (Laravel)

### Databáza:

**Nová tabuľka: `seasons`**
```sql
- id
- name (napr. "Zima 2024/2025")
- year (2024)
- start_date (2024-12-01)
- end_date (2025-03-31)
- is_active (boolean) - len 1 môže byť aktívna
- description (voliteľné)
- created_at, updated_at
```

**Upravené tabuľky:**
```sql
tasks:
  + season_id (foreign key)
  
user_stamps:
  + season_id (foreign key)
```

### Model: `Season.php`

**Metódy:**
```php
✅ tasks() - Úlohy v sezóne
✅ stamps() - Pečiatky v sezóne
✅ scopeActive() - Aktívna sezóna
✅ scopeByYear() - Filter podľa roku
✅ getCurrentSeason() - Vráti aktívnu sezónu
✅ activate() - Aktivuje sezónu (deaktivuje ostatné)
```

### Controller: `SeasonController.php`

**API Endpoints:**
```php
✅ GET  /api/seasons          - Všetky sezóny
✅ GET  /api/seasons/active   - Aktívna sezóna
✅ POST /api/seasons          - Vytvoriť sezónu (admin)
✅ POST /api/seasons/{id}/activate - Aktivovať (admin)
✅ GET  /api/seasons/{id}/statistics - Štatistiky
```

### Seeder:

**Predvytvorené sezóny:**
```php
1. Zima 2024/2025 (AKTÍVNA)
   - 01.12.2024 - 31.03.2025
   - Všetky úlohy patrianúcej tejto sezóne

2. Zima 2023/2024 (Historická)
   - 01.12.2023 - 31.03.2024
   - Pre testovanie histórie
```

---

## 📱 FRONTEND (Flutter)

### Model: `season.dart`

```dart
class Season {
  final int id;
  final String name;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? description;
}
```

### Widget: `SeasonSelector`

**Features:**
- ✅ Dropdown-style selector
- ✅ Zobrazuje aktuálnu sezónu
- ✅ Bottom sheet s všetkými sezónami
- ✅ "AKTÍVNA" badge pre aktívnu sezónu
- ✅ Callback pri zmene sezóny
- ✅ Krásne animácie

**Použitie:**
```dart
SeasonSelector(
  onSeasonChanged: (season) {
    // Reload data for selected season
  },
)
```

### Screen: `SeasonManagementScreen` (Admin)

**Features:**
- ✅ Zoznam všetkých sezón
- ✅ **Vytvor novú sezónu:**
  - Názov (text)
  - Rok (number)
  - Dátum začiatku (date picker)
  - Dátum konca (date picker)
  - Popis (optional)
- ✅ **Aktivovať sezónu** (button)
  - Deaktivuje ostatné
  - Nastaví ako aktuálnu
- ✅ Vizuálne odlíšenie aktívnej (zelený border)
- ✅ FAB pre quick add

---

## 🎯 AKO TO FUNGUJE

### 1. Koncept:

**Jedna aktívna sezóna:**
- Všetky nové úlohy sa vytvárajú pre aktívnu sezónu
- Všetky nové pečiatky patria aktívnej sezóne
- Používatelia vidia len úlohy aktívnej sezóny (default)

**História:**
- Všetky staré sezóny zostávajú v databáze
- Môžete si pozrieť staré dáta
- Filter podľa sezóny

### 2. Flow:

**Na začiatku roka:**
```
Admin:
1. Vytvorí novú sezónu (napr. "Zima 2025/2026")
2. Aktivuje ju (automaticky deaktivuje staré)
3. Vytvorí nové úlohy pre túto sezónu

Výsledok:
- Stará sezóna → archived
- Nová sezóna → aktívna
- Deti začínajú s 0 pečiatkami v novej sezóne!
```

**Počas sezóny:**
```
- Všetky operácie sa týkajú aktívnej sezóny
- Úlohy sú pre aktuálnu sezónu
- Pečiatky sa zapisujú do aktívnej sezóny
```

**Koniec sezóny:**
```
- História zostáva zachovaná
- Môžete si pozrieť staré dáta cez season selector
- Vytvorte novú sezónu pre budúci rok
```

### 3. Zobrazenie dát:

**Default (aktuálna sezóna):**
```dart
GET /api/tasks
// Automaticky vráti úlohy aktívnej sezóny
```

**Špecifická sezóna:**
```dart
GET /api/tasks?season_id=2
// Vráti úlohy sezóny s ID=2
```

**Child môže:**
- Vidieť aktuálnu sezónu (default)
- Vybrať starú sezónu (season selector)
- Pozrieť si históriu svojich pečiatok

---

## 🎨 UI IMPLEMENTÁCIA

### Child Home Screen:

**V headeri (hneď pod AppBar):**
```
┌─────────────────────────┐
│ 📅 Zima 2024/2025  ▼   │ ← Season Selector
├─────────────────────────┤
│ 👤 Avatar + Meno        │
│ ⭐ 150 bodov            │
└─────────────────────────┘
```

**Klik na season selector:**
```
Bottom sheet:
┌─────────────────────────┐
│  Vyber Sezónu           │
├─────────────────────────┤
│ ✅ Zima 2024/2025 AKTÍVNA│
│ ○  Zima 2023/2024       │
│ ○  Zima 2022/2023       │
└─────────────────────────┘
```

### Admin Dashboard:

**Nová karta (5 total now):**
```
┌────────┬────────┐
│ Úlohy  │ Users  │
├────────┼────────┤
│Sezóny📅│Rebríček│
├────────┼────────┤
│ Skenovať       │
└────────────────┘
```

### Season Management Screen:

```
┌────────────────────────────────┐
│ Správa Sezón           │ + │
├────────────────────────────────┤
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━┓   │ ← Zelený border
│ ┃ Zima 2024/2025  AKTÍVNA ┃   │
│ ┃ 01.12.2024 - 31.03.2025 ┃   │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                │
│ ┌──────────────────────────┐   │
│ │ Zima 2023/2024          │   │
│ │ 01.12.2023 - 31.03.2024 │   │
│ │              [Aktivovať] │   │
│ └──────────────────────────┘   │
└────────────────────────────────┘
```

---

## 🔧 POUŽITIE

### Admin - Vytvorenie novej sezóny:

1. Login ako admin
2. Klikni "Sezóny"
3. Klikni + (FAB)
4. Vyplň form:
   ```
   Názov: Zima 2025/2026
   Rok: 2025
   Začiatok: 01.12.2025
   Koniec: 31.03.2026
   Popis: Zimná sezóna
   ```
5. Klikni "Vytvoriť"
6. → Nová sezóna vytvorená!
7. Klikni "Aktivovať"
8. → Nová sezóna je teraz aktívna!

### Admin - Vytvorenie úloh pre novú sezónu:

1. Po aktivácii novej sezóny
2. Prejdi do "Úlohy"
3. Vytvor úlohy (automaticky sa priradia k aktívnej sezóne)
4. Deti začínajú s 0 pečiatkami!

### Dieťa - Zobrazenie histórie:

1. Login ako child
2. V dashboarde klikni na "📅 Zima 2024/2025"
3. Vyber "Zima 2023/2024"
4. → Vidíš úlohy a pečiatky z minulej sezóny!

---

## 📊 PRÍKLADY POUŽITIA

### Lyžiarske stredisko (reálny scenár):

**September 2024:**
```
Admin vytvorí:
- Sezóna "Zima 2024/2025"
- Start: 01.12.2024
- End: 31.03.2025
- Aktivuje ju
- Vytvorí 10-15 úloh
```

**December 2024 - Marec 2025:**
```
- Deti zbierajú pečiatky
- Pečiatky sa zapisujú do sezóny 2024/2025
- Rebríček ukazuje tento rok
```

**Apríl 2025:**
```
- Sezóna končí
- Dáta zostávajú zachované
- Admin môže exportovať štatistiky
```

**September 2025:**
```
Admin vytvorí:
- Nová sezóna "Zima 2025/2026"
- Aktivuje ju
- Vytvorí nové úlohy (alebo skopíruje staré)

Deti:
- Začínajú s 0 pečiatkami v novej sezóne
- Môžu si pozrieť históriu (predošlé roky)
```

---

## 🎨 UI FEATURES

### Season Selector Widget:

**Výzor:**
```
┌─────────────────────┐
│ 📅 Zima 2024/2025 ▼ │ ← Klikateľné
└─────────────────────┘
```

**Vlastnosti:**
- White background s opacity
- Calendar icon
- Dropdown arrow
- Smooth animations
- Bottom sheet picker

**Kde je umiestnené:**
- ✅ Child Home (header)
- Môže byť pridané aj do:
  - Tasks screen
  - Stamps screen
  - Admin screens

---

## 📈 ŠTATISTIKY PODĽA SEZÓNY

### Backend endpoint:

```php
GET /api/seasons/{id}/statistics
```

**Vracia:**
```json
{
  "success": true,
  "statistics": {
    "season": { /* season data */ },
    "total_tasks": 10,
    "total_stamps": 156,
    "total_users": 23
  }
}
```

### Future UI (môže byť pridané):

**Statistics Screen:**
```
┌──────────────────────────┐
│  Sezóna: Zima 2024/2025  │
├──────────────────────────┤
│  📋 Úlohy:        10     │
│  ⭐ Pečiatky:     156    │
│  👥 Deti:         23     │
│  📊 Priemer:      6.8    │
└──────────────────────────┘
```

---

## 🔄 MIGRÁCIA DÁTFROM

### Pri upgrade z verzie bez sezón:

**Backend upravil:**
```php
// season_id je nullable
// Staré dáta majú season_id = null
// Funguje aj bez sezón!

// Pri prvom seed sa vytvorí prvá sezóna
// Staré dáta môžu byť migrované:
UPDATE tasks SET season_id = 1 WHERE season_id IS NULL;
UPDATE user_stamps SET season_id = 1 WHERE season_id IS NULL;
```

---

## 🎯 BENEFITS

### 1. História:
```
✅ Každý rok je samostatný
✅ Dáta sa neprepíšu
✅ Môžete porovnávať roky
✅ Export štatistík po roku
```

### 2. Fair Play:
```
✅ Každý začína s 0 každý rok
✅ Žiadne nespr avné výhody
✅ Fresh start každú sezónu
```

### 3. Flexibilita:
```
✅ Rôzne úlohy každý rok
✅ Upraviť bodovanie
✅ Nové kategórie
✅ Inovácie každú sezónu
```

### 4. Analytics:
```
✅ Porovnanie rokov
✅ Trendy v účasti
✅ Najpopulárnejšie úlohy
✅ ROI gamifikácie
```

---

## 🚀 SPUSTENIE S NOVÝM SYSTÉMOM

### 1. Reset databázy (zahŕňa sezóny):

```bash
cd server
php artisan migrate:fresh --seed
```

**Vytvorí:**
- 2 sezóny (2024/2025 AKTÍVNA, 2023/2024 historická)
- 10 úloh pre aktuálnu sezónu
- 3 test účty

### 2. Test API:

```
http://127.0.0.1:8000/api/seasons/active
```

**Odpoveď:**
```json
{
  "success": true,
  "season": {
    "id": 1,
    "name": "Zima 2024/2025",
    "year": 2024,
    "is_active": true,
    ...
  }
}
```

### 3. Spustite Flutter:

```bash
cd pas_flutter
flutter run -d chrome
```

### 4. Testujte:

**Ako Admin:**
1. Login: admin@example.com / password
2. Klikni "Sezóny"
3. Vidíš 2 sezóny
4. Aktívna má zelený border
5. Klikni + → Vytvor novú sezónu
6. Klikni "Aktivovať" na starej → Zmení aktívnu

**Ako Child:**
1. Login: child@example.com / password
2. V headeri vidíš "📅 Zima 2024/2025"
3. Klikni na to → Bottom sheet
4. Vyber "Zima 2023/2024"
5. → Dashboard sa reloadne s dátami z roku 2023!

---

## 📋 ADMIN WORKFLOW

### Každý rok (September):

**Krok 1: Vytvor novú sezónu**
```
Sezóny → + → Vyplň:
- Názov: Zima 2025/2026
- Rok: 2025
- Start: 01.12.2025
- End: 31.03.2026
```

**Krok 2: Aktivuj sezónu**
```
Klikni "Aktivovať" na novej sezóne
→ Stará sa deaktivuje
→ Nová je aktívna
```

**Krok 3: Vytvor úlohy**
```
Úlohy → + → Vytvor úlohy pre novú sezónu
(Automaticky sa priradia k aktívnej sezóne)
```

**Krok 4: Hotovo!**
```
✅ Systém je pripravený na nový rok
✅ Deti začínajú s 0 pečiatkami
✅ Stará história je zachovaná
```

---

## 🔍 FILTROVANIE DÁTPODĽA SEZÓNY

### Backend automaticky filtruje:

**Úlohy:**
```php
// Default - aktívna sezóna
GET /api/tasks

// Špecifická sezóna
GET /api/tasks?season_id=2
```

**Pečiatky:**
```php
// Filter sa môže pridať (future):
GET /api/stamps?season_id=2
```

**Rebríček:**
```php
// Môže byť rozšírený (future):
GET /api/users/leaderboard?season_id=2
```

---

## 📊 REPORTING (Future Enhancement)

### Možné rozšírenia:

**1. Season Statistics Screen:**
```
- Celkové pečiatky
- Najpopulárnejšie úlohy
- Najaktívnejšie deti
- Grafy a charts
```

**2. Year Comparison:**
```
- 2024 vs 2023
- Rast účasti
- Zmeny v obľúbenosti úloh
```

**3. Export:**
```
- PDF certifikáty pre deti
- Excel report pre management
- Grafy pre marketing
```

---

## ✅ VÝHODY SYSTÉMU

### Pre Stredisko:
```
✅ Dlhodobá história
✅ Analytics po rokoch
✅ Porovnanie sezón
✅ Marketing insights
```

### Pre Deti:
```
✅ Fresh start každý rok
✅ História achievementov
✅ Motivácia zlepšiť sa
✅ Porovnanie vlastných rokov
```

### Pre Adminov:
```
✅ Jednoduchá správa
✅ Flexibilné nastavenie
✅ Žiadne manuálne resetovanie
✅ Automatizácia
```

---

## 🎉 ZÁVER

Máte teraz **MULTI-SEASON SYSTEM**:

✅ Backend - seasons tabuľka + relationships  
✅ API - 5 endpointov pre seasons  
✅ Flutter - season model + selector widget  
✅ Admin UI - season management screen  
✅ Child UI - season selector v dashboarde  
✅ Seeder - 2 testové sezóny  
✅ Dokumentácia - tento súbor!  

**READY FOR MULTI-YEAR USAGE! 🗓️🎊**

---

**Teraz môžete používať systém roky a roky s kompletnou históriou! 🚀**

---

Vytvorené s ❤️ pre dlhodobé používanie!








