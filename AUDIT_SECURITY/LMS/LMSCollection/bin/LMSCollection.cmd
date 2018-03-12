@echo off
setlocal
setlocal EnableDelayedExpansion
@title Oracle LMS Collection Script v18.1.2
:: 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  LMSCollection.cmd  		v18.1.2
::  	- driver script for LMSCollection_main.js  
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

pushd "%~dp0"

:LMSCollection
cscript.exe LMSCollection_main.js %*
@title Command Prompt

:endlocalvars
endlocal
popd
:EOF