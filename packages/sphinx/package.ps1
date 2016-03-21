param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SPHINX IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\sphinx"
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
			write-host "sphinx has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\setuptools\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SPHINX
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SPHINX
#------------------------------------------------------------------------------
$src="http://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.3b3.tar.gz"
$dest="$scriptPath\work\Sphinx-1.3b3.tar.gz"
try
{
	download-check-unpack-file $src $dest "2414D9B89E4FE6EC7D76AC8A6CFAD4DD"  >> $logFile
}
catch [system.exception]
{
	#we know this would happen, since Sphinx-1.3b3.tar.gz" extracts to "dist/Sphinx-1.3b3.tar"
}
finally
{
	mv "dist\Sphinx-1.3b3.tar" ".\Sphinx-1.3b3.tar"
	rd "dist" -force
	unpack-file "Sphinx-1.3b3.tar" >> $logFile
}

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SPHINX
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL SPHINX 
#------------------------------------------------------------------------------
cd "Sphinx-1.3b3"
$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS
if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}

&"$VSP_PYTHON_PATH\python" "setup.py" "build" >> $logFile
&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK

#------------------------------------------------------------------------------
# STEP 7: CLEANUP SPHINX AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "sphinx has been installed successfully!" -Foreground Green
