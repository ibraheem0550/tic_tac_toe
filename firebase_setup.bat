@echo off
echo 🔥 Firebase Setup Commands for Tic Tac Toe

echo.
echo 📱 App IDs:
echo Android: 1:43060082396:android:db71a1bd4d59659d2c2619
echo iOS: 1:43060082396:ios:b39d3d6c1ba55cdd2c2619
echo iOS Encoded: app-1-43060082396-ios-b39d3d6c1ba55cdd2c2619

echo.
echo 🛠️ Running setup commands...

echo.
echo 1. Cleaning project...
flutter clean

echo.
echo 2. Getting dependencies...
flutter pub get

echo.
echo 3. Getting SHA-1 for Android (needed for Google Sign In)...
echo Navigate to android folder and run: gradlew signingReport
echo.

echo.
echo 4. Running app...
echo Choose platform:
echo   - Android: flutter run -d android
echo   - iOS: flutter run -d ios
echo   - Windows: flutter run -d windows

echo.
echo 📋 Next steps:
echo 1. Download google-services.json and place in android/app/
echo 2. Download GoogleService-Info.plist and place in ios/Runner/
echo 3. Enable Authentication methods in Firebase Console
echo 4. Create Firestore Database
echo 5. Test the app!

echo.
echo 🔗 Firebase Console: https://console.firebase.google.com
echo.

pause
