echo off
SetLocal EnableDelayedExpansion
SetLocal EnableExtensions

set "current_dir=%cd%"
set "working_dir=..\resources\util\LMSCPU"
set "output_dir=%LMSCT_TMP%\LMSCPU"
set "logs_dir=%LMSCT_TMP%\logs"

if not exist "%output_dir%" ( mkdir "%output_dir%" ) 
if not exist "%logs_dir%" ( mkdir "%logs_dir%" ) 

cd "%working_dir%"
call lms_cpuq.cmd %output_dir%

cd /d "%output_dir%"

For /F "delims=" %%a in ('type *-lms_cpuq.txt ^| findstr /B /C:"Computer Name:"') do (
	set v_collected=%%a
	set v_collected=!v_collected:Computer Name: =!
	echo LMSCPU: LMS-01000: COLLECTED: Machine Name: !v_collected! >> "%logs_dir%\LMSCPU_collected.log"
	)

	 
For /F "delims=" %%a in ('type *-lms_cpuq.txt ^| findstr /B /R /C:"LMSCPU: LMS-[0-9]*: WARNING:"') do (
	set v_collected=%%a
	echo %v_collected% >> "%logs_dir%\LMSCPU_warnings.log"
	 )	 

For /F "delims=" %%a in ('type *-lms_cpuq.txt ^| findstr /B /R /C:"LMSCPU: LMS-[0-9]*: ERROR:"') do (
	set v_collected=%%a
	echo %v_collected% >> "%logs_dir%\LMSCPU_errors.log"
	 )	 

EndLocal