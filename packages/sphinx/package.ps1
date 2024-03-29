param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SPHINX IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\sphinx"
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
			write-host "sphinx has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE SPHINX
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH SPHINX
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SPHINX
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL SPHINX 
#------------------------------------------------------------------------------
&"pip.exe" "install" "sphinx"  "--upgrade" >> $logFile

#------------------------------------------------------------------------------
# STEP 7: CLEANUP SPHINX AND FINISH
#------------------------------------------------------------------------------
write-host "sphinx has been installed successfully!" -Foreground Green
