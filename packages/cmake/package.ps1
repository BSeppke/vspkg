param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF CMAKE IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\cmake"
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
			write-host "cmake has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE CMAKE
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH CMAKE
#------------------------------------------------------------------------------
$src="http://www.cmake.org/files/v3.2/cmake-3.2.1-win32-x86.zip"
$dest="$scriptPath\work\cmake-3.2.1-win32-x86.zip"
download-check-unpack-file $src $dest "C0B0C090718B8543A9B377E5B7A27BEE" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO CMAKE
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD CMAKE
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL CMAKE
#------------------------------------------------------------------------------
cp "cmake-3.2.1-win32-x86\*"  "$VSP_INSTALL_PATH" -recurse -force

#------------------------------------------------------------------------------
# STEP 8: CLEANUP CMAKE AND FINISH
#------------------------------------------------------------------------------
rm "$VSP_INSTALL_PATH\cmake.org.html"
cd ..
rd work -force -recurse
write-host "cmake has been installed successfully!" -Foreground Green
