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
# STEP 6: BUILD TIFF
#------------------------------------------------------------------------------
cd  "tiff-4.0.6"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" ".." >> $logFile

devenv tiff.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile

#------------------------------------------------------------------------------
# STEP 7: INSTALL TIFF
#------------------------------------------------------------------------------
devenv tiff.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP TIFF AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "tiff has been installed successfully!" -Foreground Green
