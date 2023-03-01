::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: Netrunner
:: License: GNU General Public License v3.0
:: Description: Toggle AutoHDR within Windows using parameters
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Usage: toggleAutoHDR.bat /off   |    toggleAutoHDR.bat /on
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
: Find Windows SID
for /f "delims= " %%a in ('"wmic path win32_useraccount where name='%USERNAME%' get sid"') do (
   if not "%%a"=="SID" (          
      set Sid=%%a
      goto :loop_end
   )   
)

:loop_end
set arg1=%1
set ValidKey=false
set AutoHDROn="AutoHDREnable=1;SwapEffectUpgradeEnable=1;"
set AutoHDROff="AutoHDREnable=0;SwapEffectUpgradeEnable=1;"
@for /f "tokens=3*" %%i in ('reg query HKEY_USERS\%Sid%\Software\Microsoft\DirectX\UserGpuPreferences /v "DirectXUserGlobalSettings" 2^>Nul') do set "AutoHDRString=%%i"
if not defined AutoHDRString goto exit

: Check if AutoHDR is of
if %AutoHDROff% == "%AutoHDRString%" (
    set ValidKey=true
)
if %AutoHDROn% == "%AutoHDRString%" (
    set ValidKey=true
)

if %ValidKey% == true (
    echo Performing registry swap..
    if "%arg1%" == "/off" (
        reg add HKEY_USERS\%Sid%\Software\Microsoft\DirectX\UserGpuPreferences /t REG_SZ /v DirectXUserGlobalSettings /d AutoHDREnable=0;SwapEffectUpgradeEnable=1; /f
    ) else (
        reg add HKEY_USERS\%Sid%\Software\Microsoft\DirectX\UserGpuPreferences /t REG_SZ /v DirectXUserGlobalSettings /d AutoHDREnable=1;SwapEffectUpgradeEnable=1; /f
    )
) else (
    echo The registry keys are set to an unexpected value..maybe due to a Windows Update; script stopped automatically.
    pause
)

:exit
exit
