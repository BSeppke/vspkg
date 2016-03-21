param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYSVG IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pysvg"
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
			write-host "pysvg has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE PYSVG
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PYSVG
#------------------------------------------------------------------------------
$src="http://pysvg.googlecode.com/files/pysvg-0.2.1.zip"
$dest="$scriptPath\work\pysvg-0.2.1.zip"
download-check-unpack-file $src $dest "4324F33ABDAD70AE067EDEC41A2B5518"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYSVG
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD PYSVG 
#------------------------------------------------------------------------------
cd "pysvg-0.2.1"
$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS
if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}

&"$VSP_PYTHON_PATH\python" "setup.py" "build_ext" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL PYSVG 
#------------------------------------------------------------------------------
&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK

#------------------------------------------------------------------------------
# STEP 8: CLEANUP PYSVG AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "pysvg has been installed successfully!" -Foreground Green
