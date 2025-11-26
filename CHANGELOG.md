# Changelog - Flutter Aplikácia

## 2024-11-08 - Finálne Opravy

### ✅ OPRAVENÉ:

1. **Backend - Employee prístup k deťom**
   - Employee môže teraz načítať zoznam detí (predtým len admin)
   - Fix v `server/app/Http/Controllers/UserController.php`

2. **Manuálne pridanie pečiatky**
   - Fungovanie opravené pre Employee
   - Pridané aj pre Admin
   - Zobrazuje všetky deti v aktuálnej sezóne

3. **Zjednodušený UI pre dieťa**
   - Odstránené duplicitné karty
   - Zostala len **"Moja História"** (namiesto Moje Sezóny + História)
   - SeasonSelector odstránený z hlavnej obrazovky
   - Automaticky zobrazuje aktuálnu sezónu

4. **Admin rozhranie**
   - Pridaná karta **"Manuálne Pečiatka"**
   - Admin má teraz prístup k rovnakej funkcii ako Employee

### 🎯 AKO TO FUNGUJE TERAZ:

#### **Dieťa (Child):**
- Hlavná obrazovka automaticky zobrazuje **aktuálnu sezónu**
- 5 action cards:
  1. Všetky Úlohy
  2. Moje Pečiatky
  3. Môj QR Kód
  4. Rebríček
  5. **Moja História** ← Zobrazí všetky sezóny a ich výsledky

#### **Employee:**
- Automaticky pracuje s **aktívnou sezónou**
- Vidí len deti v aktívnej sezóne
- 2 spôsoby pridania pečiatky:
  1. Skenovať QR kód dieťaťa
  2. Manuálne vybrať dieťa a úlohu

#### **Admin:**
- Vidí **VŠETKO**
- 8 action cards:
  1. Úlohy (správa)
  2. Používatelia (správa)
  3. Sezóny (správa)
  4. Rebríček
  5. Skenovať QR
  6. Dashboard (kompletný prehľad)
  7. **Manuálne Pečiatka** ← NOVÉ!
  8. Synchronizácia

### 📋 SYSTÉM SEZÓN:

**Automatické správanie:**
- Nové dieťa sa automaticky "prihlási" do **aktívnej sezóny** (žiadne manuálne prihlasovanie)
- Všetky nové pečiatky sa pridávajú do **aktívnej sezóny**
- Dieťa vidí aktuálnu sezónu automaticky
- V "Moja História" vidí všetky svoje minulé sezóny a výsledky

**Admin správa:**
- Admin vytvorí novú sezónu
- Admin aktivuje sezónu (predchádzajúca sa stane neaktívnou)
- Všetky nové pečiatky sa od tej chvíle pridávajú do novej aktívnej sezóny

### 🔐 OPRÁVNENIA:

| Funkcia | Child | Employee | Admin |
|---------|-------|----------|-------|
| Vlastné pečiatky | ✅ | ✅ | ✅ |
| Všetky úlohy | ✅ | ✅ | ✅ |
| QR kód (zobrazenie) | ✅ | ❌ | ❌ |
| QR kód (skenovanie) | ❌ | ✅ | ✅ |
| Manuálna pečiatka | ❌ | ✅ | ✅ |
| Správa úloh | ❌ | ❌ | ✅ |
| Správa používateľov | ❌ | ❌ | ✅ |
| Správa sezón | ❌ | ❌ | ✅ |
| Dashboard | ❌ | ❌ | ✅ |
| História sezón (vlastná) | ✅ | ❌ | ✅ |
| História sezón (všetci) | ❌ | ❌ | ✅ |

---

## Predchádzajúce Zmeny

### 2024-11-07
- Vytvorenie Flutter aplikácie
- Implementácia základných funkcií
- Multi-season systém
- QR code systém
- Offline synchronizácia

---

**Aktuálny stav:** ✅ PLNE FUNKČNÉ
**Backend:** Laravel 11
**Frontend:** Flutter 3.x
**Databáza:** SQLite (mobile) / SharedPreferences (web)







