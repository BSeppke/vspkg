param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SQLITE IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\sqlite"
if(test-path($logFile))
{ 
	if($force)
	{
		rm $logFile
	}
	else
	{
		if(-not $silent)
		{
			write-host "sqlite has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SQLITE
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SQLITE
#------------------------------------------------------------------------------
$src="http://www.sqlite.org/2015/sqlite-amalgamation-3080803.zip"
$dest="$scriptPath\work\sqlite-amalgamation-3080803.zip"
download-check-unpack-file $src $dest "97604645C615D81194541E1398687B61" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SQLITE
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD SQLITE
#------------------------------------------------------------------------------
cd  "sqlite-amalgamation-3080803"
cl "shell.c" "sqlite3.c" "-Fesqlite3.exe" >> $logFile
cl "sqlite3.c" "/DSQLITE_API=__declspec(dllexport)" "-link" "-dll" "-out:sqlite3.dll" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL SQLITE
#------------------------------------------------------------------------------
cp sqlite3.exe  "$VSP_BIN_PATH" -force
cp sqlite3.dll  "$VSP_BIN_PATH" -force
cp sqlite3.lib  "$VSP_LIB_PATH" -force
cp sqlite3.exp  "$VSP_LIB_PATH" -force
cp sqlite3.h    "$VSP_INCLUDE_PATH" -force
cp sqlite3ext.h "$VSP_INCLUDE_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP SQLITE AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "sqlite has been installed successfully!" -Foreground Green
