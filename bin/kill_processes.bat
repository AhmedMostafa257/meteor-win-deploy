@echo off

cls

echo.
echo Terminating NodeJS and its related batch processes
echo ..................................................
echo.

for %%a in ("C:\scripts\pids\*") do (
  for /f "usebackq tokens=1" %%h in (`tasklist ^| findstr %%~nxa`) do (
    echo Process name is %%h
    if %%h==cmd.exe taskkill /T /F /PID %%h
    if %%h==node.exe taskkill /T /F /PID %%h
  )
  echo PID from file is %%~nxa
  del /f %%a
)

if %UNATTENDED% EQU 0 pause

exit
