@echo off
set interface="°Ï°ì³s½u"
set ipaddr=10.6.225.198
set mask=255.255.255.0
set gateway=10.6.225.254
set recoveryKey=dhcp

netsh interface ip set address name=%interface% static %ipaddr% gateway=%gateway% mask=%mask%
echo ip %ipaddr% setted

if %1==%recoveryKey% ( 
netsh interface ip set address %interface% dhcp 
echo ip auto recovery
)