param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PIP IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pip"
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
			write-host "Pip has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\python\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PIP
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 4: FETCH PIP
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PIP
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL PIP 
#------------------------------------------------------------------------------
python -m ensurepip --upgrade  >> $logFile
python -m pip install --upgrade pip >> $logFile
cp "$VSP_PYTHON_PATH\Scripts\pip3.exe" "$VSP_PYTHON_PATH\Scripts\pip.exe"  >> $logFile

#------------------------------------------------------------------------------
# STEP 7: CLEANUP PIP AND FINISH
#------------------------------------------------------------------------------
write-host "Pip has been installed successfully!" -Foreground Green
