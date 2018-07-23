@echo OFF

cls

echo.
echo.
echo.

echo Setting up Meteor application
echo .............................
echo.

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set TIMENOW=%mydate%_%mytime%

::call "%~dp0cleanup.bat"

::echo Detecting machine name
::for /f "skip=1 delims=" %%A in (
::  'wmic computersystem get name'
::) do for /f "delims=" %%B in ("%%A") do set "compName=%%A"

echo Copying helper application files ...
xcopy /s /e /j /h /y "%~dp0helper\" "%SystemDrive%\helper\"
echo.

echo Copying scripting files ...
for %%i in ("%~dp0bin\*.bat") do (
  xcopy /s /e /j /h /y %%i "%SystemDrive%\scripts\"
)
for %%i in ("%~dp0bin\*.vbs") do (
  xcopy /s /e /j /h /y %%i "%SystemDrive%\scripts\"
)
echo.

echo Checking windows architecture ...
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

cmd /c "%~dp0installdeps.bat"

if exist "%SystemDrive%\var\www\meteor\bundle\" (
  echo Bundle folder exists
  echo Renaming ...
  ren "%SystemDrive%\var\www\meteor\bundle\" "bundle_%TIMENOW%"
  echo.
  goto COPYCOREFILES
)
if exist "%SystemDrive%\var\www\meteor\bundle.tar" (
  echo Bundle tar archive exists
  echo Renaming ...
  ren "%SystemDrive%\var\www\meteor\bundle.tar" "bundle_%TIMENOW%.tar"
  echo.
  goto COPYCOREFILES
)
if exist "%SystemDrive%\var\www\meteor\bundle.tar.xz" (
  echo Bundle tar.xz archive exists
  echo Renaming ...
  ren "%SystemDrive%\var\www\meteor\bundle.tar.xz" "bundle_%TIMENOW%.tar.xz"
  echo.
  goto COPYCOREFILES
)
if exist "%SystemDrive%\var\www\meteor\bundle.7z" (
  echo Bundle 7z archive exists
  echo Renaming ...
  ren "%SystemDrive%\var\www\meteor\bundle.7z" "bundle_%TIMENOW%.7z"
  echo.
  goto COPYCOREFILES
)

:COPYCOREFILES
echo Copying application core files ...
if %OS%==x86 (
  xcopy /s/e /j /q /h /y "%~dp0x86" "%SystemDrive%\"
)
if %OS%==x64 (
  xcopy /s/e /j /q /h /y "%~dp0x64" "%SystemDrive%\"
)
cd "%SystemDrive%\var\www\meteor\"
if exist "%SystemDrive%\var\www\meteor\bundle.tar.xz" (
  echo Extracting {Stage 1} ...
  start cmd /k 7z x "%SystemDrive%\var\www\meteor\bundle.tar.xz"
  echo.
  echo Extracting {Stage 2} ...
  start cmd /k 7z x "%SystemDrive%\var\www\meteor\bundle.tar"
  echo.
)
if exist "%SystemDrive%\var\www\meteor\bundle.7z" (
  echo Extracting ...
  start cmd /k 7z x "%SystemDrive%\var\www\meteor\bundle.7z"
  echo.
)

echo Creating scheduled tasks ...
cmd /c "%~dp0\bin\schedule.bat"
echo.

::call "%~dp0bin\npm.bat"

echo Creating shortcuts ...
xcopy /h /y "%~dp0bin\Server.bat" "%userprofile%\Desktop\"
::mklink "%userprofile%\Start Menu\Programs\Startup\Server.lnk" "%userprofile%\Desktop\Server.bat"
echo [InternetShortcut] > "%userprofile%\Desktop\Sys.url"
echo URL="http://localhost:8000" >> "%userprofile%\Desktop\Sys.url"
echo.

echo Finished

echo.
echo.
echo.

echo ----------------------------------------------------
echo.
echo Setup completed and will restart computer
echo review steps above to be sure before proceed
echo.
echo ----------------------------------------------------

echo.
echo.
echo.

pause

::cmd /c "%userprofile%\Desktop\Server.bat"
shutdown /r /t 0
