@echo Off

::%1 放本機的備份 dmp 檔
::%2 放 server01 的 dmp檔位置
::%3 放控制用的 switch_case

set bakDMP=%1\
set serverDMP=%2\
set switch_case=%3\

FOR /F "tokens=1-4 delims=/ " %%a IN ("%date%") DO (
SET MyDate=%%a%%b%%c
)
set myfileNmae=DEV03_%MyDate%
	
if exist %bakDMP%%myfileNmae%.dmp ( 
	echo. && echo %myfileNmae% 已存在
	call %switch_case% %bakDMP% %MyDate% %serverDMP%
	goto :EOF
)
echo will export %myfileNmae%...
2>nul exp foo/bar@DEV03 BUFFER=4096 FILE=%bakDMP%%myfileNmae%.dmp GRANTS=Y LOG=%bakDMP%%myfileNmae%.log OWNER=foo 

zip %bakDMP%%myfileNmae%.zip %bakDMP%%myfileNmae%.dmp -9 -j >> %bakDMP%%myfileNmae%.log

del %bakDMP%%myfileNmae%.dmp

copy %bakDMP%%myfileNmae%.zip %serverDMP% /-Y 2>&1 >> %bakDMP%%myfileNmae%.log


