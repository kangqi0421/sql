@echo off
REM /**********************************************************************/
REM  * countclients.cmd  						  *	
REM  *	- file to count Tuxedo client connections on a windows platform	  *	
REM  *									  *
REM  **********************************************************************/  

@echo off
setlocal
setlocal EnableDelayedExpansion

:: check to see if LMSCollection is running, if it is, don't print the license prompt again
tasklist /v | findstr /C:"Oracle LMS Collection Script"
echo er %errorlevel%
if errorlevel 1 (
  goto printLicense
) else (
  goto getTUXDIR
)

:printLicense 
more ..\resources\util\license_agreement.txt
:promptloop
set /p ANSWER=Accept License Agreement? (y\n\q)
   
if "%ANSWER%" == "y" (
       goto getTUXDIR
) else if "%ANSWER%" == "n" (
       goto licagreement
) else if "%ANSWER%" == "q" (
       goto licagreement
) else (
	goto promptloop
)
   
:licagreement
echo.
echo You cannot run this program without agreeing to the license agreement.
goto endcountclients


:getTUXDIR

if "%TUXDIR%" == "q" (
	echo User chose to quit countclients.>> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt
	goto endcountclients
) else if "%TUXDIR%" == "quit" (
	echo User chose to quit countclients.>> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt
	goto endcountclients
) else if not exist "%TUXDIR%\udataobj" (
	echo "TUXDIR not set or Tuxedo directory %TUXDIR%\udataobj does not exist."
	echo "Please enter the location where Tuxedo is installed to set TUXDIR environment variable,"
	set /p TUXDIR=or to quit the Tuxedo Countclients script, enter [quit or q]:
	goto getTUXDIR 
)

REM SETLOCAL
:getTUXCONFIG

if "%TUXCONFIG%" == "q" (
	echo User chose to quit countclients.>> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt
	goto endcountclients
) else if "%TUXCONFIG%" == "quit" (
	echo User chose to quit countclients.>> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt
	goto endcountclients
) else if "%TUXCONFIG%" == "Q" (
	echo User chose to quit countclients.>> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt
	goto endcountclients
) else if not exist "%TUXCONFIG%" (
	echo "Cannot find Tuxedo configuration file %TUXCONFIG%."
	set /p TUXCONFIG=Please try again to enter the location where Tuxedo TUXCONFIG file is located or type quit or q to exit countclients:
	goto getTUXCONFIG 
)

@echo off

:: init variables
set SCRIPT_VERSION=16.2
set PATH=%PATH%;%TUXDIR%\bin


tasklist /v | findstr /C:"BBL" >> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt
echo er %errorlevel%
if errorlevel 1 (
  goto BBLnotFound
) else (
  goto checkArguments
)

:checkArguments
set FLDTBLDIR32=%TUXDIR%\udataobj
set FIELDTBLS32=tpadm,Usysfl32

if not EXIST %FLDTBLDIR32%\nul goto tuxdir_invalid

REM
REM /* set up some vars to be used as a LF/CR for the 
REM     ud32 command */
REM 
set LF=^


REM
REM /* put data for ud32 to act on in a temp file. */
REM 
echo SRVCNM^	.TMIB^%LF%%LF%TA_OPERATION^	GET^%LF%%LF%TA_CLASS^	T_MACHINE^%LF%%LF%TA_FLAGS^	65536^%LF%%LF%TA_FILTER^	33560667^%LF%%LF%TA_FILTER^	33560712^%LF%%LF%>temp.txt

REM
REM /* output the text file to the ud32 command to find client count*/
REM
type temp.txt|ud32 -C tpsysadm >>%LMSCT_TMP%\%COMPUTERNAME%-countclients.txt

del temp.txt

tmunloadcf >> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt

goto endcountclients

:BBLnotFound
echo "No Tuxedo BBL processes found running on this machine.  Countclients will not be run."
echo "No Tuxedo BBL processes found running on this machine.  Countclients will not be run." >> %LMSCT_TMP%\%COMPUTERNAME%-countclients.txt

:endcountclients
@endlocal
ENDLOCAL



