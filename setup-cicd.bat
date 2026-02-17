@echo off
REM Setup CI/CD Pipeline for Cloud Run
REM This script configures Cloud Build triggers and permissions

echo ========================================
echo Setting up CI/CD Pipeline
echo ========================================

REM Set your project ID
set /p PROJECT_ID="Enter your GCP Project ID: "
set REGION=europe-west1

echo.
echo Configuring project...
gcloud config set project %PROJECT_ID%

echo.
echo ========================================
echo Step 1: Enable Required APIs
echo ========================================
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable containerregistry.googleapis.com

echo.
echo ========================================
echo Step 2: Grant Cloud Build Permissions
echo ========================================

REM Get Cloud Build service account
for /f "tokens=*" %%i in ('gcloud projects describe %PROJECT_ID% --format="value(projectNumber)"') do set PROJECT_NUMBER=%%i
set CLOUD_BUILD_SA=%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com

echo Cloud Build Service Account: %CLOUD_BUILD_SA%

REM Grant necessary roles
echo Granting Cloud Run Admin role...
gcloud projects add-iam-policy-binding %PROJECT_ID% ^
    --member=serviceAccount:%CLOUD_BUILD_SA% ^
    --role=roles/run.admin

echo Granting Service Account User role...
gcloud projects add-iam-policy-binding %PROJECT_ID% ^
    --member=serviceAccount:%CLOUD_BUILD_SA% ^
    --role=roles/iam.serviceAccountUser

echo Granting Secret Manager Accessor role...
gcloud projects add-iam-policy-binding %PROJECT_ID% ^
    --member=serviceAccount:%CLOUD_BUILD_SA% ^
    --role=roles/secretmanager.secretAccessor

echo.
echo ========================================
echo Step 3: Create Secrets in Secret Manager
echo ========================================

set /p OPENAI_KEY="Enter your OpenAI API Key: "
set /p PERPLEXITY_KEY="Enter your Perplexity API Key: "
set /p TAVILY_KEY="Enter your Tavily API Key: "

echo Creating secrets...
echo %OPENAI_KEY% | gcloud secrets create openai-api-key --data-file=- --replication-policy=automatic 2>nul || echo %OPENAI_KEY% | gcloud secrets versions add openai-api-key --data-file=-
echo %PERPLEXITY_KEY% | gcloud secrets create perplexity-api-key --data-file=- --replication-policy=automatic 2>nul || echo %PERPLEXITY_KEY% | gcloud secrets versions add perplexity-api-key --data-file=-
echo %TAVILY_KEY% | gcloud secrets create tavily-api-key --data-file=- --replication-policy=automatic 2>nul || echo %TAVILY_KEY% | gcloud secrets versions add tavily-api-key --data-file=-

echo.
echo ========================================
echo Step 4: Connect GitHub Repository
echo ========================================
echo.
echo MANUAL STEP REQUIRED:
echo 1. Go to: https://console.cloud.google.com/cloud-build/triggers/connect
echo 2. Select "GitHub" as source
echo 3. Authenticate and select your repository
echo 4. Press Enter when done...
pause

echo.
echo ========================================
echo Step 5: Create Build Trigger
echo ========================================

set /p REPO_NAME="Enter your GitHub repository name (e.g., username/repo): "

gcloud builds triggers create github ^
    --name=deploy-on-push ^
    --repo-name=%REPO_NAME% ^
    --repo-owner=%REPO_NAME:~0,-1% ^
    --branch-pattern="^main$" ^
    --build-config=cloudbuild-secure.yaml ^
    --substitutions=_REGION=%REGION%

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Your CI/CD pipeline is now configured.
echo Every push to the 'main' branch will trigger automatic deployment.
echo.
echo Next steps:
echo 1. Push cloudbuild-secure.yaml to your repository
echo 2. Make a commit to the main branch
echo 3. Watch the build at: https://console.cloud.google.com/cloud-build/builds
echo.
pause
