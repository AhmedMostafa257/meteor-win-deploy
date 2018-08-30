@echo OFF

echo.
echo.
echo.

echo Installing dependancies for Meteor application
echo ..............................................
echo.

echo Copying shared content ...
if [%UNATTENDED%]==[] (
  goto ASKFILES
) else goto CHECKUNATTENDED

:CHECKUNATTENDED
if %UNATTENDED% EQU 0 (
  goto ASKFILES
) else goto OVERWRITEFILES

:ASKFILES
xcopy "%~dp0shared" "%SystemDrive%\" /s /e /h
goto CHECKARCH
:OVERWRITEFILES
xcopy "%~dp0shared" "%SystemDrive%\" /s /e /h /y
echo.

:CHECKARCH
echo Checking windows architecture ...
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

if %OS%==x86 (
  echo Installing 32-bit dependancies ...
  for %%i in ("%~dp0sources\x86\*.msi") do (
    for %%f in (%%i) do (
      echo.
      echo Installing %%~nf ...
      echo.
    )
    msiexec /i %%i /qn /norestart
  )
  echo.

  for %%i in ("%~dp0sources\x86\*.exe") do (
    echo Installing %%i ...
    start /wait %%i
  )
  echo.
)
if %OS%==x64 (
  echo Installing 64-bit dependancies ...
  for %%i in ("%~dp0sources\x64\*.msi") do (
    for %%f in (%%i) do (
      echo.
      echo Installing %%~nf ...
      echo.
    )
    msiexec /i %%i /qn /norestart
  )
  echo.

  for %%i in ("%~dp0sources\x64\*.exe") do (
    echo Installing %%i ...
    start /wait %%i
  )
  echo.
)

echo Adding MongoDB tools to system path ...
::if "!PATH:%ProgramFiles%\MongoDB\Server\bin\=!" equ "%PATH%" (
   setx PATH "%PATH%;%ProgramFiles%\MongoDB\Server\bin\"
::)
::if "!PATH:%ProgramFiles%\MongoDB\Server\3.2\bin\=!" equ "%PATH%" (
   setx PATH "%PATH%;%ProgramFiles%\MongoDB\Server\3.2\bin\"
::)
::if "!PATH:%ProgramFiles%\MongoDB\Server\3.4\bin\=!" equ "%PATH%" (
   setx PATH "%PATH%;%ProgramFiles%\MongoDB\Server\3.4\bin\"
::)
::if "!PATH:%ProgramFiles%\MongoDB\Server\3.6\bin\=!" equ "%PATH%" (
   setx PATH "%PATH%;%ProgramFiles%\MongoDB\Server\3.6\bin\"
::)
echo.
echo Adding 7-Zip to system path ...
::if "!PATH:%ProgramFiles%\7-Zip\=!" equ "%PATH%" (
   setx PATH "%PATH%;%ProgramFiles%\7-Zip\"
::)
echo.

if exist "%SystemDrive%\etc\mongod.conf" goto CHECKSRV

echo Copying database configuration file ...
if %OS%==x64 (
  xcopy /h /y "%~dp0bin\MongoDB\Server\mongod.conf" "%SystemDrive%\etc\"
) else xcopy /h /y "%~dp0bin\MongoDB\Server\mampv2\mongod.conf" "%SystemDrive%\etc\"
echo.

:CHECKSRV
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  goto CREATESRV
) else goto ADDENVVARS

:CREATESRV
echo Creating a service for MongoDB server ...
mongod --config "%SystemDrive%\etc\mongod.conf" --install
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  echo Service installation failed
) else (
  echo Service installed successfully
)
echo.

:ADDENVVARS
echo Setting environment variables ...
echo 1- Port
if not defined PORT setx PORT 8000 /M
echo %PORT%
echo 2- Mongo URL
if not defined MONGO_URL setx MONGO_URL "mongodb://127.0.0.1:27017/admin" /M
echo %MONGO_URL%
echo 3- Root URL
if not defined ROOT_URL setx ROOT_URL "http://localhost" /M
echo %ROOT_URL%
echo.


:OPENPORTS
wmic service where "Caption like '%%firewall%%'" get state | findstr /i "running" >nul
if %ERRORLEVEL% GTR 0 (
  echo.
  echo Windows Firewall service is not running
  echo no need to open ports
  echo.
  goto FINISH
)
echo.
echo Opening ports in firewall ...
echo.
if %HELPER% EQU 1 (
  echo Sync app roles
  netsh advfirewall firewall show rule name="Meteor helper sync" >nul
  if not %ERRORLEVEL% == 0 (
    echo.
    echo Adding roles ...
    echo.
    netsh advfirewall firewall add rule name="Meteor helper sync" dir=in action=allow protocol=TCP localport=2717
    netsh advfirewall firewall add rule name="Meteor helper sync" dir=out action=allow protocol=TCP localport=2717
  ) else echo Already exists
  echo MongoDB roles
  netsh advfirewall firewall show rule name="MongoDB">nul
  if not %ERRORLEVEL% == 0 (
    echo.
    echo Adding roles ...
    echo.
    netsh advfirewall firewall add rule name="MongoDB" dir=in action=allow protocol=TCP localport=27017
    netsh advfirewall firewall add rule name="MongoDB" dir=out action=allow protocol=TCP localport=27017
  ) else echo Already exists
)
echo MeteorJS server roles
  netsh advfirewall firewall show rule name="MeteorJS">nul
  if not %ERRORLEVEL% == 0 (
    echo.
    echo Adding roles ...
    echo.
    netsh advfirewall firewall add rule name="MeteorJS" dir=in action=allow protocol=TCP localport=8000
    netsh advfirewall firewall add rule name="MeteorJS" dir=out action=allow protocol=TCP localport=8000
  ) else echo Already exists
echo.

:FINISH
echo.
echo.
echo.

echo ----------------------------------------------------
echo.
echo Meteor.JS application dependancies setup
echo completed and almost ready to copy and
echo extract core application files to default paths
echo review steps above to be sure before proceed
echo.
echo ----------------------------------------------------

echo.
echo.
echo.

if defined %UNATTENDED% if %UNATTENDED% EQU 0 pause
