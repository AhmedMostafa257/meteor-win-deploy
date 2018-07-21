@echo OFF

echo Starting Meteor.JS application server
echo ....................................
echo.

set /A SRVTRY=1

echo Checking MongoDB service
echo Checking if service exists
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  echo MongoDB service not found
  echo Run checks first or installdeps from meteor install patch repository
  exit /b
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
      exit /b
    )
  ) else echo MongoDB service running
)
echo.

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set FILENAME=%mydate%_%mytime%

if exist "C:\var\www\meteor\bundle\programs\server" goto INSTALLNPM
echo Applcation core files do not exist
exit /b
:INSTALLNPM
c:
cd "C:\var\www\meteor\bundle\programs\server"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit

cd ..\..
node "%SystemDrive%\var\www\meteor\bundle\main.js"
