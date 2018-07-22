::echo Checking windows architecture
::reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32 || set OS=64
::echo %OS% architecture detected
::echo.

::for /f "tokens=2 delims==" %%v in (
::  'wmic product where "Name like '%%MongoDB%%'" get version /format:list'
::) do set MONGOVER=%%v
::echo %MONGOVER%
::for /f "tokens=2 delims==" %%v in (
::  'wmic product where "Name like '%%Node%%'" get version /format:list'
::) do set NODEVER=%%v
::echo %NODEVER%

::wmic product where "Name like '%%MongoDB%%'" call uninstall /nointeractive

::echo Adding MongoDB tools to system path
::setx /M PATH "%PATH%;%ProgramFiles%\MongoDB\Server\bin\"

::echo Copying database configuration file
::xcopy /h /y "%~dp0bin\MongoDB\Server\mongod.conf" "%SystemDrive%\etc\"
::echo.

::echo Creating a service for MongoDB server
::"%ProgramFiles%\MongoDB\Server\bin\mongod.exe" --config "%SystemDrive%\etc\mongod.conf" --install
::sc query MongoDB
::IF ERRORLEVEL 1060 (
::  echo Service installation failed
::) else (
::  echo Service installed successfully
::)
::echo.
