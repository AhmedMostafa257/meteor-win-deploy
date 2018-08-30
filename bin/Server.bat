@echo OFF

echo Starting Meteor.JS application server
echo ....................................
echo.

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

set "APPNAME=meteor"
set %APPTITLE%=MeteorJS
:FINDINSTALLDIR
set "INSTALLDIR=%SystemDrive%\var\www\meteor"
for /f "usebackq eol=H tokens=2*" %%D IN (`reg query "HKLM\SOFTWARE\%APPTITLE%\%APPNAME%" /v InstallDir`) do (
  set INSTALLDIR=%%E
)

set /A HELPER=0
for /f "usebackq skip=2 tokens=2*" %%D IN (`reg query "HKLM\SOFTWARE\%APPTITLE%\%APPNAME%" /v Helper`) do (
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
