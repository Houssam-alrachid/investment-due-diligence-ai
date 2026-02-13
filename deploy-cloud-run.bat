@echo off
REM ============================================================================
REM Script de Déploiement Cloud Run - Investment Due Diligence AI
REM ============================================================================
REM Ce script automatise le déploiement sur Google Cloud Run
REM ============================================================================

echo ============================================================
echo    Cloud Run Deployment - Investment Due Diligence AI
echo ============================================================
echo.

REM ============================================================================
REM CONFIGURATION - MODIFIER CES VALEURS
REM ============================================================================
set PROJECT_ID=ysance-datascience
set REGION=europe-west1

echo Configuration:
echo   Project ID: %PROJECT_ID%
echo   Region: %REGION%
echo.

REM ============================================================================
REM CONFIGURATION DES CLES API
REM ============================================================================
echo.
echo Configuration des cles API (variables d'environnement)...
echo AVERTISSEMENT: Les cles seront visibles dans la console Cloud Run
echo il faut mieux les stocker dans secret manager de GCP (j'ai pas les permissions)
echo.

set /p OPENAI_API_KEY="Entrez votre OPENAI_API_KEY: "
if "%OPENAI_API_KEY%"=="" (
    echo [ERREUR] OPENAI_API_KEY est requis
    pause
    exit /b 1
)

set /p SENDGRID_API_KEY="Entrez votre SENDGRID_API_KEY: "
if "%SENDGRID_API_KEY%"=="" (
    echo [ERREUR] SENDGRID_API_KEY est requis
    pause
    exit /b 1
)

echo [OK] Cles API configurees
echo.

REM ============================================================================
REM VERIFICATION DES PREREQUIS
REM ============================================================================
echo [Verification] Checking prerequisites...

REM Vérifier gcloud
call gcloud version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] gcloud n'est pas installé
    echo.
    echo Installation:
    echo   choco install gcloudsdk
    echo.
    pause
    exit /b 1
)
echo [OK] gcloud installé

REM Vérifier Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas installé
    pause
    exit /b 1
)
echo [OK] Docker installé

REM Vérifier les images locales
docker inspect investment-backend:latest >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Image investment-backend:latest non trouvée
    echo Buildez d'abord: .\docker-build.bat
    pause
    exit /b 1
)
echo [OK] Image backend trouvée

docker inspect investment-frontend:latest >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Image investment-frontend:latest non trouvée
    echo Buildez d'abord: .\docker-build.bat
    pause
    exit /b 1
)
echo [OK] Image frontend trouvée

echo.

REM ============================================================================
REM ETAPE 1: CONFIGURATION DU PROJET
REM ============================================================================
echo ============================================================
echo [1/7] Configuration du projet GCP...
echo ============================================================
call gcloud config set project %PROJECT_ID%
if %errorlevel% neq 0 (
    echo [ERREUR] Impossible de configurer le projet
    echo Vérifiez que le projet existe et que vous avez les permissions
    pause
    exit /b 1
)
echo [OK] Projet configuré
echo.

REM ============================================================================
REM ETAPE 2: ACTIVATION DES APIS
REM ============================================================================
echo ============================================================
echo [2/7] Activation des APIs nécessaires...
echo ============================================================
echo Activation de Cloud Run API...
call gcloud services enable run.googleapis.com
echo Activation de Container Registry API...
call gcloud services enable containerregistry.googleapis.com
echo Activation de Artifact Registry API...
call gcloud services enable artifactregistry.googleapis.com
echo [OK] APIs activées
echo.

REM ============================================================================
REM ETAPE 3: CONFIGURATION DOCKER
REM ============================================================================
echo ============================================================
echo [3/7] Configuration de Docker pour Google Container Registry (GCR)...
echo ============================================================
call gcloud auth configure-docker
if %errorlevel% neq 0 (
    echo [ERREUR] Échec de la configuration Docker
    pause
    exit /b 1
)
echo [OK] Docker configuré
echo.

REM ============================================================================
REM ETAPE 4: PUSH DES IMAGES
REM ============================================================================
echo ============================================================
echo [4/7] Push des images vers GCR...
echo ============================================================

echo Tagging backend image...
docker tag investment-backend:latest gcr.io/%PROJECT_ID%/investment-backend:latest
docker tag investment-backend:latest gcr.io/%PROJECT_ID%/investment-backend:v1.0

echo Pushing backend image...
docker push gcr.io/%PROJECT_ID%/investment-backend:latest
docker push gcr.io/%PROJECT_ID%/investment-backend:v1.0
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du push de l'image backend
    pause
    exit /b 1
)
echo [OK] Backend image pushed

echo.
echo Tagging frontend image...
docker tag investment-frontend:latest gcr.io/%PROJECT_ID%/investment-frontend:latest
docker tag investment-frontend:latest gcr.io/%PROJECT_ID%/investment-frontend:v1.0

