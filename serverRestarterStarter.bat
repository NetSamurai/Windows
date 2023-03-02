@echo off
echo Starting Server Restarter as SC-%USERNAME%@domain.com..
runas /smartcard "%USERPROFILE%\Path\To\serverRestarter.bat"