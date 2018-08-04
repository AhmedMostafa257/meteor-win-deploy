@echo off

if [%UNATTENDED%]==[] (
  cls
  goto BEGIN
)
if %UNATTENDED% EQU 0 cls

:BEGIN
echo.
echo Terminating NodeJS and its related batch processes
echo ..................................................
echo.

for /F "usebackq skip=1" %%G in (
  `wmic process where "CommandLine like '%%Server.bat%%' AND Caption like '%%cmd.exe%%'" get ProcessId`
) do (
  if not [%%G]==[] (
    echo PID is %%G
    taskkill /f /pid %%G
  )
)

echo.
echo All cmd related processes terminated
echo.

tasklist | findstr /i "node.exe"

if %ERRORLEVEL% EQU 0 (
  for /f "usebackq tokens=2 delims= " %%a in (`tasklist ^| findstr /i "node.exe"`) do (
    echo.
    echo Terminating node processes ...
    echo Process PID is %%a
    taskkill /t /f /PID %%a
    echo.
  )
) else echo No NodeJS processes are running

echo.
echo Done
echo.
