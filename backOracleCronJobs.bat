@echo off
set host=172.18.1.1
set login="foo"
set password="bar"


set file="%USERPROFILE%\AppData\Local\Temp\%RANDOM%.txt"
echo datetime=$(date +%%Y%%m%%d) >> %file%
echo crontab -l ^>^>/RADIO/crontab_$datetime.crontab >>%file%

C:\Users\adm\Desktop\program\putty.exe -ssh -l %login% -pw %password% %host% -m %file%
del %file%