echo Pushing frontend image...
docker push gcr.io/%PROJECT_ID%/investment-frontend:latest
docker push gcr.io/%PROJECT_ID%/investment-frontend:v1.0
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du push de l'image frontend
    pause
    exit /b 1
)
echo [OK] Frontend image pushed
echo.

REM ============================================================================
REM ETAPE 5: DEPLOIEMENT DU BACKEND
REM ============================================================================
echo ============================================================
echo [5/7] Déploiement du backend sur Cloud Run...
echo ============================================================

call gcloud run deploy investment-backend ^
  --image gcr.io/%PROJECT_ID%/investment-backend:latest ^
  --platform managed ^
  --region %REGION% ^
  --allow-unauthenticated ^
  --port 8080 ^
  --memory 512Mi ^
  --cpu 1 ^
  --timeout 300 ^
  --min-instances 0 ^
  --max-instances 10 ^
  --set-env-vars API_HOST=0.0.0.0,API_PORT=8080,PYTHONUNBUFFERED=1,OPENAI_API_KEY=%OPENAI_API_KEY%,SENDGRID_API_KEY=%SENDGRID_API_KEY%

if %errorlevel% neq 0 (
    echo [ERREUR] Échec du déploiement du backend
    echo.
    echo Vérifiez que vous avez les permissions nécessaires
    echo.
    pause
    exit /b 1
)

echo [OK] Backend déployé!
echo.

REM Obtenir l'URL du backend
echo Récupération de l'URL du backend...
for /f "tokens=*" %%i in ('call gcloud run services describe investment-backend --region %REGION% --format "value(status.url)"') do set BACKEND_URL=%%i

echo Backend URL: %BACKEND_URL%
echo.

REM ============================================================================
REM ETAPE 6: DEPLOIEMENT DU FRONTEND
REM ============================================================================
echo ============================================================
echo [6/7] Déploiement du frontend sur Cloud Run...
echo ============================================================

call gcloud run deploy investment-frontend ^
  --image gcr.io/%PROJECT_ID%/investment-frontend:latest ^
  --platform managed ^
  --region %REGION% ^
  --allow-unauthenticated ^
  --port 80 ^
  --memory 256Mi ^
  --cpu 1 ^
  --timeout 60 ^
  --min-instances 0 ^
  --max-instances 5 ^
  --set-env-vars BACKEND_URL=%BACKEND_URL%

if %errorlevel% neq 0 (
    echo [ERREUR] Échec du déploiement du frontend
    pause
    exit /b 1
)

echo [OK] Frontend déployé!
echo.

REM Obtenir l'URL du frontend
echo Récupération de l'URL du frontend...
for /f "tokens=*" %%i in ('call gcloud run services describe investment-frontend --region %REGION% --format "value(status.url)"') do set FRONTEND_URL=%%i

echo Frontend URL: %FRONTEND_URL%
echo.

REM ============================================================================
REM ETAPE 7: MISE A JOUR DU BACKEND AVEC FRONTEND_URL
REM ============================================================================
echo ============================================================
echo [7/7] Mise à jour du backend avec FRONTEND_URL...
echo ============================================================

call gcloud run services update investment-backend ^
  --region %REGION% ^
  --update-env-vars FRONTEND_URL=%FRONTEND_URL%

if %errorlevel% neq 0 (
    echo [AVERTISSEMENT] Échec de la mise à jour FRONTEND_URL
    echo Vous devrez le faire manuellement via la console
)

echo [OK] Backend mis à jour
echo.

REM ============================================================================
REM RESUME FINAL
REM ============================================================================
echo ============================================================
echo    Déploiement Terminé avec Succès!
echo ============================================================
echo.
echo URLs de votre application:
echo.
echo   Frontend (Public):  %FRONTEND_URL%
echo   Backend (API):      %BACKEND_URL%
echo   API Docs:           %BACKEND_URL%/docs
echo   Health Check:       %BACKEND_URL%/health
echo.
echo ============================================================
echo    Tests Recommandés
echo ============================================================
echo.
echo 1. Ouvrir le frontend dans votre navigateur:
echo    %FRONTEND_URL%
echo.
echo 2. Tester le healthcheck du backend:
echo    curl %BACKEND_URL%/health
echo.
echo 3. Voir la documentation API:
echo    %BACKEND_URL%/docs
echo.
echo 4. Lancer une analyse complète via l'interface
echo.
echo ============================================================
echo    Monitoring
echo ============================================================
echo.
echo Voir les logs:
echo   gcloud run services logs read investment-backend --region %REGION%
echo   gcloud run services logs read investment-frontend --region %REGION%
echo.
echo Voir les métriques:
echo   https://console.cloud.google.com/run?project=%PROJECT_ID%
echo.
echo ============================================================
echo.
pause
