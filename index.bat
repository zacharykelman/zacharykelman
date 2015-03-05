@echo off
COLOR 0A
echo.
:CHOICE
set nxt=0
set ric=0
echo Device type:
echo 1) Normal
echo 2) Special (for example: Sony Tablet S, Medion Lifetab)
echo 3) New Xperia Root by Goroh_kun (Xperia Z, Xperia V [JellyBean] ...)
echo.
echo x) Unroot
echo.
set /p type=Make a choice: 
if %type% == 1 GOTO TEST
if %type% == 2 GOTO TABSMENU
if %type% == 3 GOTO NEWROOT
if %type% == x GOTO UNROOT
echo.
echo Please Enter a valid number (1 to x)
echo.
GOTO CHOICE

:TEST
echo Checking if i should run in Normal Mode or special Sony Mode
echo Please connect your device with USB-Debugging enabled now
echo Waiting for device to shop up, if nothing happens please check if Windows ADB-drivers are installed correctly!
stuff\adb.exe wait-for-device
stuff\adb.exe pull /system/app/Backup-Restore.apk . > NUL
stuff\adb.exe pull /system/bin/ric . > NUL
if EXIST ric (set ric=1) else (echo .)
if EXIST Backup-Restore.apk (GOTO XPS) else (echo .)
echo Above file not found warning ARE NOT ERRORS, it is intended to be this way!
GOTO OTHER

:UNROOT
set /p unr=Really (y/n) ?
IF %unr% == n GOTO CHOICE
stuff\adb.exe push stuff\busybox /data/local/tmp/busybox
stuff\adb.exe shell "chmod 755 /data/local/tmp/busybox"
stuff\adb.exe shell "su -c '/data/local/tmp/busybox mount -o remount,rw /system'"
stuff\adb.exe shell "su -c 'rm /system/bin/su'"
stuff\adb.exe shell "su -c 'rm /system/xbin/su'"
stuff\adb.exe shell "su -c 'rm /system/app/Superuser.apk'"
stuff\adb.exe uninstall eu.chainfire.supersu
stuff\adb.exe uninstall com.noshufou.android.su
echo If it did not work correct please use the inbuild UNROOT/DEINSTALL function of Superuser / SuperSu
GOTO FINISH

:TABSMENU
echo.
echo Special mode:
echo 1) Root
echo 2) Rollback
set /p tabtype=Make a choice: 
if %tabtype% == 1 GOTO TABS
if %tabtype% == 2 GOTO TABS_RB

:TABS
echo.
echo Tablet S mode enabled!
echo.
GOTO START

:XPS
echo.
echo Found Sony Backup-Restore.apk
echo LT26,LT22 etc. mode enabled!
echo.
del Backup-Restore.apk
if %ric% == 1 (del ric) else (echo .)
set NXT=1
GOTO START

:TABS_RB
echo.
echo Tablet S Roll Back
echo.
echo Please connect device with ADB-Debugging enabled now....
stuff\adb.exe wait-for-device
FOR /F "tokens=1 delims=" %%A in ('stuff\adb.exe shell "if [ -d /data/app- ]; then echo 1 ; else echo 0 ; fi"') do SET tabs_app=%%A
if %tabs_app% == 1 GOTO TABS_RB_1
if %tabs_app% == 0 GOTO TABS_RB_2

:TABS_RB_1
stuff\adb.exe shell "rm -r /data/data/com.android.settings/a/*"
stuff\adb.exe restore stuff/tabletS.ab
echo Please look at your device and click "Restore my data"
echo.
stuff\adb.exe shell "while [ ! -d /data/data/com.android.settings/a/file99 ] ; do echo 1; done" > NUL
echo 1st RESTORE OK, hit ENTER to continue.
pause
stuff\adb.exe shell "rm -r /data/data/com.android.settings/a"
stuff\adb.exe restore stuff/tabletS.ab
echo Please look at your device and click "Restore my data"
echo.
stuff\adb.exe shell "while : ; do ln -s /data /data/data/com.android.settings/a/file99; [ -f /data/file99 ] && exit; done" > NUL
stuff\adb.exe shell "rm -r /data/file99"
echo Achieved! hit ENTER to continue.
echo.
pause
stuff\adb.exe shell "mv /data/system /data/system3"
stuff\adb.exe shell "mv /data/system- /data/system"
stuff\adb.exe shell "mv /data/app /data/app3"
stuff\adb.exe shell "mv /data/app- /data/app"
echo "Roll back compelted."
GOTO FINISH

