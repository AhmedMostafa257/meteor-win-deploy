@echo OFF

if [%UNATTENDED%]==[] (
  cls
  goto BEGIN
)
if %UNATTENDED% EQU 0 cls

:BEGIN
echo.
echo Installing node modules
echo .......................
echo.

if [%UNATTENDED%]==[] goto CONFIGPYTHON
if %UNATTENDED% EQU 0 (
  echo Updating NPM ...
  echo.
  cmd /c npm i -g npm
  echo.
)

:CONFIGPYTHON
echo.
echo Fixing Python issue for node-gyp ...
cmd /c npm config set python python2.7 -g
cmd /c npm config set msvs_version 2015 --global
echo.

if [%HELPER%]==[] goto INSTALLHELPERMODULES
if %HELPER% EQU 0 goto INSTALLAPPNPM

:INSTALLHELPERMODULES
echo.
echo Installing helper node modules ...
echo.
cd "%SystemDrive%\helper"
cmd /c npm i
if [%UNATTENDED%]=[] goto INSTALLAPPNPM
if %UNATTENDED% EQU 0 cmd /c npm audit fix
if %UNATTENDED% EQU 0 cmd /c npm audit
echo.

:INSTALLAPPNPM
echo.
echo Installing Meteor.JS application node modules ...
echo.
if [%INSTALLDIR%]==[] (
  cd %INSTALLDIR%\bundle\programs\server\
) else (
  cd "%SystemDrive%\var\www\meteor\bundle\programs\server"
)
cmd /c npm i
if [%UNATTENDED%]==[] goto FINISH
if %UNATTENDED% EQU 0 cmd /c npm audit fix
if %UNATTENDED% EQU 0 cmd /c npm audit
echo.

if %UNATTENDED% EQU 0 (
  pause
  exit
)

:FINISH
echo.
echo done
echo.
