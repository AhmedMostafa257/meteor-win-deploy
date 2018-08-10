@echo OFF

echo Backup MongoDB database process
echo ...............................
echo.

set /A SRVTRY=1
set /A BACTRY=0

echo.
echo Checking MongoDB service existance ...
echo.
sc query MongoDB > nul
if ERRORLEVEL 1060 (
  echo MongoDB service not found
  echo Run checks first or installdeps from meteor install patch repository
  exit
) else echo MongoDB service found
echo.

:CHECKSRV
echo.
echo Checking if service is running ...
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
      exit
    )
  ) else echo MongoDB service running
)
echo.

echo.
echo Checking MongoDB tools existance in windows PATH ...
echo.
set path | findstr /i "mongodb"
if ERRORLEVEL EQU 0 (
    echo MongoDB tools exists in PATH
) else echo MongoDB tools not found in PATH
echo.

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set DUMPFILENAME=%mydate%_%mytime%

if exist "%SystemDrive%\db_backups" goto BACKUP
echo Backups directory not found
echo Creating new directory for backups ...
mkdir "%SystemDrive%\db_backups"
echo.

:BACKUP
echo.
echo Begin backup procedure
set /A BACTRY+=1
echo Running backup database {Try no. %BACTRY%} ...
if exist "%SystemDrive%\db_backups\%DUMPFILENAME%.gz" (
  echo Recent backup exists
  echo Renaming file ...
  ren "%SystemDrive%\db_backups\%DUMPFILENAME%.gz" "%DUMPFILENAME%-old.gz"
  echo.
)
mongodump -h 127.0.0.1:27017 -d admin --archive="%SystemDrive%\db_backups\%DUMPFILENAME%.gz" --gzip
if %errorlevel% EQU 0 (
  echo Database backup completed successfully
  exit
) else (
  if /I %BACTRY% LEQ 10 (
    goto BACKUP
  ) else echo Database backup failed %BACTRY% times
)

exit
