@echo OFF

cls

echo.
echo Installing node modules
echo .......................
echo.

echo Updating NPM ...
echo.
cmd /c npm i -g npm
echo.

if %HELPER% EQU 0 (
  goto INSTALLAPPNPM
)

echo Installing helper node modules ...
echo.
cd "%SystemDrive%\helper"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit
echo.

:INSTALLAPPNPM
echo Installing Meteor.JS application node modules ...
echo.
if defined %INSTALLDIR% (
  cd %INSTALLDIR%\bundle\programs\server\
)
else (
  cd "%SystemDrive%\var\www\meteor\bundle\programs\server"
)
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit
echo.

echo done

if %UNATTENDED% EQU 0 (
  pause
  exit
)
