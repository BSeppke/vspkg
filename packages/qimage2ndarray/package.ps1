param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF QIMAGE2NDARRAY IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\qimage2ndarray"
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
			write-host "qimage2ndarray has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\numpy\package.ps1
..\pyqt4\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE QIMAGE2NDARRAY
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH QIMAGE2NDARRAY
#------------------------------------------------------------------------------
$src="http://pypi.python.org/packages/source/q/qimage2ndarray/qimage2ndarray-1.0.zip"
$dest="$scriptPath\work\qimage2ndarray-1.0.zip"
download-check-unpack-file $src $dest "5E79E1B45B87AA8E18490162ADCCE8E4"  >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO QIMAGE2NDARRAY
#------------------------------------------------------------------------------
unpack-file "..\qimage2ndarray-1.0-patch.zip"  >> $logFile
cp "qimage2ndarray-1.0-patch\*" "qimage2ndarray-1.0\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD QIMAGE2NDARRAY 
#------------------------------------------------------------------------------
cd "qimage2ndarray-1.0"
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


#------------------------------------------------------------------------------
# STEP 7: INSTALL QIMAGE2NDARRAY 
#------------------------------------------------------------------------------
&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK


#------------------------------------------------------------------------------
# STEP 7: CLEANUP QIMAGE2NDARRAY AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "qimage2ndarray has been installed successfully!" -Foreground Green
