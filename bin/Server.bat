@echo OFF

echo Starting Meteor.JS application server
echo ....................................
echo.

for /F "usebackq tokens=*" %%G in (
  `wmic process where "CommandLine like '%%Server.bat%%' AND Caption like '%%cmd.exe%%'" get ProcessID/value ^| find /I "="`
) do (
  if not exist "%SystemDrive%\scripts\pids\" mkdir "%SystemDrive%\scripts\pids\"
  for /F "tokens=2 delims==" %%H in ("%%~G") do echo %%H >> "%SystemDrive%\scripts\pids\%%H"
)

set /A SRVTRY=1

echo Checking MongoDB service
echo Checking if service exists
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  echo.
  echo MongoDB service not found
  echo Run checks first or installdeps from meteor install patch repository
  echo.
  exit
) else echo MongoDB service found
echo.

:CHECKSRV
echo Checking if service is running
for /F "tokens=3 delims=: " %%H in ('sc query "MongoDB" ^| findstr "        STATE"') do (
  if /I "%%H" NEQ "RUNNING" (
    set /A SRVTRY+=1
    if /I %SRVTRY% LEQ 10 (
      echo MongoDB service not started
      echo Starting MongoDB service {Try no. %SRVTRY%} ...
      net start MongoDB
      goto CHECKSRV
    ) else (
      echo MongoDB service failed to start %SRVTRY% times
      exit
    )
  ) else echo MongoDB service running
)
echo.

::for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
::for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
::set FILENAME=%mydate%_%mytime%

set "APPNAME=CosmosLabs"
reg query "HKLM\SOFTWARE\Cosmos Labs\LaBox" >nul
if %ERRORLEVEL% EQU 0 (
  set APPNAME=LaBox
  goto FINDINSTALLDIR
)
reg query "HKLM\SOFTWARE\Cosmos Labs\HosBox" >nul
if %ERRORLEVEL% EQU 0 (
  set APPNAME=HosBox
  goto FINDINSTALLDIR
)
reg query "HKLM\SOFTWARE\Cosmos Labs\GiveBox" >nul
if %ERRORLEVEL% EQU 0 (
  set APPNAME=GiveBox
  goto FINDINSTALLDIR
)
reg query "HKLM\SOFTWARE\Cosmos Labs\PharmBox" >nul
if %ERRORLEVEL% EQU 0 (
  set APPNAME=PharmBox
  goto FINDINSTALLDIR
)
reg query "HKLM\SOFTWARE\Cosmos Labs\IOBox" >nul
if %ERRORLEVEL% EQU 0 (
  set APPNAME=IOBox
  goto FINDINSTALLDIR
)

:FINDINSTALLDIR
set "INSTALLDIR=%SystemDrive%\var\www\meteor"
for /f "usebackq eol=H tokens=2*" %%D IN (`reg query "HKLM\SOFTWARE\Cosmos Labs\%APPNAME%" /v InstallDir`) do (
  set INSTALLDIR=%%E
)

set /A HELPER=0
for /f "usebackq skip=2 tokens=2*" %%D IN (`reg query "HKLM\SOFTWARE\Cosmos Labs\%APPNAME%" /v Helper`) do (
  set /A HELPER=%%E
)

if exist "%INSTALLDIR%\bundle\programs\server" goto CHECKHELPER
echo Application core files do not exist
pause
exit

:CHECKHELPER
if %HELPER% EQU 0 goto RUNAPP
if exist "%SystemDrive%\helper" goto RUNAPP
echo Helper application files do not exist
pause
exit

:RUNAPP
if %HELPER% EQU 0 (
  cd "%INSTALLDIR%\bundle"
  node main.js
) else (
  cd "%SystemDrive%\helper\"
  node dist\main.js
)

goto CHECKSRV
