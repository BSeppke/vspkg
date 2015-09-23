param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF FFTW IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\fftw"
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
			write-host "fftw has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE FFTW
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH FFTW
#------------------------------------------------------------------------------
$src="http://www.fftw.org/fftw-3.3.3.tar.gz"
$dest="$scriptPath\work\fftw-3.3.3.tar.gz"
download-check-unpack-file $src $dest "0A05CA9C7B3BFDDC8278E7C40791A1C2" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO FFTW
#------------------------------------------------------------------------------
unpack-file "..\fftw-3.3.3-patch.zip" >> $logFile
cp "fftw-3.3.3-patch\*" "fftw-3.3.3" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD FFTW
#------------------------------------------------------------------------------
cd  "fftw-3.3.3\vc$($VSP_MSVC_VER)"
devenv fftw-3.3-libs.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile
devenv fftw-3.3-libs.sln /Build "Static-Release|$($VSP_BUILD_ARCH)" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL FFTW
#------------------------------------------------------------------------------
$VSP_RELEASE_PREFIX = "."
if ($VSP_BUILD_ARCH -ne "Win32")
{
	$VSP_RELEASE_PREFIX = $VSP_BUILD_ARCH
}

cp "$($VSP_RELEASE_PREFIX)\Release\*.exe"  "$($VSP_BIN_PATH)" -force

cp "$($VSP_RELEASE_PREFIX)\Release\*.dll"  "$($VSP_BIN_PATH)" -force
cp "$($VSP_RELEASE_PREFIX)\Release\*.lib"  "$($VSP_LIB_PATH)" -force
cp "$($VSP_RELEASE_PREFIX)\Release\*.exp"  "$($VSP_LIB_PATH)" -force

cp "$($VSP_RELEASE_PREFIX)\Static-Release\*.lib"  "$($VSP_LIB_PATH)" -force

cp "..\api\fftw3.h"  "$($VSP_INCLUDE_PATH)" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP FFTW AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "fftw has been installed successfully!" -Foreground Green
