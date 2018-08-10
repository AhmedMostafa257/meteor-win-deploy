@echo off

echo.
echo Checking windows architecture ...
echo.
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

echo.
echo Detecting machine name ...
echo.
for /f "skip=1 delims=" %%A in ('wmic computersystem get name') do (
    for /f "delims=" %%B in ("%%A") do set "COMPNAME=%%A"
)
echo Computer name detected: %COMPNAME%
echo.

echo.
echo Checking helper cache file ...
echo.
type c:\etc\labox\cache.json
echo.

echo.
echo Checking helper config file ...
echo.
type c:\etc\labox\helper-config.json
echo.

echo.
echo Checking MongoDB config file ...
echo.
type c:\etc\mongod.conf
echo.

echo.
echo Checking MongoDB service existance ...
echo.
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  echo MongoDB service not found
  echo Run checks first or installdeps from meteor install patch repository
  exit /b
) else echo MongoDB service found
echo.

echo.
echo Checking if MongoDB service is running ...
echo.
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
  ) else echo MongoDB service is running
)
echo.

echo.
echo Checking local IP addresses ...
echo.
ipconfig | findstr /i "ipv4"
echo.

echo.
echo Checking MongoDB tools existance in windows PATH ...
echo.
set path | findstr /i "mongodb"
if ERRORLEVEL EQU 0 (
    echo MongoDB tools exists in PATH
) else echo MongoDB tools not found in PATH
echo.

echo.
echo Checking Replica set status ...
echo.
mongo --eval "rs.status();"
echo.
