@echo off
echo Building SpendWise...

if "%1"=="apk" (
    echo Building APK...
    flutter build apk --release --no-tree-shake-icons
    echo APK ready at: build\app\outputs\flutter-apk\app-release.apk
)

if "%1"=="aab" (
    echo Building App Bundle...
    flutter build appbundle --release --no-tree-shake-icons
    echo AAB ready at: build\app\outputs\bundle\release\app-release.aab
)

if "%1"=="" (
    echo Building both APK and AAB...
    flutter build apk --release --no-tree-shake-icons
    flutter build appbundle --release --no-tree-shake-icons
    echo Done.
)