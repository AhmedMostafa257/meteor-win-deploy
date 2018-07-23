@echo OFF

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

echo Checking windows architecture ...
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

cmd /c "%~dp0installdeps.bat"

if exist "%SystemDrive%\var\www\meteor\bundle\" (
  ren "%SystemDrive%\var\www\meteor\bundle\" "bundle_%TIMENOW%"
  goto COPYCOREFILES
)
if exist "%SystemDrive%\var\www\meteor\bundle.tar" (
  ren "%SystemDrive%\var\www\meteor\bundle.tar" "bundle_%TIMENOW%.tar"
  goto COPYCOREFILES
)
if exist "%SystemDrive%\var\www\meteor\bundle.tar.xz" (
  ren "%SystemDrive%\var\www\meteor\bundle.tar.xz" "bundle_%TIMENOW%.tar.xz"
  goto COPYCOREFILES
)
if exist "%SystemDrive%\var\www\meteor\bundle.7z" (
  ren "%SystemDrive%\var\www\meteor\bundle.7z" "bundle_%TIMENOW%.7z"
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
  7z x "%SystemDrive%\var\www\meteor\bundle.tar.xz"
  echo.
  echo Extracting {Stage 2} ...
  7z x "%SystemDrive%\var\www\meteor\bundle.tar"
  echo.
)
if exist "%SystemDrive%\var\www\meteor\bundle.7z" (
  echo Extracting ...
  7z x "%SystemDrive%\var\www\meteor\bundle.7z"
  echo.
)

echo Copying helper application files ...
xcopy /s /e /j /q /h /y "%~dp0helper\" "%SystemDrive%\helper\"

echo Creating scheduled tasks ...
cmd /c "%~dp0\bin\schedule.bat"

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
echo Setup completed and almost ready to run application
echo review steps above to be sure before proceed
echo.
echo ----------------------------------------------------

echo.
echo.
echo.

pause

cmd /c "%userprofile%\Desktop\Server.bat"

pause

exit /b
