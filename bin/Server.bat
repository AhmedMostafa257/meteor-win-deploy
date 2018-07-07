@echo OFF

echo Starting Meteor application
echo ...........................
echo.

net start MongoDB

node "%SystemDrive%\var\www\meteor\bundle\main.js"
