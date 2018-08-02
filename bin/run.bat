@echo OFF

if [%1]==[] (
  echo.
  echo You didn't specify any batch file to run
  echo.
  goto QUIT
)

for /F "usebackq tokens=*" %%G in (
  `wmic process where "CommandLine like '%%run.bat%%' AND Caption like '%%cmd.exe%%'" get ProcessID/value ^| find /I "="`
) do (
  if not exist "%SystemDrive%\scripts\pids\" mkdir "%SystemDrive%\scripts\pids\"
  for /F "tokens=2 delims==" %%H in ("%%~G") do echo %%H >> "%SystemDrive%\scripts\pids\%%H"
)

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set LOGFILETIME=%mydate%_%mytime%

for %%f in (%1) do set FILENAME=%%~nf

set /A COUNT=0

if exist "%SystemDrive%\log" goto RUNPATCH
echo Log directory not found
echo Creating new directory for log files ....
mkdir "%SystemDrive%\log"
echo.

:RUNPATCH

set /A COUNT+=1
set "LOGFILEPATH=%SystemDrive%\log\%FILENAME%_%LOGFILETIME%-%COUNT%.log"

if exist "%LOGFILEPATH%" (
  echo Log files exists
  echo.
  goto RUNPATCH
)

cmd /c %1 > "%LOGFILEPATH%" 2>&1

:QUIT
pause
exit