:TABS_RB_2
echo.
echo.
echo "Roll back failed. /data/app- not found."
echo.
echo.
GOTO FINISH

:OTHER
echo.
echo Normal Mode enabled!
if %ric% == 1 (del ric) else (echo .)
echo.

:START
stuff\adb.exe wait-for-device
IF %type% == 2 GOTO TABTRICK
echo Pushing busybox....
stuff\adb.exe push stuff/busybox /data/local/tmp/.
echo Pushing su binary ....
stuff\adb.exe push stuff/su /data/local/tmp/.
stuff\adb.exe push stuff/.su /data/local/tmp/.su
:SUCHOICE
echo You want Superuser or SuperSU installed ?
echo 1) Superuser
echo 2) SuperSu
echo.
set /p type=Make a choice: 
if %type% == 1 GOTO SUPERUSER
if %type% == 2 GOTO SUPERSU
echo.
echo Please Enter a valid number (1 to x)
echo.
GOTO SUCHOICE
:SUPERUSER
echo Pushing Superuser app
stuff\adb.exe push stuff/Superuser.apk /data/local/tmp/.
GOTO CONTINUE
:SUPERSU
echo Pushing SuperSu app
stuff\adb.exe push stuff/SuperSu.apk /data/local/tmp/.
:CONTINUE
echo Making busybox runable ...
stuff\adb.exe shell chmod 755 /data/local/tmp/busybox
if %ric% == 1 (stuff\adb.exe push stuff/ric /data/local/tmp/ric) else (echo .)
IF %nxt% == 1 GOTO XPSTRICK
stuff\adb.exe restore stuff/fakebackup.ab
echo Please look at your device and click RESTORE!
echo If all is successful i will tell you, if not this shell will run forever.
echo Running ...
stuff\adb.exe shell "while ! ln -s /data/local.prop /data/data/com.android.settings/a/file99; do :; done" > NUL
echo Successful, going to reboot your device in 10 seconds!
ping -n 10 127.0.0.1 > NUL
stuff\adb.exe reboot
echo Waiting for device to show up again....
ping -n 10 127.0.0.1 > NUL
stuff\adb.exe wait-for-device
GOTO NORMAL

:TABTRICK
stuff\adb.exe install -s stuff/Term.apk
stuff\adb.exe push stuff/busybox /data/local/tmp/.
stuff\adb.exe push stuff/su /data/local/tmp/.
stuff\adb.exe push stuff/Superuser.apk /data/local/tmp/.
stuff\adb.exe push stuff/rootkittablet.tar.gz /data/local/tmp/rootkittablet.tar.gz
stuff\adb.exe shell "chmod 755 /data/local/tmp/busybox"
stuff\adb.exe shell "/data/local/tmp/busybox tar -C /data/local/tmp -x -v -f /data/local/tmp/rootkittablet.tar.gz"
stuff\adb.exe shell "chmod 644 /data/local/tmp/VpnFaker.apk"
stuff\adb.exe shell "touch -t 1346025600 /data/local/tmp/VpnFaker.apk"
stuff\adb.exe shell "chmod 755 /data/local/tmp/_su"
stuff\adb.exe shell "chmod 755 /data/local/tmp/su"
stuff\adb.exe shell "chmod 755 /data/local/tmp/onload.sh"
stuff\adb.exe shell "chmod 755 /data/local/tmp/onload2.sh"
stuff\adb.exe shell "rm -r /data/data/com.android.settings/a/*"
stuff\adb.exe restore stuff/tabletS.ab
echo Please look at your device and click "Restore my data"
echo.
stuff\adb.exe shell "while [ ! -d /data/data/com.android.settings/a/file99 ] ; do echo 1; done" > NUL
ping -n 3 127.0.0.1 > NUL
echo 1st RESTORE OK, hit ENTER to continue.
pause
stuff\adb.exe shell "rm -r /data/data/com.android.settings/a"
stuff\adb.exe restore stuff/tabletS.ab
echo Please look at your device and click "Restore my data"
echo.
stuff\adb.exe shell "while : ; do ln -s /data /data/data/com.android.settings/a/file99; [ -f /data/file99 ] && exit; done" > NUL
stuff\adb.exe shell "rm -r /data/file99"
ping -n 3 127.0.0.1 > NUL
echo Achieved! hit ENTER to continue.
echo.
pause
stuff\adb.exe shell "/data/local/tmp/busybox cp -r /data/system /data/system2"
stuff\adb.exe shell "/data/local/tmp/busybox find /data/system2 -type f -exec chmod 666 {} \;"
stuff\adb.exe shell "/data/local/tmp/busybox find /data/system2 -type d -exec chmod 777 {} \;"
stuff\adb.exe shell "mv /data/system /data/system-"
stuff\adb.exe shell "mv /data/system2 /data/system"
stuff\adb.exe shell "mv /data/app /data/app-"
stuff\adb.exe shell "mkdir /data/app"
stuff\adb.exe shell "mv /data/local/tmp/VpnFaker.apk /data/app"
stuff\adb.exe shell "/data/local/tmp/busybox sed -f /data/local/tmp/packages.xml.sed /data/system-/packages.xml > /data/system/packages.xml"
stuff\adb.exe shell "sync; sync; sync"
echo Need to reboot now!
stuff\adb.exe reboot
ping -n 3 127.0.0.1 > NUL
echo Waiting for device to come up again....
stuff\adb.exe wait-for-device
echo Unlock your device, a Terminal will show now, type this 2 lines, after each line press ENTER
echo /data/local/tmp/onload.sh
echo /data/local/tmp/onload2.sh
echo after this is done press a key here in this shell to continue!
echo If the shell on your device does not show please re-start the process!
stuff\adb.exe shell "am start -n com.android.vpndialogs/.Term"
pause
GOTO TABTRICK1

