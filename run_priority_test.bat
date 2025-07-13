@echo off
REM قاعدة الاختبار: أندرويد أولاً، ثم ويندوز

echo 🤖 فحص أجهزة أندرويد المتصلة...
flutter devices | findstr "android" >nul

if %ERRORLEVEL% EQU 0 (
    echo ✅ تم العثور على جهاز أندرويد. تشغيل التطبيق على أندرويد...
    flutter run -d android --verbose
) else (
    echo ❌ لا يوجد جهاز أندرويد متصل. تشغيل التطبيق على ويندوز...
    flutter run -d windows --verbose
)
