::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: Netrunner
:: License: GNU General Public License v3.0
:: Description: Restart a server remotely using a smart card and just a .bat!
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Hide Command and Set Scope
@echo off
setlocal EnableExtensions

:: Customize Window
title Server Restart Menu

set "server[1]=hostname1"
set "server[2]=hostname2"
set "server[3]=hostname3"

:: Display the Menu
set "Message="
:Menu
cls
echo.%Message%
echo.
echo.  Server Restart Menu
echo.
set "x=0"
:MenuLoop
set /a "x+=1"
if defined Server[%x%] (
    call echo   %x%. %%Server[%x%]%%
    goto MenuLoop
)
echo.

:: Prompt User for Choice
:Prompt
set "Input="
set /p "Input=Which Server would you like to restart? "

:: Validate Input [Remove Special Characters]
if not defined Input goto Prompt
set "Input=%Input:"=%"
set "Input=%Input:^=%"
set "Input=%Input:<=%"
set "Input=%Input:>=%"
set "Input=%Input:&=%"
set "Input=%Input:|=%"
set "Input=%Input:(=%"
set "Input=%Input:)=%"
:: Equals are not allowed in variable names
set "Input=%Input:^==%"
call :Validate %Input%

:: Process Input
call :Process %Input%
goto End

:Validate
set "Next=%2"
if not defined Server[%1] (
    set "Message=Invalid Input: %1"
    goto Menu
)
if defined Next shift & goto Validate
goto :eof

:Process
set "Next=%2"
call set "Server=%%Server[%1]%%"


set /P AREYOUSURE=Are you sure? Type YES to confirm or anything else to cancel...
if /I "%AREYOUSURE%" NEQ "YES" goto :eof

echo Restarting %Server%...
shutdown /r /m \\%Server%.win.ad.domain.com
pause
endlocal
start "" "%~f0"
exit

:: Prevent the command from being processed twice if listed twice.
set "Server[%1]="
if defined Next shift & goto Process
goto :eof

:End
endlocal
