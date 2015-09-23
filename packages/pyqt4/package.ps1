param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYQT4 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pyqt4"
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
			write-host "pyqt4 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\qt4\package.ps1
..\sip\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PYQT4
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PYQT4
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/pyqt/PyQt4/PyQt-4.10/PyQt-win-gpl-4.10.zip"
$dest="$scriptPath\work\PyQt-win-gpl-4.10.zip"
download-check-unpack-file $src $dest "28E82A6E64E22E9CAA508034A91493DC" "-erroraction 'silentlyStop'" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYQT4
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD PYQT4 
#------------------------------------------------------------------------------
cd "PyQt-win-gpl-4.10"
$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS
if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}

&"$VSP_PYTHON_PATH\python" "configure.py" "--confirm-license" >> $logFile
nmake /NOLOGO >> $logFile
$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK


#------------------------------------------------------------------------------
# STEP 7: INSTALL PYQT4 
#------------------------------------------------------------------------------
nmake /NOLOGO install >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP PYQT4 AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "pyqt4 has been installed successfully!" -Foreground Green
