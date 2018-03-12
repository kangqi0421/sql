@Echo off
SetLocal EnableDelayedExpansion
SetLocal EnableExtensions

set v_product=%1
set v_finalcheck=%2

if exist DB_sql_*00*.log (
if "%v_product%"=="DB" ( if "%v_finalcheck%" NEQ "YES" (

For %%a in (DB_sql_*00*.log) do (
	 findstr /R /C:"DB: LMS-[0-9]*: COLLECTED:" %%a>> DB_collected.log
	 )

For %%a in (DB_sql_*00*.log) do (
	 findstr /R /C:"DB: LMS-[0-9]*: WARNING:" %%a>> DB_warnings.log
	 )	 

For %%a in (DB_sql_*00*.log) do (
	 findstr /R /C:"DB: LMS-[0-9]*: ERROR:" %%a>> DB_errors.log
	 )		 
)
)
)

if "%v_product%"=="DB" ( if "%v_finalcheck%"=="YES" (
	for /f "delims=" %%a in ('FINDSTR /R /N "^.*$" db_list.csv ^| FIND /C ":"') do (
	if %%a==1 (	echo DB: LMS-02808: WARNING: There are no DB instances running on this machine >> DB_warnings.log )
	)
)
)


if exist EBS_sql_*00*.log (
if "%v_product%"=="EBS" ( if "%v_finalcheck%" NEQ "YES" (
For %%a in (EBS_sql_*00*.log) do (
	 findstr /R  /C:"EBS: LMS-[0-9]*: COLLECTED:" %%a>> EBS_collected.log
	 )

For %%a in (EBS_sql_*00*.log) do (
	 findstr /R /C:"EBS: LMS-[0-9]*: WARNING:" %%a>> EBS_warnings.log
	 )	 

For %%a in (EBS_sql_*00*.log) do (
	 findstr /R /C:"EBS: LMS-[0-9]*: ERROR:" %%a>> EBS_errors.log
	 )		 
)
)
)

	
endlocal



