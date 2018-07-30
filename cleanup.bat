@echo OFF

cls

echo.
echo Cleaning up Meteor application installation
echo ...........................................
echo.

echo Deleteing old files and folders
del /s /q /Q %SystemDrive%\var\* >nul 2>&1
RMDIR /S /Q %SystemDrive%\var
del /s /q /Q %SystemDrive%\etc\* >nul 2>&1
RMDIR /S /Q %SystemDrive%\etc
echo.

echo Checking windows architecture
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
echo %OS% architecture detected
echo.

if %OS%==32BIT (
  echo Finishing database configuration
  "%ProgramFiles%\MongoDB\Server\3.2\bin\mongod.exe" --remove
  sc query MongoDB
  IF ERRORLEVEL 1060 (
    echo Service removed
  ) else (
    echo Service removal failed
  )
)
if %OS%==64BIT (
  echo Finishing database configuration
  "%ProgramFiles%\MongoDB\Server\3.6\bin\mongod.exe" --remove
  sc query MongoDB
  IF ERRORLEVEL 1060 (
    echo Service removed
  ) else (
    echo Service removal failed
  )
  echo.
)

echo Removing old version of MongoDB
wmic product where "Name like '%%MongoDB%%'" call uninstall /nointeractive
echo Removing old version of NodeJS
wmic product where name="Node.js" call uninstall /nointeractive
echo.

echo Removing old database configuration files
del /F /Q "%ProgramFiles%\MongoDB\Server\3.2\mongod.cfg"
del /F /Q "%ProgramFiles%\MongoDB\Server\3.4\mongod.cfg"
del /F /Q "%ProgramFiles%\MongoDB\Server\3.6\mongod.cfg"
echo.

::del /F /Q "%SystemDrive%\data\db\*.*"

echo Deleteing shortcuts
del /F /Q "%userprofile%\Desktop\Server.bat"
del /F /Q "%userprofile%\Start Menu\Programs\Startup\Server.lnk"
del /F /Q "%userprofile%\Desktop\Sys.lnk"
del /F /Q "%userprofile%\Desktop\Sys.url"
echo.

echo Cleaning finished

echo.
echo.
echo.

pause
