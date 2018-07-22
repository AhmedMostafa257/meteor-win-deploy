@echo OFF

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set LOGFILENAME=%mydate%_%mytime%.log

for %%f in (%1) do set FILENAME=%%~nf

if exist "%SystemDrive%\log" goto RUNPATCH
echo Log directory not found
echo Creating new directory for log files ....
mkdir "%SystemDrive%\log"
echo.

:RUNPATCH
cmd /c %1 > %SystemDrive%\log\%FILENAME%_%LOGFILENAME% 2>&1
