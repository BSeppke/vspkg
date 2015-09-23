param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF FREETYPE IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\freetype"
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
			write-host "freetype has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE FREETYPE
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH FREETYPE
#------------------------------------------------------------------------------
$src="http://mirror.lihnidos.org/GNU/savannah/freetype/freetype-2.4.11.tar.gz"
$dest="$scriptPath\work\freetype-2.4.11.tar.gz"
download-check-unpack-file $src $dest "5AF8234CF36F64DC2B97F44F89325117" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO FREETYPE
#------------------------------------------------------------------------------
unpack-file "..\freetype-2.4.11-patch.zip" >> $logFile
cp "freetype-2.4.11-patch\*" "freetype-2.4.11\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD FREETYPE
#------------------------------------------------------------------------------
cd  "freetype-2.4.11\builds\win32\vc$VSP_MSVC_VER"
devenv freetype.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile
cd ..\..\..


#------------------------------------------------------------------------------
# STEP 7: INSTALL FREETYPE
#------------------------------------------------------------------------------
cp "objs\$VSP_BUILD_ARCH\vc2010\*.lib" "$VSP_LIB_PATH\" -force
cp "$VSP_LIB_PATH\freetype2411.lib"    "$VSP_LIB_PATH\freetype.lib" -force
cp "include\*" "$VSP_INCLUDE_PATH" -recurse -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP FREETYPE AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "freetype has been installed successfully!" -Foreground Green
