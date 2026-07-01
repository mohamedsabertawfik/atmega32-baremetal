@echo off
chcp 65001 > nul
color 0A

echo =======================================
echo     Preparing files for Uploading
echo =======================================

:: فحص إذا كان المجلد يحتوي على جيّت مسبقاً
if exist .git (
    echo =======================================
    echo    This project is already initialized!
    echo =======================================
    goto skip_init
)

git init
echo =======================================
echo          initialization Done
echo =======================================

:skip_init
echo =======================================
echo          Adding all the files
echo =======================================

git add .
echo =======================================
echo                Adding Done
echo =======================================

echo.
set /p commit_msg="Enter your Commit message: "
git commit -m "%commit_msg%"

git branch -M main

:: فحص إذا كان الـ origin مضاف من الأساس في الإعدادات
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Remote 'origin' not found.
    goto ask_remote
)

:try_push
echo =======================================
echo         Uploading to GitHub...
echo =======================================
git push -u origin main
:: لو الـ push تم بنجاح، اذهب لنهاية السكريبت
if %errorlevel% equ 0 goto success_block

echo.
echo [X] Push failed! 
echo [!] This usually happens if the link is wrong OR GitHub contains files (like README.md) that you don't have locally.
echo ---------------------------------------
echo  1. Re-enter/Update the GitHub repo link.
echo  2. Pull remote changes from GitHub (Fix "fetch first" error).
echo  3. Exit.
echo ---------------------------------------
set /p push_choice="Choose an option (1-3): "

if "%push_choice%"=="1" goto ask_remote
if "%push_choice%"=="2" goto auto_pull
goto end_script

:auto_pull
echo.
echo =======================================
echo     Pulling changes from GitHub...
echo =======================================
:: تم إضافة --no-rebase هنا لحل مشكلة الحيرة وتحديد طريقة الدمج تلقائياً
git pull origin main --no-rebase --allow-unrelated-histories
echo =======================================
echo     Trying to push again...
echo =======================================
goto try_push

:ask_remote
echo.
echo =======================================
echo    Link your device with the repo
echo =======================================
set /p repo_link="Enter your GitHub repo link: "

if defined repo_link set repo_link=%repo_link:"=%

if "%repo_link%"=="" (
    echo [ERROR] Link cannot be empty!
    goto ask_remote
)

git remote add origin "%repo_link%" 2>nul
if %errorlevel% neq 0 (
    git remote set-url origin "%repo_link%"
)
echo [V] Remote link configured. Trying to push again...
goto try_push

:success_block
echo.
echo تم الرفع بنجاح!                 
echo =======================================
echo        Uploaded Successfully!
echo =======================================

:end_script
pause