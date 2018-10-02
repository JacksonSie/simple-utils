@echo off

set source=\\Server03\d\BVC_ecm\BVC_app\BVC_DEV\BVC_ERP
set dest=C:\Users\jackson\Desktop\BVC\BVC_ERP
set log=C:\Users\jackson\Desktop\各種資訊\logs

FOR /F "tokens=1-4 delims=/ " %%a IN ("%date%") DO (
SET MyDate=%%a%%b%%c
)
set myfileNmae=ERP_%MyDate%
rem PowerShell.exe -windowstyle hidden (隱藏視窗用)
robocopy %source% %dest% /E /XO /purge /log+:%log%/%myfileNmae%.txt
echo. >>%log%/%myfileNmae%.txt
echo. >>%log%/%myfileNmae%.txt
echo. >>%log%/%myfileNmae%.txt
echo. >>%log%/%myfileNmae%.txt
exit /B