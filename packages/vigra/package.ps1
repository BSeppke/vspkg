param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent 
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF VIGRA IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\vigra"
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
			write-host "vigra has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}

#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\doxygen\package.ps1
..\fftw\package.ps1
..\jpeg\package.ps1
..\png\package.ps1
..\hdf5\package.ps1
..\openexr\package.ps1
..\tiff\package.ps1
..\numpy\package.ps1
..\boost\package.ps1
..\sphinx\package.ps1
..\nose\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE VIGRA
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH VIGRA
#------------------------------------------------------------------------------
$src="http://github.com/ukoethe/vigra/releases/download/Version-1-11-0/vigra-1.11.0-src.tar.gz"
$dest="$scriptPath\work\vigra-Version-1-11-0.tar.gz"
download-check-unpack-file $src $dest "7f80d289e03a2f2e8c8e85f3ff29d988" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO VIGRA
#------------------------------------------------------------------------------
unpack-file "..\vigra-1.11.0-patch.zip"  >> $logFile
cp "vigra-1.11.0-patch\*" "vigra-1.11.0\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD VIGRA
#------------------------------------------------------------------------------
cd "vigra-1.11.0\"
if(test-path("$scriptPath\work\vigra-1.11.0\build"))
{
	rd build -force -recurse
}
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DWITH_OPENEXR=1" "-DDEPENDENCY_SEARCH_PREFIX=$VSP_INSTALL_PATH" "-DZLIB_LIBRARY=$VSP_LIB_UNIXPATH/z.lib" "-DJPEG_LIBRARY=$VSP_LIB_UNIXPATH/jpeg.lib"  "-DTIFF_LIBRARY=$VSP_LIB_UNIXPATH/tiff.lib" "-DPNG_LIBRARY=$VSP_LIB_UNIXPATH/png.lib" ".." >> $logFile

devenv vigra.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile

#------------------------------------------------------------------------------
# STEP 6: INSTALL VIGRA
#------------------------------------------------------------------------------
devenv vigra.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP VIGRA AND FINISH
#------------------------------------------------------------------------------

cd ..\..\..
rd work -force -recurse
write-host "vigra has been installed successfully!" -Foreground Green
