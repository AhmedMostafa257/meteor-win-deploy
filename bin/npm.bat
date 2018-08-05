@echo OFF

:BEGIN
echo.
echo Installing node modules
echo .......................
echo.

if not defined %UNATTENDED% if %UNATTENDED% EQU 0 (
  echo.
  echo Updating NPM ...
  echo.
  cmd /c npm i -g npm
  echo.
)

echo.
echo Fixing Python issue for node-gyp ...
cmd /c npm config set python python2.7 -g
cmd /c npm config set msvs_version 2015 --global
echo.

if not defined %HELPER% if %HELPER% EQU 1 (
  echo.
  echo Installing helper node modules ...
  echo.
  cd "%SystemDrive%\helper"
  cmd /c npm i
)

if not defined %UNATTENDED% if %UNATTENDED% EQU 0 (
  cmd /c npm audit fix
  cmd /c npm audit
  echo.
)

echo.
echo Installing Meteor.JS application node modules ...
echo.
if [%INSTALLDIR%]==[] (
  cd %INSTALLDIR%\bundle\programs\server\
) else (
  cd %SystemDrive%\var\www\meteor\bundle\programs\server
)

cmd /c npm i

if not defined %UNATTENDED% if %UNATTENDED% EQU 0 (
  cmd /c npm audit fix
  cmd /c npm audit
  echo.
  pause
  exit
)

echo.
echo done
echo.
