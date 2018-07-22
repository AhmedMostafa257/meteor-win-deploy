@echo OFF

echo Restore MongoDB database process
echo ...............................
echo.

set /A RESTRY=0

echo MongoDB service not started
echo Starting MongoDB service ...
net start MongoDB

echo Begin restore procedure
:RESTORE
set /A RESTRY+=1
echo Restoring database {Try no. %RESTRY%} ...
echo.
mongorestore -h 127.0.0.1:27017 --archive=%1 --gzip --drop
if %errorlevel% EQU 0 (
  echo Database restored successfully
  exit /b
) else (
  if /I %RESTRY% LEQ 4 (
    goto RESTORE
  ) else echo Database restore failed
)

pause
