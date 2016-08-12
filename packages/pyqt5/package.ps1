param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYQT5 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pyqt5"
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
			write-host "pyqt5 has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE PYQT5
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH PYQT5
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYQT5
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD PYQT5 
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 7: INSTALL PYQT5 
#------------------------------------------------------------------------------
&"pip.exe" "install" "pyqt5" "--upgrade" >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP PYQT5 AND FINISH
#------------------------------------------------------------------------------
write-host "pyqt5 has been installed successfully!" -Foreground Green
