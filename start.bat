@echo off
echo ============================================================
echo Investment Due Diligence AI - FastAPI Edition
echo ============================================================
echo.

echo Starting Backend (FastAPI)...
start cmd /k "cd backend && uv run run.py"

timeout /t 3 /nobreak > nul

echo Starting Frontend (Web Server)...
start cmd /k "cd frontend && python -m http.server 3000"

echo.
echo ============================================================
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000
echo API Docs: http://localhost:8080/docs
echo ============================================================
echo.
echo Press any key to exit (servers will continue running)...
pause > nul
