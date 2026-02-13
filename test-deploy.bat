@echo off
echo Starting test...
echo.

echo Test 1: gcloud
gcloud version >nul 2>&1
if %errorlevel% neq 0 (
    echo FAIL: gcloud
    pause
    exit /b 1
)
echo PASS: gcloud

echo Test 2: docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo FAIL: docker
    pause
    exit /b 1
)
echo PASS: docker

echo Test 3: backend image
docker inspect investment-backend:latest >nul 2>&1
if errorlevel 1 (
    echo FAIL: backend image
    pause
    exit /b 1
)
echo PASS: backend image

echo Test 4: frontend image
docker inspect investment-frontend:latest >nul 2>&1
if errorlevel 1 (
    echo FAIL: frontend image
    pause
    exit /b 1
)
echo PASS: frontend image

echo.
echo All tests passed!
pause
