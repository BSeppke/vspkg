param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SETUPTOOLS IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\setuptools"
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
			write-host "setuptools has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE SETUPTOOLS
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SETUPTOOLS
#------------------------------------------------------------------------------
$src="http://pypi.python.org/packages/source/s/setuptools/setuptools-14.0.tar.gz"
$dest="$scriptPath\work\setuptools-14.0.tar.gz"
try
{
	download-check-unpack-file $src $dest "058655FE511DECCB4359BF02727F5199"  >> $logFile
}
catch [system.exception]
{
	#we know this would happen, since setuptools-14.04.tar.gz" extracts to "dist/setuptools-14.0.tar"
}
finally
{
	mv "dist\setuptools-14.0.tar" ".\setuptools-14.0.tar"
	rd "dist" -force
	unpack-file "setuptools-14.0.tar" >> $logFile
}

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SETUPTOOLS
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL SETUPTOOLS 
#------------------------------------------------------------------------------
cd "setuptools-14.0"
$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS
if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}
if( $VSP_MSVC_VER -eq "12")
{
	$Env:VS90COMNTOOLS = $VS120COMNTOOLS
}
if( $VSP_MSVC_VER -eq "14")
{
	$Env:VS90COMNTOOLS = $VS140COMNTOOLS
}

&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK

#------------------------------------------------------------------------------
# STEP 7: CLEANUP SETUPTOOLS AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "setuptools has been installed successfully!" -Foreground Green
