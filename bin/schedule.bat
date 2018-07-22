schTasks /create /tn "MongoDB database continous backup" /tr "wscript.exe %SystemDrive%\script\hide_backup.vbs" /sc HOURLY /mo 2
schTasks /create /tn "Meteor helper application" /tr "wscript.exe %SystemDrive%\script\hide_helper.vbs" /sc ONLOGON

pause
