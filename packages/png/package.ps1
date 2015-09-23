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
$src="http://downloads.sourceforge.net/project/libpng/libpng16/older-releases/1.6.0/libpng-1.6.0.tar.gz"
$dest="$scriptPath\work\libpng-1.6.0.tar.gz"
download-check-unpack-file $src $dest "24F5619A56CF338FEEDD39781CA4C5C1" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PNG
#------------------------------------------------------------------------------
unpack-file "..\png-1.6.0-patch.zip" >> $logFile
cp "png-1.6.0-patch\*" "libpng-1.6.0" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD PNG
#------------------------------------------------------------------------------
cd  "libpng-1.6.0\projects\vc$($VSP_MSVC_VER)"
devenv vstudio.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile
devenv vstudio.sln /Build "Release Library|$($VSP_BUILD_ARCH)"  >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL PNG
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
cp "$($VSP_RELEASE_PREFIX)\Release\*.map"  "$($VSP_LIB_PATH)" -force

cp "$($VSP_RELEASE_PREFIX)\Release Library\*.lib"  "$($VSP_LIB_PATH)" -force

cp "..\..\pnglibconf.h" "$($VSP_INCLUDE_PATH)" -force
cp "..\..\pngconf.h"    "$($VSP_INCLUDE_PATH)" -force
cp "..\..\png.h"        "$($VSP_INCLUDE_PATH)" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP png AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..\..
rd work -force -recurse
write-host "png has been installed successfully!" -Foreground Green
