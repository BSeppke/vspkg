param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYSVG IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pysvg"
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
			write-host "pysvg has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\pip\package.ps1


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PYSVG
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH PYSVG
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYSVG
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD PYSVG 
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL PYSVG 
#------------------------------------------------------------------------------
&"pip.exe" "install" "pysvg" "--upgrade" >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP PYSVG AND FINISH
#------------------------------------------------------------------------------
write-host "pysvg has been installed successfully!" -Foreground Green
