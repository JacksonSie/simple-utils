@echo off
timeout /t 60

ipconfig |findstr 172
if not ERRORLEVEL 0 exit

:: for /f "delims=" %%a in (%~dp0\batchConfig\BAT.config) do (set %%a)
set NSSid=Foo
set NSSpass=Bar
net use K: \\172.20.24.1\nss2 /user:%NSSid% %NSSpass%


pause
