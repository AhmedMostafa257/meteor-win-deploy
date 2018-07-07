@echo OFF

echo Setting up Meteor application
echo .............................
echo.

call "%~dp0cleanup.bat"

echo Detecting machine name
for /f "skip=1 delims=" %%A in (
  'wmic computersystem get name'
) do for /f "delims=" %%B in ("%%A") do set "compName=%%A"

echo Checking windows architecture
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
echo %OS% architecture detected
echo.

if %OS%==32BIT (
  echo Copying files
  xcopy /s/e /j /q /h /y "%~dp0x86" "%SystemDrive%\"
  echo.
)

if %OS%==64BIT (
  echo Copying files
  xcopy /s/e /j /q /h /y "%~dp0x64" "%SystemDrive%\"
  echo.
)

call "%~dp0installdeps.bat"

call "%~dp0bin\npm.bat"

echo Creating shortcuts
xcopy /h /y "%~dp0bin\Server.bat" "%userprofile%\Desktop\"
mklink "%userprofile%\Start Menu\Programs\Startup\Server.lnk" "%userprofile%\Desktop\Server.bat"
echo [InternetShortcut] > "%userprofile%\Desktop\Sys.url"
echo URL="http://localhost:8000" >> "%userprofile%\Desktop\Sys.url"
echo.

echo Finished
echo.
echo.
echo.

call "%userprofile%\Desktop\Server.bat"
