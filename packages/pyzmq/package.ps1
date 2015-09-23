param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

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
# STEP 3: INITIALIZE PYZMQ
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PYZMQ
#------------------------------------------------------------------------------
$src="https://pypi.python.org/packages/source/p/pyzmq/pyzmq-14.5.0.zip"
$dest="$scriptPath\work\pyzmq-14.5.0.zip"
download-check-unpack-file $src $dest "F8D37FC3BFD17A855B9E439FD03121F0"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYZMQ
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL PYZMQ 
#------------------------------------------------------------------------------
cd "pyzmq-14.5.0"
$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS
if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}

&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK


#------------------------------------------------------------------------------
# STEP 7: CLEANUP PYZMQ AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "pyzmq has been installed successfully!" -Foreground Green
