@echo OFF

cls

echo.
echo Installing node modules
echo .......................

echo Updating NPM ...
echo.
cmd /c npm i -g npm
echo.

echo Installing helper node modules
echo.
cd "%SystemDrive%\helper"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit
echo.

echo Installing Meteor.JS application node modules
echo.
cd "%SystemDrive%\var\www\meteor\bundle\programs\server"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit
echo.

echo done

pause

exit /b
