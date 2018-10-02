# simple-utils
例行工作自動化的小工具，持續增加中

## autoMount.bat 
    * 自動掛載 NAS server
    * 需先設定IP
    * 需把此 script 加入 $PATH 與 startup
---
## changeIPauto.bat 
    - 自動更換靜態IP與動態IP
    - 需先知道網卡、IP
    - 需把此 script 加入 $PATH 與 startup
---
## backOracleCronJobs.bat 
    - 需要時可執行備份用
    - 需把此 script 加入 $PATH
---
## adSearch
這是為了方便查詢 AD 中各個員工狀態的小腳本

### 使用方式
- 先將 powershell 執行腳本的權限打開，可以使用以下指令，或參考 https://go.microsoft.com/fwlink/?LinkID=135170
```powershell
Set-ExecutionPolicy -ExecutionPolicy UNRESTRICTED
```
- 確認 chcp 的encoding 是 utf8系列，否則輸出不正常
- ./this.ps1 員工號碼1 員工號碼2 員工號碼3 ...

### output sample:
        empNo1	業務部	小明  在職
        empNo2	會計部	阿美  留停
        empNo3	經營室	王董  離職
        ...
