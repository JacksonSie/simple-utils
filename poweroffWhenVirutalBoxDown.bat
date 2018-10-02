@echo off
cls
echo.
set BreakSEC=300
set shutdownTime=60
set filename=%date:~5,2%.%date:~8,2%_%date:~0,4% ::mm.dd_yyyy
:start
::tasklist /fi "imagename eq VirtualBox.exe" /fo csv > list
for /f " skip=3 tokens=1,2 " %%a in ('tasklist /fi "imagename eq VirtualBox.exe"' ) do (
        set pid=%%b
        echo %%b %%a
        )
echo.
::if errorlevel neq 0 會有錯
if  not errorlevel 0 (
        echo %pid% VirtualBox.exe with errorlevel : %errorlevel%  >> error.txt
        goto :failReset
) else (
        if "%pid%" neq "" (
                :failReset
                set pid=
                timeout %BreakSEC% /nobreak
                goto :start
        ) else (
                rename error.txt error_%filename%.txt
                shutdown /s /t %shutdownTime%
         )
)
