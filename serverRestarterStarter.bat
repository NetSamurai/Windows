::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: Netrunner
:: License: GNU General Public License v3.0
:: Description: Restart a server remotely using a smart card and just a .bat!
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
echo Starting Server Restarter as SC-%USERNAME%@domain.com..
runas /smartcard "%USERPROFILE%\Path\To\serverRestarter.bat"
