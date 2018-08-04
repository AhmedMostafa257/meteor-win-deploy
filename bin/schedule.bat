@echo off

schTasks /query /tn "MongoDB database continous backup" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo.
  echo Database backup task already exists
  echo.
  goto HELPERTASK
)
schTasks /create /tn "MongoDB database continous backup" /tr "wscript.exe %SystemDrive%\scripts\hide_backup.vbs" /sc HOURLY /mo 2 /ru "NT AUTHORITY\SYSTEM" /np /rl HIGHEST
echo.

:HELPERTASK
schTasks /query /tn "Meteor helper application" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo.
  echo Application auto-start task already exists
  echo.
  goto TASKSEND
)
schTasks /create /tn "Meteor helper application" /tr "wscript.exe %SystemDrive%\scripts\hide_helper.vbs" /sc ONSTART /ru "NT AUTHORITY\SYSTEM" /np /rl HIGHEST
echo.

:TASKSEND
echo.
echo Tasks creation ended
echo.

if not [%UNATTENDED%]==[] (
  if %UNATTENDED% EQU 0 pause
)
