param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF NOSE IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\nose"
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
			write-host "nose has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE NOSE
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH NOSE
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO NOSE
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL NOSE 
#------------------------------------------------------------------------------
&"pip.exe" "install" "nose" "--upgrade" >> $logFile

#------------------------------------------------------------------------------
# STEP 7: CLEANUP NOSE AND FINISH
#------------------------------------------------------------------------------
write-host "nose has been installed successfully!" -Foreground Green
