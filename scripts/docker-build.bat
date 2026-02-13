@echo off
REM ============================================================================
REM Script de Build Docker - Investment Due Diligence AI
REM ============================================================================
REM Ce script facilite le build des images Docker
REM Usage: docker-build.bat [backend|frontend|all]
REM ============================================================================

echo ============================================================
echo    Docker Build Script - Investment Due Diligence AI
echo ============================================================
echo.

REM Vérifier si Docker est installé
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas installé ou n'est pas dans le PATH
    echo Installez Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Vérifier si Docker est en cours d'exécution
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas en cours d'execution
    echo Demarrez Docker Desktop et reessayez
    pause
    exit /b 1
)

echo [OK] Docker est installe et en cours d'execution
echo.

REM Déterminer quoi builder
set BUILD_TARGET=%1
if "%BUILD_TARGET%"=="" set BUILD_TARGET=all

echo Target de build: %BUILD_TARGET%
echo.

REM Build Backend
if "%BUILD_TARGET%"=="backend" goto build_backend
if "%BUILD_TARGET%"=="all" goto build_backend
goto check_frontend

:build_backend
echo ============================================================
echo Building Backend Image...
echo ============================================================
docker build -t investment-backend:latest -f backend/Dockerfile .
if %errorlevel% neq 0 (
    echo [ERREUR] Build du backend a echoue
    pause
    exit /b 1
)
echo [OK] Backend image built successfully
echo.

:check_frontend
if "%BUILD_TARGET%"=="backend" goto end
if "%BUILD_TARGET%"=="frontend" goto build_frontend
if "%BUILD_TARGET%"=="all" goto build_frontend
goto end

:build_frontend
echo ============================================================
echo Building Frontend Image...
echo ============================================================
docker build -t investment-frontend:latest -f frontend/Dockerfile frontend/
if %errorlevel% neq 0 (
    echo [ERREUR] Build du frontend a echoue
    pause
    exit /b 1
)
echo [OK] Frontend image built successfully
echo.

:end
echo ============================================================
echo Build Complete!
echo ============================================================
echo.
echo Images disponibles:
docker images | findstr investment
echo.
echo Pour demarrer les conteneurs:
echo   docker-compose up -d
echo.
pause
