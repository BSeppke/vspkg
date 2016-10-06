param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF OPENEXR IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\openexr"
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
			write-host "openexr has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1
..\ilmbase\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE OPENEXR
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH OPENEXR
#------------------------------------------------------------------------------
$src="http://download.savannah.nongnu.org/releases/openexr/openexr-2.2.0.tar.gz"

$dest="$scriptPath\work\openexr-2.2.0.tar.gz"
download-check-unpack-file $src $dest "B64E931C82AA3790329C21418373DB4E" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO OPENEXR
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD OPENEXR
#------------------------------------------------------------------------------
cd openexr-2.2.0

md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DILMBASE_PACKAGE_PREFIX=$VSP_INSTALL_PATH" ".." >> $logFile

devenv OpenEXR.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile

#------------------------------------------------------------------------------
# STEP 7: INSTALL OPENEXR
#------------------------------------------------------------------------------
devenv OpenEXR.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile
cd ..\..\..

#------------------------------------------------------------------------------
# STEP 8: CLEANUP OPENEXR AND FINISH
#------------------------------------------------------------------------------
mv "$VSP_LIB_PATH\*.dll" "$VSP_BIN_PATH" -force >> $logFile
rd work -force -recurse
write-host "openexr has been installed successfully!" -Foreground Green
