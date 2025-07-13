#!/bin/bash
# Tic Tac Toe - iOS Runner (macOS only)

echo ""
echo "======================================="
echo "      Tic Tac Toe - iOS Version"
echo "======================================="
echo ""

cd "$(dirname "$0")"

echo "تحضير التطبيق لـ iOS..."
cp pubspec_complete.yaml pubspec.yaml
flutter clean > /dev/null 2>&1
flutter pub get

echo ""
echo "فحص محاكيات iOS المتاحة..."
flutter devices | grep ios

echo ""
echo "تشغيل التطبيق على iOS..."
echo "(يتطلب macOS و Xcode)"
echo ""

flutter run -d ios

echo ""
if [ $? -eq 0 ]; then
    echo "✅ تم تشغيل التطبيق على iOS بنجاح!"
else
    echo "❌ فشل التشغيل على iOS"
    echo "تحقق من:"
    echo "- تشغيل على جهاز macOS"
    echo "- تثبيت Xcode"
    echo "- تشغيل محاكي iOS"
fi
echo ""
read -p "اضغط Enter للإغلاق..."
