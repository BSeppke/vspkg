param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SPYDER IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\spyder"
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
			write-host "spyder has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\sphinx\package.ps1
..\ipython\package.ps1
..\matplotlib\package.ps1
..\pyzmq\package.ps1
pip rope >> $logFile
pip pyflakes >> $logFile
pip pygments >> $logFile
pip pylint >> $logFile
pip pep8 >> $logFile
pip psutil >> $logFile
pip markupsafe >> $logFile
pip pytz >> $logFile

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SPYDER
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SPYDER
#------------------------------------------------------------------------------
$src="https://pypi.python.org/packages/source/s/spyder/spyder-2.3.3.zip"
$dest="$scriptPath\work\spyder-2.3.3.zip"
download-check-unpack-file $src $dest "976E0DBD32D82E1DF7B8ED224B9A48B5"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SPYDER
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL SPYDER 
#------------------------------------------------------------------------------
cd "spyder-2.3.3"
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
# STEP 7: CLEANUP SPYDER AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "spyder has been installed successfully!" -Foreground Green
