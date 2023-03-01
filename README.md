# Windows-HDR
Here you can find some tools that probably help HDR implementations in: https://github.com/Codectory/AutoActions

## toggleAutoHDR.bat
This script toggles whether Window's "Auto HDR" setting is turned on. It is meant to be used in conjunction with HDR. "Auto HDR" might work in most cases, but this allows you to control it on a per-game basis, by making a new profile in AutoActions like so:
1) Open <a href="https://github.com/Codectory/AutoActions">AutoActions</a>
2) Create a new `Profile`, called "HDR + AutoHDR"
3) Add a new action on **Application started actions** -> **Display Action** -> **Change HDR** -> `Activate HDR`
4) Add a new action on **Application closed actions** -> **Display Action** -> **Change HDR** -> `Deactivate HDR`
5) Add a new action on **Application started actions** -> **Run program** -> Set the `File path` to where toggleAutoHDR.bat is located. Set `Arguments` to `/on`
6) Add a new action on **Application closed actions** -> **Run program** -> Set the `File path` to where toggleAutoHDR.bat is located. Set `Arguments` to `/off`
7) Assign relevant games, such as Halo: MCC to this new "HDR + AutoHDR" profile.
8) Enjoy!
