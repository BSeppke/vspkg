param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYZMQ IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pyzmq"
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
			write-host "pyzmq has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE PYZMQ
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH PYZMQ
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYZMQ
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL PYZMQ 
#------------------------------------------------------------------------------
&"pip.exe" "install" "pyzmq" "--upgrade" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP PYZMQ AND FINISH
#------------------------------------------------------------------------------
write-host "pyzmq has been installed successfully!" -Foreground Green
