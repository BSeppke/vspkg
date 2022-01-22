param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

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
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
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
$src="https://master.dl.sourceforge.net/project/doxygen/rel-1.8.12/doxygen-1.8.12.windows.bin.zip?viasf=1"
$hash="392CEE28459A276C847A325D7DEF18B0"

if ($VSP_BUILD_ARCH -eq "x64")
{
	$src="https://master.dl.sourceforge.net/project/doxygen/rel-1.8.12/doxygen-1.8.12.windows.x64.bin.zip?viasf=1"
	$hash="84433B6166C320BFC1B9CE2BF0E5B897"
}
$dest="$scriptPath\work\doxygen-1.8.12.windows.bin.zip"
download-check-unpack-file $src $dest $hash >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO DOXYGEN
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# STEP 6: BUILD DOXYGEN
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL DOXYGEN
#------------------------------------------------------------------------------
cp "*.exe"  "$VSP_BIN_PATH" -force
cp "*.dll"  "$VSP_BIN_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP DOXYGEN AND FINISH
#------------------------------------------------------------------------------
cd ..
rd work -force -recurse
write-host "doxygen has been installed successfully!" -Foreground Green
