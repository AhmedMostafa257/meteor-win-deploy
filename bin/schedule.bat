@echo off

schTasks /query /tn "MongoDB database continous backup" >nul 2>&1
if %ERRORLEVEL% EQU 0 goto HELPERTASK
schTasks /create /tn "MongoDB database continous backup" /tr "wscript.exe %SystemDrive%\scripts\hide_backup.vbs" /sc HOURLY /mo 2 /ru "NT AUTHORITY\SYSTEM" /np /rl HIGHEST

:HELPERTASK
schTasks /query /tn "Meteor helper application" >nul 2>&1
if %ERRORLEVEL% EQU 0 goto TASKSEND
schTasks /create /tn "Meteor helper application" /tr "wscript.exe %SystemDrive%\scripts\hide_helper.vbs" /sc ONSTART /ru "NT AUTHORITY\SYSTEM" /np /rl HIGHEST

:TASKSEND
echo.
echo Tasks creation ended
echo.

if %UNATTENDED% EQU 0 pause
