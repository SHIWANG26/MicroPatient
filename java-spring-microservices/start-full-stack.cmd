@echo off
echo ========================================
echo Starting Full Stack Application
echo ========================================
echo.

REM Navigate to project root
cd /d "%~dp0\.."

REM Run the main startup script
call start-full-stack.cmd
