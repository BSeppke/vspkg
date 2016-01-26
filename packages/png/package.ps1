param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PNG IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\png"
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
			write-host "png has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1 -silent
..\cmake\package.ps1 -silent

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PNG
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PNG
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/libpng/libpng16/older-releases/1.6.19/libpng-1.6.19.tar.gz"
$dest="$scriptPath\work\libpng-1.6.19.tar.gz"
download-check-unpack-file $src $dest "3121bdc77c365a87e054b9f859f421fe" >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PNG
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD PNG
#------------------------------------------------------------------------------
cd  "libpng-1.6.19"

md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" ".." >> $logFile
devenv libpng.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile
devenv libpng.sln /Project INSTALL /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL PNG
#------------------------------------------------------------------------------
devenv vigra.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile

cp "$VSP_BIN_PATH/libpng16.dll" "$VSP_BIN_PATH/libpng.dll"

cp "$VSP_LIB_PATH/libpng16_static.lib" "$VSP_LIB_PATH/libpng.lib"
cp "$VSP_LIB_PATH/libpng16.lib" "$VSP_LIB_PATH/png.lib"

mv "$VSP_LIB_PATH/libpng/*"  "$VSP_SHARE_PATH/cmake-3.2/Modules"
rd "$VSP_LIB_PATH/libpng/" -recurse

#------------------------------------------------------------------------------
# STEP 8: CLEANUP png AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "png has been installed successfully!" -Foreground Green
