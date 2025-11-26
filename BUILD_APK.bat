@echo off
echo ======================================
echo   BUILDING ANDROID APK
echo ======================================
echo.

cd /d "%~dp0"

echo Cleaning previous builds...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo.
echo ======================================
echo Building DEBUG APK (for testing)...
echo ======================================
echo.
call flutter build apk --debug

echo.
echo ======================================
echo   BUILD COMPLETE!
echo ======================================
echo.
echo APK location:
echo build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Copy this file to your Android phone and install it!
echo.
pause







