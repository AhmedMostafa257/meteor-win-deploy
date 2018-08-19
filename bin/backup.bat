@echo OFF

echo Backup MongoDB database process
echo ...............................
echo.

set /A SRVTRY=1
set /A BACTRY=0

echo.
echo Checking MongoDB service existance ...
echo.
sc.exe query MongoDB > nul
if ERRORLEVEL 1060 (
  echo MongoDB service not found
  echo Run checks first or installdeps from meteor install patch repository
  exit /b 1
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
      exit /b 1
    )
  ) else echo MongoDB service running
)
echo.

echo.
echo Checking MongoDB tools existance in windows PATH ...
echo.
set path | findstr /i "mongodb" > nul || echo MongoDB tools not found in PATH
echo.

for /f "tokens=2-4 delims=/ " %%a in ('%DATE%') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('%TIME%') do (set mytime=%%a-%%b)
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
dir "%SystemDrive%\db_backups\%DUMPFILENAME%.gz" > nul && ren "%SystemDrive%\db_backups\%DUMPFILENAME%.gz" "%DUMPFILENAME%-old.gz"
mongodump -h 127.0.0.1:27017 -d admin --archive="%SystemDrive%\db_backups\dump_%DUMPFILENAME%.gz" --gzip
if %errorlevel% EQU 0 (
  echo Database backup completed successfully
  exit /b 0
) else (
  if /I %BACTRY% LEQ 10 (
    goto BACKUP
  ) else (
    echo.
    echo Database backup failed %BACTRY% times
    echo.
  )
)

echo.
echo Backup data directory process beginning ...
echo.
del /f "%SystemDrive%\db_backups\datadir_%DUMPFILENAME%.tar"
net stop mongodb
"%ProgramFiles%/7-Zip/7z.exe" a "%SystemDrive%\db_backups\datadir_%DUMPFILENAME%.tar" "%SystemDrive%\data\db" && net start mongodb
"%ProgramFiles%/7-Zip/7z.exe" a "%SystemDrive%\db_backups\datadir_%DUMPFILENAME%.tar.xz" "%SystemDrive%\db_backups\datadir_%DUMPFILENAME%.tar" && del /f "%SystemDrive%\db_backups\datadir_%DUMPFILENAME%.tar"
echo.
