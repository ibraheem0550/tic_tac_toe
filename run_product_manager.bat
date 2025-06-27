@echo off
echo Starting Unified Admin Mode (Product Manager View)...
echo ==================================================
echo وضع الإدارة الموحد - عرض إدارة المنتجات
echo ==================================================
cd /d "c:\Users\ibrah\projects\projects for code\tic_tac_toe"
flutter run -d windows --dart-define=app_mode=admin
pause
