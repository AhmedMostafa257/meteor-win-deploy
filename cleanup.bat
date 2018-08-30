@echo OFF

if [%UNATTENDED%]=[] cls

echo.
echo Cleaning up Meteor application installation
echo ...........................................
echo.

echo.
echo Deleteing old files and folders ...
echo.
del /F /Q %SystemDrive%\var\* >nul 2>&1
RMDIR /S /Q %SystemDrive%\var
del /F /Q %SystemDrive%\etc\* >nul 2>&1
RMDIR /S /Q %SystemDrive%\etc
del /F /Q %SystemDrive%\scripts\* >nul 2>&1
RMDIR /S /Q %SystemDrive%\scripts
echo.

echo.
echo Checking windows architecture ...
echo.
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

echo.
echo Finishing database configuration ...
echo.
mongod --remove
sc query MongoDB
IF ERRORLEVEL 1060 (
  echo Service removed
) else echo Service removal failed
echo.

echo.
echo Removing old version of MongoDB ...
wmic product where "Name like '%%MongoDB%%'" call uninstall /nointeractive
echo Removing old version of NodeJS ...
wmic product where name="Node.js" call uninstall /nointeractive
echo.

echo.
echo Removing old database engine folder ...
rmdir /S /Q "%ProgramFiles%\MongoDB"
echo.

if not [%1]==[] del /F /Q "%SystemDrive%\data\db\*.*"

echo.
echo Deleting registry values ...
echo.
REG DELETE "HKLM\SOFTWARE\Cosmos Labs"
echo.

echo Deleteing shortcuts
del /F /Q "%userprofile%\Desktop\Server.bat"
del /F /Q "%userprofile%\Start Menu\Programs\Startup\Server.lnk"
del /F /Q "%userprofile%\Desktop\Sys.lnk"
del /F /Q "%userprofile%\Desktop\Sys.url"
del /F /Q "%SystemDrive%\Users\Public\Desktop\Server.lnk"
del /F /Q "%SystemDrive%\Users\Public\Desktop\Sys.url"
echo.

echo Cleaning finished

echo.
echo.
echo.

if %UNATTENDED% EQU 0 pause
