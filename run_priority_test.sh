#!/bin/bash
# قاعدة الاختبار: أندرويد أولاً، ثم ويندوز

echo "🤖 فحص أجهزة أندرويد المتصلة..."
ANDROID_DEVICES=$(flutter devices | grep "android" | wc -l)

if [ $ANDROID_DEVICES -gt 0 ]; then
    echo "✅ تم العثور على جهاز أندرويد. تشغيل التطبيق على أندرويد..."
    flutter run -d android --verbose
else
    echo "❌ لا يوجد جهاز أندرويد متصل. تشغيل التطبيق على ويندوز..."
    flutter run -d windows --verbose
fi
