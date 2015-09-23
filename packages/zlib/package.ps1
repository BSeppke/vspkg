param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF ZLIB IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\zlib"
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
			write-host "zlib has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE ZLIB
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH ZLIB
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/libpng/zlib/1.2.7/zlib-1.2.7.tar.gz"
$dest="$scriptPath\work\zlib-1.2.7.tar.gz"
download-check-unpack-file $src $dest "60DF6A37C56E7C1366CCA812414F7B85" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO ZLIB
#------------------------------------------------------------------------------
unpack-file "..\zlib-1.2.7-patch.zip" >> $logFile
cp "zlib-1.2.7-patch\*" "zlib-1.2.7" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD ZLIB
#------------------------------------------------------------------------------
cd  "zlib-1.2.7\contrib\vstudio\vc$($VSP_MSVC_VER)"
devenv zlibvc.sln /Build "ReleaseWithoutAsm|$($VSP_BUILD_ARCH)" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL ZLIB
#------------------------------------------------------------------------------
$VSP_RELEASE_PREFIX = $VSP_BUILD_ARCH
if ($VSP_BUILD_ARCH -eq "Win32")
{
	$VSP_RELEASE_PREFIX = "x86"
}

cp "$($VSP_RELEASE_PREFIX)\ZlibDllReleaseWithoutAsm\*.dll"  "$($VSP_BIN_PATH)" -force
cp "$($VSP_RELEASE_PREFIX)\ZlibDllReleaseWithoutAsm\*.lib"  "$($VSP_LIB_PATH)" -force
cp "$($VSP_RELEASE_PREFIX)\ZlibDllReleaseWithoutAsm\*.exp"  "$($VSP_LIB_PATH)" -force
cp "$($VSP_RELEASE_PREFIX)\ZlibDllReleaseWithoutAsm\*.map"  "$($VSP_LIB_PATH)" -force

cp "$($VSP_RELEASE_PREFIX)\ZlibStatReleaseWithoutAsm\zlibstat.lib"  "$($VSP_LIB_PATH)" -force

cp "..\..\..\zlib.h"  "$($VSP_INCLUDE_PATH)" -force
cp "..\..\..\zconf.h" "$($VSP_INCLUDE_PATH)" -force

cp "$($VSP_LIB_PATH)\zlib.lib" "$($VSP_LIB_PATH)\zdll.lib" -force
cp "$($VSP_LIB_PATH)\zlib.exp" "$($VSP_LIB_PATH)\zdll.exp" -force
cp "$($VSP_LIB_PATH)\zlib.map" "$($VSP_LIB_PATH)\zdll.map" -force

cp "$($VSP_LIB_PATH)\zlibstat.lib" "$($VSP_LIB_PATH)\libzlib.lib" -force
cp "$($VSP_LIB_PATH)\zlib.lib"     "$($VSP_LIB_PATH)\z.lib" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP ZLIB AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..\..\..
rd work -force -recurse
write-host "zlib has been installed successfully!" -Foreground Green
