::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: Netrunner
:: License: GNU General Public License v3.0
:: Description: Mount NFS drive(s). Add to Windows Task Scheduler to automate this.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
set nas=192.168.1.2

timeout /t 3
ping -n 1 %nas% |find "TTL=" || goto :loop
echo Ping answer received..

:remount
echo Unmounting NFS share...
umount N:\

echo Remounting NFS share...
mount -o anon -o nolock \\g.home\volume1\data N:\

echo Checking if NFS share is mounted...
if exist N:\ (
    goto exit
) else (
    echo NFS share failed to remount. Trying again in 10 seconds...
    timeout /t 10
    goto remount
)

:exit
echo NFS share successfully mounted.
