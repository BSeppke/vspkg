param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF NUMPY IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\numpy"
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
			write-host "numpy has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\python\package.ps1
..\setuptools\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE NUMPY
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH NUMPY
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO NUMPY
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL NUMPY 
#------------------------------------------------------------------------------
&"easy_install.exe" "cython" >> $logFile
&"easy_install.exe" "nose" >> $logFile
&"easy_install.exe" "numpy" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP NUMPY AND FINISH
#------------------------------------------------------------------------------
write-host "numpy has been installed successfully!" -Foreground Green
