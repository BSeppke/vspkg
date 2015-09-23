param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF MATPLOTLIB IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\matplotlib"
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
			write-host "matplotlib has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\numpy\package.ps1
..\pyqt4\package.ps1
..\freetype\package.ps1
..\png\package.ps1


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE MATPLOTLIB
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH MATPLOTLIB
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.4.3/matplotlib-1.4.3.tar.gz"
$dest="$scriptPath\work\matplotlib-1.4.3.tar.gz"
try
{
	download-check-unpack-file $src $dest "67A28A359AF4919896D1EC74B6E6B3CE"  >> $logFile
}
catch [system.exception]
{
	#we know this would happen, since matplotlib-1.4.3.tar.gz" extracts to "dist/matplotlib-1.4.3.tar"
}
finally
{
	mv "dist\matplotlib-1.4.3.tar" ".\matplotlib-1.4.3.tar"
	rd "dist" -force
	unpack-file "matplotlib-1.4.3.tar" >> $logFile
}

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO MATPLOTLIB
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD MATPLOTLIB 
#------------------------------------------------------------------------------
cd "matplotlib-1.4.3"
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
# STEP 7: INSTALL MATPLOTLIB 
#------------------------------------------------------------------------------
&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK


#------------------------------------------------------------------------------
# STEP 8: CLEANUP MATPLOTLIB AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "matplotlib has been installed successfully!" -Foreground Green
