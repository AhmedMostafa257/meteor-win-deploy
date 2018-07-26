@echo off
cls
echo.
Extracting files ...
....................
echo.
cd "%SystemDrive%\var\www\meteor\"
if exist "%SystemDrive%\var\www\meteor\bundle.tar.xz" (
  echo Extracting {Stage 1} ...
  echo.
  7z x "%SystemDrive%\var\www\meteor\bundle.tar.xz"
  echo.
  echo Extracting {Stage 2} ...
  echo.
  7z x "%SystemDrive%\var\www\meteor\bundle.tar"
  echo.
)
if exist "%SystemDrive%\var\www\meteor\bundle.tar"(
  echo Extracting ...
  echo.
  7z x "%SystemDrive%\var\www\meteor\bundle.tar"
  echo.
)
if exist "%SystemDrive%\var\www\meteor\bundle.7z" (
  echo Extracting ...
  echo.
  7z x "%SystemDrive%\var\www\meteor\bundle.7z"
  echo.
)
echo Done
echo.
pause
exit /b
