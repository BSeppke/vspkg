param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

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
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
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
$src="https://cmake.org/files/v3.22/cmake-3.22.1-windows-i386.zip"
$dest="$scriptPath\work\cmake-3.22.1-windows-i386.zip"
download-check-unpack-file $src $dest "825959AFFDA8322C0986BEEDF3D6E07A" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO CMAKE
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD CMAKE
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL CMAKE
#------------------------------------------------------------------------------
cp "cmake-3.22.1-windows-i386\bin\cmake.exe"  "$VSP_BIN_PATH"
cp "cmake-3.22.1-windows-i386\bin\ctest.exe"  "$VSP_BIN_PATH"
cp -force -recurse "cmake-3.22.1-windows-i386\doc\cmake"  "$VSP_DOC_PATH"
cp -force -recurse "cmake-3.22.1-windows-i386\share\aclocal"  "$VSP_SHARE_PATH"
cp -force -recurse "cmake-3.22.1-windows-i386\share\cmake-3.22"  "$VSP_SHARE_PATH"

#------------------------------------------------------------------------------
# STEP 8: CLEANUP CMAKE AND FINISH
#------------------------------------------------------------------------------
cd ..
rd work -force -recurse
write-host "cmake has been installed successfully!" -Foreground Green
