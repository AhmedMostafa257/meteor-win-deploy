@echo off

echo Stopping MongoDB service ...
echo.
net stop mongodb
echo.

echo Copying standalone configuration file ...
xcopy /f /y "%~dp0\standalone\mongod.conf" "%SystemDrive%\etc"
echo.

echo Checking MongoDB configuration file ...
type "%SystemDrive%\etc\mongod.conf"
echo.

echo Starting MongoDB service ...
echo.
net start mongodb
echo.

echo Removing old replica set configuration ...
echo.
mongo local --eval "db.system.replset.remove({});"
echo.

if [%1]==[] (
  echo Skipping oplog collection drop step ...
) else (
  echo Dropping oplog collection ...
  echo.
  mongo local --eval "db.oplog.rs.drop();"
)
echo.

echo Waiting for MongoDB to be stable ...
echo.
timeout /t 15 /nobreak
echo.

echo Checking replica set status ...
echo.
mongo --eval "rs.status();"
echo.
