# simple-utils
例行工作自動化的小工具，持續增加中

## autoMount.bat 
* 自動掛載 NAS server
* 需先設定IP
* 需把此 script 加入 $PATH 與 startup
---
## changeIPauto.bat 
* 自動更換靜態IP與動態IP
* 需先知道網卡、IP
* 需把此 script 加入 $PATH 與 startup
---
## backOracleCronJobs.bat 
* 需要時可執行備份用
* 需把此 script 加入 $PATH
---
## adSearch
這是為了方便查詢 AD 中各個員工狀態的小腳本

### 使用方式
* 先將 powershell 執行腳本的權限打開，可以使用以下指令，或參考 https://go.microsoft.com/fwlink/?LinkID=135170
```powershell
Set-ExecutionPolicy -ExecutionPolicy UNRESTRICTED
```
* 確認 chcp 的encoding 是 utf8系列，否則輸出不正常
* ./this.ps1 員工號碼1 員工號碼2 員工號碼3 ...

### output sample:
        empNo1	業務部	小明  在職
        empNo2	會計部	阿美  留停
        empNo3	經營室	王董  離職
        ...
---
## sqlUpdateSample.sql 
- 產出月報告的自動工具(Oracle)
- Oracle sql anonymous block code
### 呼叫方式
```bash
crontab -e
0 0 * * * sqlplus @sqlUpdateSample
$ sqlplus @sqlUpdateSample
```
---
## md5checksum.py

### 使用方式
```bash
$ python ./this.py foo.exe bar.zip biz.png ...
```
---
## BackupDB.bat
備份開發資料庫

### 使用方式
```bash
$ ./this.bat %1 %2 %3 
```
- %1 放本機的備份 dmp 檔
- %2 server 的 dmp檔位置
- %3 放控制用的 switch_case
---
## backup_logic.bat
備份程式開發(powerbuilder)的原始碼

---
## layoutGen.py
開發 powerbuilder datawindow layout 的生成 code

### 使用方式
- 創一個txt檔(argv[1])，裡頭:
``` bash
tableINcolumn1
tableINcolumn2
...
```
- 再創一個txt檔，裡頭把 dw 的src code塞進去(argv[2])。他就會輸出你所需要的全部給你，你再把它貼到PB就好。
- $ python layoutGne.py argv[1] argv[2] 
---
## Syslog server.py
臨時架一個 syslog server 用的 code

---
## pinger.py
多執行續 ping IP

---
## poweroffWhenVirutalBoxDown.bat
windows 發現 Vbox 咖掉後即關機 (要事先把 Virtualboxe 管理介面選單關掉)