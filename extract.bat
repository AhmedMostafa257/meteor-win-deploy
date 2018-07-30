@echo off

cls

echo.
echo Extracting files ...
echo ....................
echo.

cd %INSTALLDIR%

if exist ".\bundle.tar.xz" (
  echo.
  echo Extracting {Stage 1} ...
  echo.
  7z x ".\bundle.tar.xz"
  echo.
  if exist ".\bundle.tar" del ".\bundle.tar.xz"
  echo.
  echo Extracting {Stage 2} ...
  echo.
  7z x ".\bundle.tar"
  echo.
  if exist ".\bundle\" del ".\bundle.tar"
) else (
  if exist ".\bundle.tar" (
    echo.
    echo Extracting ...
    echo.
    7z x ".\bundle.tar"
    echo.
    if exist ".\bundle\" del ".\bundle.tar"
  )
)
if exist ".\bundle.7z" (
  echo.
  echo Extracting ...
  echo.
  7z x ".\bundle.7z"
  echo.
  if exist ".\bundle\" del ".\bundle.7z"
)

echo.
echo Done
echo.

if %UNATTENDED% EQU 0 (
  pause
  exit
)
