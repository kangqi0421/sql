@echo off
set SCRIPT_VERSION="18.1"!LMSCT_BUILD_VERSION!
setlocal
setlocal EnableDelayedExpansion
echo "Starting run_opmnctl_status.cmd script"
if not exist "!LMSCT_TMP!\FMW\" mkdir "!LMSCT_TMP!\FMW\"
set LMS_OPMN_TEMPFILE="!LMSCT_TMP!\%COMPUTERNAME%-opmnctl_locations.txt"
set LMS_OPMN_OUT_FILE="!LMSCT_TMP!\FMW\%COMPUTERNAME%-opmn_output.txt"
findstr "bin\\opmnctl.exe bin\\opmnctl.bat" !LMSCT_TMP!\logs\LMSfiles.txt | findstr /v "tmplt" > %LMS_OPMN_TEMPFILE%
echo "SCRIPT_VERSION = %SCRIPT_VERSION%" > %LMS_OPMN_OUT_FILE%
echo ============================================================================= >> %LMS_OPMN_OUT_FILE%
SET /a c=0
for /F "tokens=*" %%a in ('type %LMS_OPMN_TEMPFILE%') do (
	set /a c=c+1
	set string1=%%a
	set string2=!string1:\opmn\bin\opmnctl.bat=!
	set string3=!string2:\bin\opmnctl.bat=!
	echo Home!c!:  !string3! >> %LMS_OPMN_OUT_FILE%
	echo ---------------- >> %LMS_OPMN_OUT_FILE%
	cmd /c %%a status >> %LMS_OPMN_OUT_FILE% 2>&1
	echo ============================================================================= >> %LMS_OPMN_OUT_FILE%
)
if exist %LMS_OPMN_TEMPFILE% del %LMS_OPMN_TEMPFILE%
endlocal