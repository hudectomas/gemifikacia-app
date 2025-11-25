@echo off
echo ================================================
echo  SPUSTENIE FLUTTER APP - DETSKÝ PAS
echo ================================================
echo.

echo Kontrolujem Flutter...
flutter --version
echo.

echo Spustam aplikaciu v Chrome...
echo (Chrome je najrychlejsi sposob pre testovanie!)
echo.
echo Pre Android Emulator pouzite: flutter run
echo.

flutter run -d chrome

pause






