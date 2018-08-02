@echo off

cls

echo.
echo Terminating NodeJS and its related batch processes
echo ..................................................
echo.

for %%a in ("C:\scripts\pids\*") do (
  echo PID from file is %%~nxa
  for /f "usebackq tokens=1" %%h in (`tasklist ^| findstr %%~nxa`) do (
    echo Process name is %%h
    if %%h==cmd.exe taskkill /T /F /PID %%h
    if %%h==node.exe taskkill /T /F /PID %%h
  )
  del /f %%a
)

for /f "usebackq tokens=2 delims= " %%a in (`tasklist ^| findstr node.exe`) do (
    echo.
    echo Terminating node processes ...
    echo.
    echo Process PID is %%a
    taskkill /T /F /PID %%a
  )

echo.
echo Done
echo.
