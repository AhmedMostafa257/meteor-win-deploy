@echo off

schTasks /create /tn "MongoDB database continous backup" /tr "wscript.exe %SystemDrive%\scripts\hide_backup.vbs" /sc HOURLY /mo 2 /rl HIGHEST
schTasks /create /tn "Meteor helper application" /tr "wscript.exe %SystemDrive%\scripts\hide_helper.vbs" /sc ONLOGON /rl HIGHEST

pause
