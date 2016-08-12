param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF MATPLOTLIB IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\matplotlib"
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
			write-host "matplotlib has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\setuptools\package.ps1
&"easy_install.exe" "pip" >> $logFile

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE MATPLOTLIB
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH MATPLOTLIB
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO MATPLOTLIB
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD MATPLOTLIB 
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 7: INSTALL MATPLOTLIB 
#------------------------------------------------------------------------------
&"pip.exe" "install" "matplotlib" "--upgrade" >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP MATPLOTLIB AND FINISH
#------------------------------------------------------------------------------
write-host "matplotlib has been installed successfully!" -Foreground Green
