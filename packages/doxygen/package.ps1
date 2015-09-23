param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF DOXYGEN IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\doxygen"
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
			write-host "doxygen has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE DOXYGEN
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH DOXYGEN
#------------------------------------------------------------------------------
$src="http://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.3.1.windows.bin.zip"
$dest="$scriptPath\work\doxygen-1.8.3.1.windows.bin.zip"
download-check-unpack-file $src $dest "D0BCCD73BC040B8A000F438CE4A3E5FC" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO DOXYGEN
#------------------------------------------------------------------------------
md "doxygen-1.8.3.1.windows.bin" >> $logFile
mv "*.exe" "doxygen-1.8.3.1.windows.bin\"
mv "*.cgi" "doxygen-1.8.3.1.windows.bin\"


#------------------------------------------------------------------------------
# STEP 6: BUILD DOXYGEN
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL DOXYGEN
#------------------------------------------------------------------------------
cd "doxygen-1.8.3.1.windows.bin"
cp "*"  "$VSP_BIN_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP DOXYGEN AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "doxygen has been installed successfully!" -Foreground Green
