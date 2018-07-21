@echo OFF

echo Installing dependancies for Meteor application
echo ..............................................
echo.

echo Copying shared content
xcopy "%~dp0shared" "%SystemDrive%\" /s /e /t /q /h /y
echo.

echo Checking windows architecture
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32 || set OS=64
echo %OS% architecture detected
echo.

if %OS%==32 (
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
if %OS%==64 (
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

echo Copying database configuration file
  xcopy /h /y "%~dp0bin\MongoDB\Server\mongod.conf" "%SystemDrive%\etc\"
  echo.

  echo Creating a service for MongoDB server
  "%ProgramFiles%\MongoDB\Server\bin\mongod.exe" --config "%SystemDrive%\etc\mongod.conf" --install
  sc query MongoDB > nul
  IF ERRORLEVEL 1060 (
    echo Service installation failed
  ) else (
    echo Service installed successfully
  )
  echo.

echo Running database server
net start MongoDB
echo.

echo Adding MongoDB tools to system path
setx /M PATH "%PATH%;%ProgramFiles%\MongoDB\Server\bin\"

echo Setting environment variables
echo 1) Port
SETx PORT 8000 /M
echo 2) Mongo URL
SETx MONGO_URL "mongodb://localhost:27017/admin" /M
echo 3) Root URL
SETx ROOT_URL http://localhost /M
echo.

echo Dependancies installed
