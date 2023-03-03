# Windows

## HDR
Here you can find some tools that probably help HDR implementations in: https://github.com/Codectory/AutoActions

### toggleAutoHDR.bat
This script toggles whether `Microsoft Windows'` "Auto HDR" setting is turned on. It is meant to be used in conjunction with HDR. "Auto HDR" might work in most cases, but this allows you to control it on a per-game basis, by making a new profile in AutoActions like so:
1) Open <a href="https://github.com/Codectory/AutoActions">AutoActions</a>
2) Create a new `Profile`, called "HDR + AutoHDR"
3) Add a new action on **Application started actions** -> **Display Action** -> **Change HDR** -> `Activate HDR`
4) Add a new action on **Application closed actions** -> **Display Action** -> **Change HDR** -> `Deactivate HDR`
5) Add a new action on **Application started actions** -> **Run program** -> Set the `File path` to where toggleAutoHDR.bat is located. Set `Arguments` to `/on`
6) Add a new action on **Application closed actions** -> **Run program** -> Set the `File path` to where toggleAutoHDR.bat is located. Set `Arguments` to `/off`
- Note: Make sure you select `All Files` instead of just `.exe` so you can select `toggleAutoHDR.bat`. 
7) Assign relevant games, such as Halo: MCC to this new "HDR + AutoHDR" profile.
8) Enjoy!

## Remote Server Management

### serverRestarter.bat
Batch script to restart remote servers.

### serverRestarterStarter.bat
Batch script to start any command prompt as if a Smart Card user, which is useful for devices like the YubiKey

### serviceRestarter.ps1
PowerShell script to restart remote services.
