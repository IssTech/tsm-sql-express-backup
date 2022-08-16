@echo off
rem ***************************************************************
rem ** Backup Script for Microsoft SQL Express Server            **
rem ** Version 0.2                                               **
rem ** Made by Christian Petersson @ IssTech AB                  **
rem ** GitHub: https://github.com/IssTech/tsm-sql-express-backup **
rem ***************************************************************

set DSM_DIR=C:\Program Files\Tivoli\TSM\baclient
set BACKUP_LOCATION=D:\SQL Backup
set LOG_LOCATION=%BACKUP_LOCATION%\logs
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-3 delims=/:/ " %%a in ('time /t') do (set mytime=%%a:%%b %%c)

rem ****************************************************
rem Verify if the old backups has been backed up or not
rem ****************************************************
rem Set Timestamp in log file
rem ****************************************************
echo %mydate% %mytime% >> "%LOG_LOCATION%\full.log"

rem ****************************************************
rem Start Spectrum Protect Backup to verify old databases
rem has been protected.
rem ****************************************************
echo "Start Spectrum Protect Backup" >> "%LOG_LOCATION%\full.log"
cd /D "%DSM_DIR%"
dsmc i "%BACKUP_LOCATION%\*"

IF NOT %errorlevel% == 0 (
	rem ****************************************************
	rem Files was not sent to Spectrum Protect, 
	rem will create a local copy only
	rem ****************************************************
	set tsm_errorlevel=%errorlevel%
	echo "Failed to start Spectrum Protect Backup" >> "%LOG_LOCATION%\full.log"
	echo "Start dumping MS SQL Express Databases to Disk" >> "%LOG_LOCATION%\full.log"
	sqlcmd -S . -E -Q "EXEC sp_BackupDatabases @backupLocation='%BACKUP_LOCATION%\', @backupType='F'" >> "%LOG_LOCATION%\full.log"
	exit /b %tsm_errorlevel%
)

rem ****************************************************
rem Will Delete all old local copies before creating new copy
rem ****************************************************
rem Delete Old Backups
rem ****************************************************
echo "Successful Backup Last Database Backup" >> "%LOG_LOCATION%\full.log"
echo "Delete old Database Backup on disk" >> "%LOG_LOCATION%\full.log"
del /F "D:\SQL Backup\*.BAK"

rem ****************************************************
rem Create a new local copy of the MS SQL Databases
rem to local disk
rem ****************************************************
echo "Start dumping MS SQL Express Databases to Disk" >> "%LOG_LOCATION%\full.log"
sqlcmd -S . -E -Q "EXEC sp_BackupDatabases @backupLocation='%BACKUP_LOCATION%\', @backupType='F'" >> "%LOG_LOCATION%\full.log"
exit /b %errorlevel%