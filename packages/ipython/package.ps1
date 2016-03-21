param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF IPYTHON IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\ipython"
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
			write-host "ipython has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE IPYTHON
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH IPYTHON
#------------------------------------------------------------------------------
$src="http://pypi.python.org/packages/source/i/ipython/ipython-3.0.0.zip"
$dest="$scriptPath\work\ipython-3.0.0.zip"
download-check-unpack-file $src $dest "0E60B2DC9958BA4A35AEF1101E5EEBD6"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO IPYTHON
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL IPYTHON 
#------------------------------------------------------------------------------
cd "ipython-3.0.0"
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
# STEP 7: CLEANUP IPYTHON AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "ipython has been installed successfully!" -Foreground Green
