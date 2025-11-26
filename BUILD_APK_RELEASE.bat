@echo off
echo ======================================
echo   BUILDING ANDROID APK (RELEASE)
echo ======================================
echo.

cd /d "%~dp0"

echo Cleaning previous builds...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo.
echo ======================================
echo Building RELEASE APK (optimized)...
echo ======================================
echo.
call flutter build apk --release

echo.
echo ======================================
echo   BUILD COMPLETE!
echo ======================================
echo.
echo APK location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo File size optimized for production!
echo Copy this file to your Android phone and install it!
echo.
pause







