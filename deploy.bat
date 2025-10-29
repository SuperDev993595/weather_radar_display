@echo off
echo Starting deployment process...

echo.
echo Installing all dependencies...
call npm run install-all
if %errorlevel% neq 0 (
    echo Error installing dependencies
    pause
    exit /b 1
)

echo.
echo Building frontend...
call npm run build
if %errorlevel% neq 0 (
    echo Error building frontend
    pause
    exit /b 1
)

echo.
echo Starting backend server...
echo Backend will run on port 5003
echo Frontend build files are served by the backend
echo.
echo Access the application at: http://213.136.72.33:5003
echo.

call npm start
