param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PTHREADS-WIN32 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\pthreads-win32"
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
			write-host "pthreads-win32 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PTHREADS-WIN32
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PTHREADS-WIN32
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/pthreads4w/pthreads-w32-2-9-1-release.zip"
$dest="$scriptPath\work\pthreads-w32-2-9-1-release.zip"
download-check-unpack-file $src $dest "A3CB284BA0914C9D26E0954F60341354" >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PTHREADS-WIN32
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD PTHREADS-WIN32
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL PTHREADS-WIN32
#------------------------------------------------------------------------------
cd "Pre-built.2"

cp "dll\x64" "dll\amd64" -recurse -force
cp "lib\x64" "lib\amd64" -recurse  -force

cp "dll\$VSP_MSVC_ARCH_FLAGS\pthreadVC2.dll" "$VSP_BIN_PATH" -force
cp "lib\$VSP_MSVC_ARCH_FLAGS\pthreadVC2.lib" "$VSP_LIB_PATH" -force

cp "include\*.h" "$VSP_INCLUDE_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP PTHREADS-WIN32 AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "pthreads-win32 has been installed successfully!" -Foreground Green