:TABTRICK1
stuff\adb.exe push stuff/script1.sh /data/local/tmp/.
stuff\adb.exe shell "chmod 755 /data/local/tmp/script1.sh"
stuff\adb.exe shell "/data/local/tmp/script1.sh"
echo Almost complete! Reboot and cleanup.
stuff\adb.exe reboot
ping -n 3 127.0.0.1 > NUL
echo Waiting for device to come up again....
stuff\adb.exe wait-for-device
stuff\adb.exe shell "su -c 'rm -r /data/app2'"
stuff\adb.exe shell "su -c 'rm -r /data/system2'"
stuff\adb.exe shell "su -c 'rm -r /data/local/tmp/*'"
GOTO FINISH

:XPSTRICK
set %NXT%=0
echo Pushing fake Backup
stuff\adb.exe push stuff\RootMe.tar /data/local/tmp/RootMe.tar
stuff\adb.exe shell "mkdir /mnt/sdcard/.semc-fullbackup > /dev/null 2>&1"
echo Extracting fakebackup on device ...
stuff\adb.exe shell "cd /mnt/sdcard/.semc-fullbackup/; /data/local/tmp/busybox tar xf /data/local/tmp/RootMe.tar"
echo Watch now your device. Select the backup named RootMe and restore it!
stuff\adb.exe shell "am start com.sonyericsson.vendor.backuprestore/.ui.BackupActivity"
echo If all is successful i will tell you, if not this shell will run forever.
echo Running ......
stuff\adb.exe shell "while ! ln -s /data/local.prop /data/data/com.android.settings/a/file99; do :; done" > NUL
echo.
echo Good, it worked! Now we are rebooting soon, please be patient!
ping -n 3 127.0.0.1 > NUL
stuff\adb.exe shell "rm -r /mnt/sdcard/.semc-fullbackup/RootMe"
stuff\adb.exe reboot
ping -n 10 127.0.0.1 > NUL
echo Waiting for device to come up again....
stuff\adb.exe wait-for-device

:NORMAL
IF %ric% == 1 GOTO RICSTUFF
echo Going to copy files to it's place
stuff\adb.exe shell "/data/local/tmp/busybox mount -o remount,rw /system && /data/local/tmp/busybox mv /data/local/tmp/su /system/xbin/su && /data/local/tmp/busybox mkdir /system/bin/.ext && /data/local/tmp/busybox mv /data/local/tmp/.su /system/bin/.ext/.su && /data/local/tmp/busybox mv /data/local/tmp/Superuser.apk /system/app/Superuser.apk && /data/local/tmp/busybox cp /data/local/tmp/busybox /system/xbin/busybox && chown 0.0 /system/xbin/su && chmod 06755 /system/xbin/su && chmod 655 /system/app/Superuser.apk && chmod 755 /system/xbin/busybox && rm /data/local.prop && reboot"
GOTO FINISH

