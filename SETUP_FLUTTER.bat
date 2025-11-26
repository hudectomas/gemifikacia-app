@echo off
echo ================================================
echo  FLUTTER SETUP - DETSKÝ PAS
echo ================================================
echo.

echo [1/4] Overujem Flutter instalaciu...
flutter doctor --version
echo.

echo [2/4] Cistim projekt...
flutter clean
echo.

echo [3/4] Stahujem zavislosti...
flutter pub get
echo.

echo [4/4] Kontrolujem dostupne zariadenia...
flutter devices
echo.

echo ================================================
echo  HOTOVO!
echo.
echo  Pre spustenie aplikacie pouzite:
echo  flutter run
echo.
echo  Pre Android Emulator:
echo  flutter run
echo.
echo  Pre Chrome (testovanie):
echo  flutter run -d chrome
echo.
echo  NEZABUDNITE:
echo  1. Nastavit API URL v lib/config/constants.dart
echo  2. Spustit backend: cd server ^&^& php artisan serve
echo ================================================
echo.
pause








