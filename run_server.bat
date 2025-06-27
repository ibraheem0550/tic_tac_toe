@echo off
echo 🚀 Starting Tic Tac Toe Game Server...
cd /d "%~dp0server"

REM التحقق من وجود Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM التحقق من وجود npm
npm --version >nul 2>&1
if errorlevel 1 (
    echo ❌ npm is not available
    pause
    exit /b 1
)

REM تثبيت التبعيات إذا لم تكن موجودة
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
    if errorlevel 1 (
        echo ❌ Failed to install dependencies
        pause
        exit /b 1
    )
)

echo ✅ Starting server on port 3000...
echo 🌐 Server will be available at http://localhost:3000
echo 🎮 Players can now connect from the Flutter app
echo.
echo Press Ctrl+C to stop the server
echo.

REM تشغيل الخادم
npm start

pause
