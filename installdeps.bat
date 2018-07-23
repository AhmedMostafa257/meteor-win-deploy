@echo OFF

echo.
echo.
echo.

echo Installing dependancies for Meteor application
echo ..............................................
echo.

::if exist "%SystemDrive%\etc\labox\helper-config.json" goto FINISH
::else goto COPYCFG

::COPYCFG
::echo Copying helper configuration file ...
::xcopy /h /y "%~dp0bin\helper-config.json" "%SystemDrive%\etc\labox"

echo Copying shared content
xcopy "%~dp0shared" "%SystemDrive%\" /s /e /t /q /h
echo.

echo Checking windows architecture
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

if %OS%==x86 (
  echo Installing 32-bit dependancies
  for %%i in ("%~dp0sources\x86\*.msi") do (
    for %%f in (%%i) do (
      echo Installing %%~nf
    )
    msiexec /i %%i /qf /norestart
  )
  echo.

  for %%i in ("%~dp0sources\x86\*.exe") do (
    echo Installing %%i
    start %%i
  )
  echo.
)
if %OS%==x64 (
  echo Installing 64-bit dependancies
  for %%i in ("%~dp0sources\x64\*.msi") do (
    for %%f in (%%i) do (
      echo Installing %%~nf
    )
    msiexec /i %%i /qf /norestart
  )
  echo.

  for %%i in ("%~dp0sources\x64\*.exe") do (
    echo Installing %%i
    start %%i
  )
  echo.
)

if exist "%SystemDrive%\etc\mongod.conf" goto CHECKSRV

echo Copying database configuration file
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
echo Creating a service for MongoDB server
"%ProgramFiles%\MongoDB\Server\bin\mongod.exe" --config "%SystemDrive%\etc\mongod.conf" --install
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  echo Service installation failed
) else (
  echo Service installed successfully
)
echo.

:ADDENVVARS
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

echo Setting environment variables ...
if %PORT% equ 8000 goto SETMONGOURLVAR
echo 1- Port
setx PORT 8000 /M
:SETMONGOURLVAR
if %MONGO_URL% == "" (
  echo 2- Mongo URL
  setx MONGO_URL "mongodb://localhost:27017/admin" /M
)
if /I %ROOT_URL% == "http://localhost" goto OPENPORTS
echo 3- Root URL
setx ROOT_URL "http://localhost" /M
echo.

:OPENPORTS
echo Opening ports in firewall ...
echo 1- Sync app inbound role
netsh advfirewall firewall add rule name="Meteor helper sync" dir=in action=allow protocol=TCP localport=2717
echo 2- Sync app outbound role
netsh advfirewall firewall add rule name="Meteor helper sync" dir=out action=allow protocol=TCP localport=2717
echo 3- MongoDB inbound role
netsh advfirewall firewall add rule name="MongoDB" dir=in action=allow protocol=TCP localport=27017
echo 4- MongoDB outbound role
netsh advfirewall firewall add rule name="MongoDB" dir=out action=allow protocol=TCP localport=27017
echo.

echo Updating NPM ...
cmd /c npm i -g npm
echo Installing forever ...
cmd /c npm i -g forever
echo.

echo Meteor.JS application dependancies setup completed

echo.
echo.
echo.

echo ----------------------------------------------------
echo.
echo Setup completed and almost ready to copy and
echo extract core application files to default paths
echo review steps above to be sure before proceed
echo.
echo ----------------------------------------------------

echo.
echo.
echo.

pause
