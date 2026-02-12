@echo off
REM ============================================================================
REM Script de Run Docker - Investment Due Diligence AI
REM ============================================================================
REM Ce script facilite le démarrage des conteneurs Docker
REM Usage: docker-run.bat [start|stop|restart|logs|status]
REM ============================================================================

echo ============================================================
echo    Docker Run Script - Investment Due Diligence AI
echo ============================================================
echo.

REM Vérifier si Docker est installé
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas installé
    pause
    exit /b 1
)

REM Vérifier si Docker Compose est installé
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Compose n'est pas installé
    pause
    exit /b 1
)

REM Déterminer l'action
set ACTION=%1
if "%ACTION%"=="" set ACTION=start

echo Action: %ACTION%
echo.

REM Exécuter l'action
if "%ACTION%"=="start" goto start
if "%ACTION%"=="stop" goto stop
if "%ACTION%"=="restart" goto restart
if "%ACTION%"=="logs" goto logs
if "%ACTION%"=="status" goto status
if "%ACTION%"=="clean" goto clean

echo [ERREUR] Action inconnue: %ACTION%
echo Actions disponibles: start, stop, restart, logs, status, clean
pause
exit /b 1

:start
echo ============================================================
echo Demarrage des conteneurs...
echo ============================================================
docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERREUR] Echec du demarrage
    pause
    exit /b 1
)
echo.
echo [OK] Conteneurs demarres avec succes!
echo.
echo Backend:  http://localhost:8080
echo Frontend: http://localhost:3000
echo API Docs: http://localhost:8080/docs
echo.
echo Pour voir les logs: docker-run.bat logs
goto end

:stop
echo ============================================================
echo Arret des conteneurs...
echo ============================================================
docker-compose down
echo [OK] Conteneurs arretes
goto end

:restart
echo ============================================================
echo Redemarrage des conteneurs...
echo ============================================================
docker-compose restart
echo [OK] Conteneurs redemarres
goto end

:logs
echo ============================================================
echo Logs des conteneurs (Ctrl+C pour quitter)
echo ============================================================
docker-compose logs -f

:status
echo ============================================================
echo Status des conteneurs
echo ============================================================
docker-compose ps
echo.
echo Utilisation des ressources:
docker stats --no-stream
goto end

:clean
echo ============================================================
echo Nettoyage complet (conteneurs, images, volumes)
echo ============================================================
echo ATTENTION: Cela supprimera tout!
set /p CONFIRM="Etes-vous sur? (oui/non): "
if not "%CONFIRM%"=="oui" (
    echo Annule
    goto end
)
docker-compose down -v --rmi all
echo [OK] Nettoyage termine
goto end

:end
echo.
pause
