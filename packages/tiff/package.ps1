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
$src="http://download.osgeo.org/libtiff/tiff-4.0.3.tar.gz"
$dest="$scriptPath\work\tiff-4.0.3.tar.gz"
download-check-unpack-file $src $dest "051C1068E6A0627F461948C365290410" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO TIFF
#------------------------------------------------------------------------------
unpack-file "..\tiff-4.0.3-patch.zip" >> $logFile
cp "tiff-4.0.3-patch\*" "tiff-4.0.3" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD TIFF
#------------------------------------------------------------------------------
cd  "tiff-4.0.3"
nmake /NOLOGO /f Makefile.vc  >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL TIFF
#------------------------------------------------------------------------------
cp "tools\*.exe"  "$($VSP_BIN_PATH)" -force

cp "libtiff\*.dll"  "$($VSP_BIN_PATH)" -force
cp "libtiff\*.lib"  "$($VSP_LIB_PATH)" -force
cp "libtiff\*.exp"  "$($VSP_LIB_PATH)" -force

cp "libtiff\tiff.h"     "$($VSP_INCLUDE_PATH)" -force
cp "libtiff\tiffconf.h" "$($VSP_INCLUDE_PATH)" -force
cp "libtiff\tiffio.h"   "$($VSP_INCLUDE_PATH)" -force
cp "libtiff\tiffvers.h" "$($VSP_INCLUDE_PATH)" -force

cp "port\libport.lib" "$($VSP_LIB_PATH)" -force
cp "port\libport.h"   "$($VSP_INCLUDE_PATH)" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP TIFF AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "tiff has been installed successfully!" -Foreground Green
