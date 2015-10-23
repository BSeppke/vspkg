param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

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
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\python\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SIP
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SIP
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/pyqt/sip/sip-4.14.4/sip-4.14.4.zip"
$dest="$scriptPath\work\sip-4.14.4.zip"
download-check-unpack-file $src $dest "16F6322A1345AABD2570D861E4611C51"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SIP
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD SIP 
#------------------------------------------------------------------------------
cd "sip-4.14.4"
$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS
if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}

&"$VSP_PYTHON_PATH\python" "configure.py" >> $logFile
nmake /NOLOGO >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK


#------------------------------------------------------------------------------
# STEP 7: INSTALL SIP 
#------------------------------------------------------------------------------
nmake /NOLOGO install >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP SIP AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "sip has been installed successfully!" -Foreground Green