:RICSTUFF
echo Going to copy files to it's place
stuff\adb.exe shell "/data/local/tmp/busybox mount -o remount,rw /system && /data/local/tmp/busybox mv /data/local/tmp/ric /system/bin/ric && chmod 755 /system/bin/ric && /data/local/tmp/busybox mv /data/local/tmp/su /system/xbin/su && /data/local/tmp/busybox mkdir /system/bin/.ext && /data/local/tmp/busybox mv /data/local/tmp/.su /system/bin/.ext/.su && /data/local/tmp/busybox mv /data/local/tmp/Superuser.apk /system/app/Superuser.apk && /data/local/tmp/busybox cp /data/local/tmp/busybox /system/xbin/busybox && chown 0.0 /system/xbin/su && chmod 06755 /system/xbin/su && chmod 655 /system/app/Superuser.apk && chmod 755 /system/xbin/busybox && rm /data/local.prop && reboot"
GOTO FINISH

:NEWROOT
echo Please connect Xperia device with enabled USB-Debugging now to your Computer
stuff\adb.exe wait-for-device
echo Going to copy over some files ...
stuff\adb.exe push stuff/onload.sh /data/local/tmp/
stuff\adb.exe shell "chmod 755 /data/local/tmp/onload.sh"
stuff\adb.exe push z_rootkit/getroot.sh /data/local/tmp/
stuff\adb.exe push stuff/ric /data/local/tmp/ric
stuff\adb.exe shell "chmod 755 /data/local/tmp/getroot.sh"
echo Starting restore operation, please look on your device and confirm restore!
echo after that press anykey here in the console
stuff\adb.exe restore z_rootkit/usbux.ab
pause
echo After restore is confirmed please look on your device and choose "Service Tests -> Display" in Service menu and WAIT THERE!"
stuff\adb.exe shell "am start -a android.intent.action.MAIN -n com.sonyericsson.android.servicemenu/.ServiceMainMenu"
echo /data/local/tmp/onload.sh ...
stuff\adb.exe shell "while : ; do [ -w /sys/kernel/uevent_helper ] && exit; done"
stuff\adb.exe shell "echo /data/local/tmp/getroot.sh > /sys/kernel/uevent_helper"
echo Ok nice ...
stuff\adb.exe shell "while : ; do [ -f /dev/sh ] && exit; done"
stuff\adb.exe push stuff/busybox-armv6l /data/local/tmp/busybox
echo Stopping RIC
stuff\adb.exe push stuff/install-recovery.sh /data/local/tmp/
stuff\adb.exe push stuff/step2.sh /data/local/tmp/
stuff\adb.exe push stuff/step3.sh /data/local/tmp/
stuff\adb.exe push stuff/libservicemenu.so /data/local/tmp/
echo Pushing su ...
stuff\adb.exe push stuff/su /data/local/tmp/
stuff\adb.exe push stuff/.su /data/local/tmp/.su
stuff\adb.exe shell "chmod 777 /data/local/tmp/step2.sh"
stuff\adb.exe shell "chmod 777 /data/local/tmp/step3.sh"
echo Running next steps
stuff\adb.exe shell "/dev/sh /data/local/tmp/step2.sh"
:SUCHOICE2
echo You want Superuser or SuperSU installed ?
echo 1) Superuser
echo 2) SuperSu
echo.
set /p type=Make a choice: 
if %type% == 1 GOTO SUPERUSER2
if %type% == 2 GOTO SUPERSU2
echo.
echo Please Enter a valid number (1 to x)
echo.
GOTO SUCHOICE2
:SUPERUSER2
echo Pushing Superuser app
stuff\adb.exe install stuff/Superuser.apk
GOTO CONTINUE
:SUPERSU2
echo Pushing SuperSu app
stuff\adb.exe install stuff/SuperSu.apk
:CONTINUE2
echo Running final step
stuff\adb.exe shell "/dev/sh /data/local/tmp/step3.sh"
echo Cleaning up
stuff\adb.exe shell "rm /data/local/tmp/busybox"
stuff\adb.exe shell "rm /data/local/tmp/install-recovery.sh"
stuff\adb.exe shell "rm /data/local/tmp/step2.sh"
stuff\adb.exe shell "rm /data/local/tmp/su"
stuff\adb.exe shell "rm /data/local/tmp/.su"
stuff\adb.exe shell "rm /data/local/tmp/onload.sh"
stuff\adb.exe shell "rm /data/local/tmp/getroot.sh"
echo Ok rebooting lets hope it worked!
stuff\adb.exe reboot

:FINISH
echo You can close all open command-prompts now!
echo After reboot all is done! Have fun!
echo Bin4ry
pause
