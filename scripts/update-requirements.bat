@echo off
REM ============================================================================
REM Script de Mise à Jour des Requirements
REM ============================================================================
REM Ce script regénère requirements.txt et supprime automatiquement pywin32
REM ============================================================================

echo Regeneration de requirements.txt...
uv pip compile pyproject.toml -o requirements.txt

echo Suppression de pywin32 (Windows-only)...
powershell -Command "(Get-Content requirements.txt) -replace '^pywin32==.*$', '# pywin32==311  # EXCLUDED - Windows only, not needed' | Set-Content requirements.txt"

echo.
echo [OK] requirements.txt mis a jour sans pywin32
echo.
pause
