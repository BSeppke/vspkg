param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF NUMPY IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\numpy"
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
			write-host "numpy has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE NUMPY
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH NUMPY
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/numpy/NumPy/1.9.2/numpy-1.9.2.tar.gz"
$dest="$scriptPath\work\numpy-1.9.2.tar.gz"

try
{
	download-check-unpack-file $src $dest "A1ED53432DBCD256398898D35BC8E645" "-erroraction 'silentlyStop'" >> $logFile
}
catch [system.exception]
{
	#we know this would happen, since "numpy-1.9.2.tar.gz" extracts to "dist/numpy-1.9.2.tar"
}
finally
{
	mv "dist\numpy-1.9.2.tar" ".\numpy-1.9.2.tar"
	rd "dist" -force
	unpack-file "numpy-1.9.2.tar" >> $logFile
}

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO NUMPY
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL NUMPY 
#------------------------------------------------------------------------------
cd "numpy-1.9.2"
&"$VSP_PYTHON_PATH\python" "setup.py" "build" "-c" "msvc" "install" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP NUMPY AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "numpy has been installed successfully!" -Foreground Green
