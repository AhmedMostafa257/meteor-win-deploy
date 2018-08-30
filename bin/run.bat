@echo OFF

if [%1]==[] (
  echo.
  echo You didn't specify any batch file to run
  echo.
  goto QUIT
)

for /f "tokens=2-4 delims=/ " %%a in ('%DATE%') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('%TIME%') do (set mytime=%%a-%%b)
set LOGFILETIME=%mydate%_%mytime%

for %%f in (%1) do set FILENAME=%%~nf

set /A COUNT=0

dir "%SystemDrive%\log" > nul || mkdir "%SystemDrive%\log"

:RUNPATCH
set /A COUNT+=1
set "LOGFILEPATH=%SystemDrive%\log\%FILENAME%_%LOGFILETIME%-%COUNT%.log"

dir "%LOGFILEPATH%" > nul && goto RUNPATCH

cmd /c %1 > "%LOGFILEPATH%" 2>&1

:QUIT
pause
exit
