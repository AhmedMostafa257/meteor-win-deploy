@echo OFF

:BEGIN
echo.
echo Installing node modules
echo .......................
echo.

if defined %UNATTENDED% if %UNATTENDED% EQU 1 goto CONFIGPYTHON

echo.
echo Updating NPM ...
echo.
cmd /c npm i -g npm
echo.

:CONFIGPYTHON
echo.
echo Fixing Python issue for node-gyp ...
cmd /c npm config set python python2.7 -g
cmd /c npm config set msvs_version 2015 --global
echo.

if defined %HELPER% if %HELPER% EQU 0 goto INSTALLAPPNPM

echo.
echo Installing helper node modules ...
echo.
cd "%SystemDrive%\helper"
cmd /c npm i

if defined %UNATTENDED% if %UNATTENDED% EQU 1 goto INSTALLAPPNPM

cmd /c npm audit fix
cmd /c npm audit
echo.

:INSTALLAPPNPM
echo.
echo Installing Meteor.JS application node modules ...
echo.
if [%INSTALLDIR%]==[] (
  cd %INSTALLDIR%\bundle\programs\server\
) else (
  cd %SystemDrive%\var\www\meteor\bundle\programs\server
)
cmd /c npm i
if defined %UNATTENDED% if %UNATTENDED% EQU 1 goto FINISH

cmd /c npm audit fix
cmd /c npm audit
echo.
pause
exit

:FINISH
echo.
echo done
echo.
