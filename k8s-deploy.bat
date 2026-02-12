@echo off
REM ============================================================================
REM Script de Déploiement Kubernetes - Investment Due Diligence AI
REM ============================================================================
REM Ce script facilite le déploiement sur Minikube
REM ============================================================================

echo ============================================================
echo    Kubernetes Deploy Script - Investment Due Diligence AI
echo ============================================================
echo.

REM Vérifier que kubectl est installé
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] kubectl n'est pas installé
    echo Installez kubectl: https://kubernetes.io/docs/tasks/tools/
    pause
    exit /b 1
)

REM Vérifier que minikube est installé
minikube version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Minikube n'est pas installé
    echo.
    echo Installation avec Chocolatey:
    echo   choco install minikube
    echo.
    echo Ou télécharger depuis:
    echo   https://minikube.sigs.k8s.io/docs/start/
    pause
    exit /b 1
)

REM Déterminer l'action
set ACTION=%1
if "%ACTION%"=="" set ACTION=deploy

echo Action: %ACTION%
echo.

REM Router vers l'action appropriée
if "%ACTION%"=="start" goto start_minikube
if "%ACTION%"=="load" goto load_images
if "%ACTION%"=="deploy" goto deploy_app
if "%ACTION%"=="status" goto check_status
if "%ACTION%"=="logs" goto view_logs
if "%ACTION%"=="tunnel" goto start_tunnel
if "%ACTION%"=="clean" goto cleanup
if "%ACTION%"=="stop" goto stop_minikube

echo [ERREUR] Action inconnue: %ACTION%
echo Actions disponibles: start, load, deploy, status, logs, tunnel, clean, stop
pause
exit /b 1

REM ============================================================================
REM START MINIKUBE
REM ============================================================================
:start_minikube
echo ============================================================
echo Démarrage de Minikube...
echo ============================================================
minikube start --driver=docker
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du démarrage de Minikube
    pause
    exit /b 1
)
echo.
echo [OK] Minikube démarré
echo.
echo Activation de l'addon Ingress...
minikube addons enable ingress
echo.
echo [OK] Cluster Kubernetes prêt!
echo.
echo Prochaine étape: .\k8s-deploy.bat load
goto end

REM ============================================================================
REM LOAD IMAGES
REM ============================================================================
:load_images
echo ============================================================
echo Chargement des images Docker dans Minikube...
echo ============================================================
echo.
echo Chargement de investment-backend:latest...
minikube image load investment-backend:latest
if %errorlevel% neq 0 (
    echo [ERREUR] Image backend non trouvée
    echo Buildez d'abord: .\docker-build.bat
    pause
    exit /b 1
)
echo.
echo Chargement de investment-frontend:latest...
minikube image load investment-frontend:latest
if %errorlevel% neq 0 (
    echo [ERREUR] Image frontend non trouvée
    echo Buildez d'abord: .\docker-build.bat
    pause
    exit /b 1
)
echo.
echo [OK] Images chargées dans Minikube
echo.
echo Prochaine étape: .\k8s-deploy.bat deploy
goto end

REM ============================================================================
REM DEPLOY APPLICATION
REM ============================================================================
:deploy_app
echo ============================================================
echo Déploiement de l'application...
echo ============================================================
echo.
echo Étape 1: Création du namespace...
kubectl apply -f k8s/namespace.yaml
if %errorlevel% neq 0 (
    echo [ERREUR] Échec de la création du namespace
    pause
    exit /b 1
)
echo.
echo Attente que le namespace soit prêt (5 secondes)...
timeout /t 5 /nobreak >nul
echo.
echo Étape 2: Application des secrets et configmap...
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml
echo.
echo Étape 3: Déploiement des applications...
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
echo.
echo Étape 4: Configuration de l'ingress...
kubectl apply -f k8s/ingress.yaml
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du déploiement
    pause
    exit /b 1
)
echo.
echo [OK] Application déployée!
echo.
echo Attente que les pods soient prêts (30 secondes)...
timeout /t 30 /nobreak >nul
echo.
echo Status:
kubectl get pods -n investment-ai
echo.
echo Pour voir les logs: .\k8s-deploy.bat logs
echo Pour accéder à l'app: .\k8s-deploy.bat tunnel
goto end

REM ============================================================================
REM CHECK STATUS
REM ============================================================================
:check_status
echo ============================================================
echo Status de l'application
echo ============================================================
echo.
echo Pods:
kubectl get pods -n investment-ai
echo.
echo Services:
kubectl get services -n investment-ai
echo.
echo Ingress:
kubectl get ingress -n investment-ai
echo.
echo Événements récents:
kubectl get events -n investment-ai --sort-by='.lastTimestamp' | Select-Object -Last 10
goto end

REM ============================================================================
REM VIEW LOGS
REM ============================================================================
:view_logs
echo ============================================================
echo Logs de l'application (Ctrl+C pour quitter)
echo ============================================================
echo.
set COMPONENT=%2
if "%COMPONENT%"=="" set COMPONENT=backend

echo Logs du %COMPONENT%:
kubectl logs -f -l component=%COMPONENT% -n investment-ai
goto end

REM ============================================================================
REM START TUNNEL
REM ============================================================================
:start_tunnel
echo ============================================================
echo Démarrage du tunnel Minikube
echo ============================================================
echo.
echo IMPORTANT: Gardez cette fenêtre ouverte
echo.
echo L'application sera accessible sur:
echo   http://localhost:3000 (Frontend)
echo   http://localhost:8080 (Backend API)
echo.
echo Démarrage du port-forward...
start cmd /k "kubectl port-forward service/frontend-service 3000:80 -n investment-ai"
timeout /t 2 /nobreak >nul
start cmd /k "kubectl port-forward service/backend-service 8080:8080 -n investment-ai"
echo.
echo [OK] Tunnels démarrés!
echo.
echo Ouvrez votre navigateur:
echo   Frontend: http://localhost:3000
echo   API Docs: http://localhost:8080/docs
goto end

REM ============================================================================
REM CLEANUP
REM ============================================================================
:clean
echo ============================================================
echo Nettoyage de l'application
echo ============================================================
echo.
echo ATTENTION: Cela supprimera toutes les ressources!
set /p CONFIRM="Êtes-vous sûr? (oui/non): "
if not "%CONFIRM%"=="oui" (
    echo Annulé
    goto end
)
echo.
echo Suppression du namespace investment-ai...
kubectl delete namespace investment-ai
echo.
echo [OK] Nettoyage terminé
goto end

REM ============================================================================
REM STOP MINIKUBE
REM ============================================================================
:stop_minikube
echo ============================================================
echo Arrêt de Minikube...
echo ============================================================
minikube stop
echo [OK] Minikube arrêté
goto end

REM ============================================================================
REM END
REM ============================================================================
:end
echo.
pause
