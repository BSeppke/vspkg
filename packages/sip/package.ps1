param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SIP IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\sip"
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
			write-host "sip has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\setuptools\pip.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SIP
#------------------------------------------------------------------------------
cd $scriptPath

#------------------------------------------------------------------------------
# STEP 4: FETCH SIP
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SIP
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD SIP 
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 7: INSTALL SIP 
#------------------------------------------------------------------------------
&"pip.exe" "install" "sip" "--upgrade" >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP SIP AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "sip has been installed successfully!" -Foreground Green
