param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF JPEG IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\jpeg"
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
			write-host "jpeg has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE JPEG
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH JPEG
#------------------------------------------------------------------------------
$src="http://www.ijg.org/files/jpegsr8d.zip"
$dest="$scriptPath\work\jpegsr8d.zip"
download-check-unpack-file $src $dest "9BD20DB2BA8242F5F7420DEAB006A261" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO JPEG
#------------------------------------------------------------------------------
unpack-file "..\jpeg-8d-patch.zip" >> $logFile
cp "jpeg-8d-patch\*" "jpeg-8d" -recurse -force
cp "jpeg-8d\jconfig.vc" "jpeg-8d\jconfig.h" -force


#------------------------------------------------------------------------------
# STEP 6: BUILD JPEG
#------------------------------------------------------------------------------
if ($VSP_MSVC_VER -eq 10)
{
	cd  "jpeg-8d\vc10"
}
else
{
	cd  "jpeg-8d\vc11"
	devenv jpeg.sln /Upgrade >> $logFile
	devenv apps.sln /Upgrade >> $logFile
}
devenv jpeg.sln /Build "Release|$($VSP_BUILD_ARCH)" /Project "jpeg" >> $logFile
devenv jpeg.sln /Build "Release|$($VSP_BUILD_ARCH)" /Project "libjpeg" >> $logFile
devenv apps.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL JPEG
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

cp "..\jconfig.h"  "$($VSP_INCLUDE_PATH)" -force
cp "..\jerror.h"   "$($VSP_INCLUDE_PATH)" -force
cp "..\jinclude.h" "$($VSP_INCLUDE_PATH)" -force
cp "..\jmorecfg.h" "$($VSP_INCLUDE_PATH)" -force
cp "..\jpeglib.h"  "$($VSP_INCLUDE_PATH)" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP JPEG AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "jpeg has been installed successfully!" -Foreground Green
