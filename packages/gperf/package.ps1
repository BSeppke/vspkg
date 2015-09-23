param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF GPERF IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\gperf"
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
			write-host "gperf has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE GPERF
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH GPERF
#------------------------------------------------------------------------------
$src="http://ftp.gnu.org/pub/gnu/gperf/gperf-3.0.4.tar.gz"
$dest="$scriptPath\work\gperf-3.0.4.tar.gz"
download-check-unpack-file $src $dest "C1F1DB32FB6598D6A93E6E88796A8632" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO GPERF
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD GPERF
#------------------------------------------------------------------------------
cd "gperf-3.0.4"
nmake /NOLOGO /f Makefile.msvc >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL GPERF
#------------------------------------------------------------------------------
cp "*.exe" "$VSP_BIN_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP GPERF AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "gperf has been installed successfully!" -Foreground Green
