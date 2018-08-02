@echo OFF

cls

echo.
echo Installing node modules
echo .......................
echo.

if "%UNATTENDED%"=="" (
  if %UNATTENDED% EQU 0 (
    echo Updating NPM ...
    echo.
    cmd /c npm i -g npm
    echo.
  )
)

echo.
npm config set python python2.7 -g
npm config set msvs_version 2015 --global
echo.

if "%HELPER%"=="" (
  if %HELPER% EQU 0 (
    goto INSTALLAPPNPM
  )
)

echo Installing helper node modules ...
echo.
cd "%SystemDrive%\helper"
cmd /c npm i
if defined %UNATTENDED% (
  if %UNATTENDED% EQU 0 cmd /c npm audit fix
  if %UNATTENDED% EQU 0 cmd /c npm audit
)
echo.

:INSTALLAPPNPM
echo Installing Meteor.JS application node modules ...
echo.
if "%INSTALLDIR%"=="" (
  cd %INSTALLDIR%\bundle\programs\server\
) else (
  cd "%SystemDrive%\var\www\meteor\bundle\programs\server"
)
cmd /c npm i
if "%UNATTENDED%"=="" (
  if %UNATTENDED% EQU 0 cmd /c npm audit fix
  if %UNATTENDED% EQU 0 cmd /c npm audit
)
echo.

echo done

if "%UNATTENDED%"=="" (
  if %UNATTENDED% EQU 0 (
    pause
    exit
  )
)
