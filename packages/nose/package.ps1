param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF NOSE IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\nose"
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
			write-host "nose has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE NOSE
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH NOSE
#------------------------------------------------------------------------------
$src="http://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz"
$dest="$scriptPath\work\nose-1.3.4.tar.gz"
try
{
	download-check-unpack-file $src $dest "6ED7169887580DDC9A8E16048D38274D"  >> $logFile
}
catch [system.exception]
{
	#we know this would happen, since nose-1.3.4.tar.gz" extracts to "dist/nose-1.3.4.tar"
}
finally
{
	mv "dist\nose-1.3.4.tar" ".\nose-1.3.4.tar"
	rd "dist" -force
	unpack-file "nose-1.3.4.tar" >> $logFile
}

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO NOSE
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL NOSE 
#------------------------------------------------------------------------------
cd "nose-1.3.4"
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
# STEP 7: CLEANUP NOSE AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "nose has been installed successfully!" -Foreground Green
