param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF TIFF IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\tiff"
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
			write-host "tiff has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1 -silent
..\jpeg\package.ps1 -silent

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE TIFF
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH TIFF
#------------------------------------------------------------------------------
$src="http://download.osgeo.org/libtiff/tiff-4.0.6.zip"
$dest="$scriptPath\work\tiff-4.0.6.zip"
download-check-unpack-file $src $dest "f5b485d750b2001255ed64224b98b857" >> $logFile



#------------------------------------------------------------------------------
# STEP 6: BUILD TIFF & STEP 7: INSTALL TIFF (SHARED AND STATIC VERSIONS)
#------------------------------------------------------------------------------
cd "tiff-4.0.6"
cp   "build"   "build-static" -recurse -force

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}

#Build static libs first and install them
cd  "build-static"
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DBUILD_SHARED_LIBS=OFF" "-DZLIB_LIBRARY=$VSP_LIB_PATH/zlibstat.lib" "-DJPEG_LIBRARY=$VSP_LIB_PATH/libjpeg.lib" ".." >> $logFile
devenv tiff.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv tiff.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile
mv "$VSP_LIB_PATH\tiff.lib" "$VSP_LIB_PATH\libtiff.lib" -force
mv "$VSP_LIB_PATH\tiffxx.lib" "$VSP_LIB_PATH\libtiffxx.lib" -force

#Then build dynamic libs and install them
cd "..\build"
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" ".." >> $logFile
devenv tiff.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv tiff.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP TIFF AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "tiff has been installed successfully!" -Foreground Green
