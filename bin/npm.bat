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

if [%UNATTENDED%]==[] goto UPDATENPM
if %UNATTENDED% EQU 1 goto CONFIGPYTHON

:UPDATENPM
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

if [%HELPER%]==[] goto INSTALLHELPERMODULES
if %HELPER% EQU 0 goto INSTALLAPPNPM

:INSTALLHELPERMODULES
echo.
echo Installing helper node modules ...
echo.
cd "%SystemDrive%\helper"
cmd /c npm i

if [%UNATTENDED%]==[] goto FIXHELPERMODULES
if %UNATTENDED% EQU 1 goto INSTALLAPPNPM

:FIXHELPERMODULES
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
if [%UNATTENDED%]==[] goto FIXAPPMODULES
if %UNATTENDED% EQU 1 goto FINISH

:FIXAPPMODULES
cmd /c npm audit fix
cmd /c npm audit
echo.
pause
exit

:FINISH
echo.
echo done
echo.
