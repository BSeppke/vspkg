param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF GDAL IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\gdal"
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
			write-host "gdal has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\proj\package.ps1
..\fftw\package.ps1
..\jpeg\package.ps1
..\png\package.ps1
..\hdf5\package.ps1
..\openexr\package.ps1
..\tiff\package.ps1
..\numpy\package.ps1
..\setuptools\package.ps1
..\swig\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE GDAL
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH GDAL
#------------------------------------------------------------------------------
$src="http://download.osgeo.org/gdal/2.1.1/gdal-2.1.1.tar.xz"
$dest="$scriptPath\work\gdal-2.1.1.tar.xz"
download-check-unpack-file $src $dest "4276383314e8080ccab10d94a4a1f495" >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO GDAL
#------------------------------------------------------------------------------
unpack-file "..\gdal-2.1.1-patch.zip" >> $logFile
cp "gdal-2.1.1-patch\*" "gdal-2.1.1\" -recurse -force

#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL GDAL 
#------------------------------------------------------------------------------
cd "gdal-2.1.1"
if ($VSP_BUILD_ARCH -eq "x64")
{
	$Env:WIN64 = "YES"
}

if($VSP_MSVC_VER = 10)
{
	$VSP_MSVC_COMPILE_VER = 1600
}
if($VSP_MSVC_VER = 11)
{
	$VSP_MSVC_COMPILE_VER = 1700
}
if($VSP_MSVC_VER = 12)
{
	$VSP_MSVC_COMPILE_VER = 1800
}
if($VSP_MSVC_VER = 14)
{
	$VSP_MSVC_COMPILE_VER = 1900
}

nmake /NOLOGO /f Makefile.vc MSVC_VER=$VSP_MSVC_COMPILE_VER >> $logFile

cd swig
nmake /NOLOGO /f makefile.vc MSVC_VER=$VSP_MSVC_COMPILE_VER python >> $logFile

cd python
&"$VSP_PYTHON_PATH\python" "setup.py" "build" >> $logFile
&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

cd ..\..
nmake /NOLOGO /f makefile.vc MSVC_VER=$VSP_MSVC_COMPILE_VER devinstall >> $logFile
cp "gdal.lib" "$VSP_LIB_PATH\libgdal.lib" >> $logFile
cp "$VSP_LIB_PATH\gdal_i.lib" "$VSP_LIB_PATH\gdal.lib" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP GDAL AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "gdal has been installed successfully!" -Foreground Green
