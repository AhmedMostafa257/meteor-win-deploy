@echo off

cls

echo.
Extracting files ...
....................
echo.

cd "%SystemDrive%\var\www\meteor\"

if exist ".\bundle.tar.xz" (
  echo Extracting {Stage 1} ...
  echo.
  7z x ".\bundle.tar.xz"
  echo.
  echo Extracting {Stage 2} ...
  echo.
  7z x ".\bundle.tar"
  echo.
) else (
  if exist ".\bundle.tar" (
    echo Extracting ...
    echo.
    7z x ".\bundle.tar"
    echo.
  )
)
if exist ".\bundle.7z" (
  echo Extracting ...
  echo.
  7z x ".\bundle.7z"
  echo.
)

echo Done
echo.

pause

exit /b
