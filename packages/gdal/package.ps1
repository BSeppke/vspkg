param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

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
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
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
$src="http://download.osgeo.org/gdal/gdal-1.9.2.tar.gz"
$dest="$scriptPath\work\gdal-1.9.2.tar.gz"
try
{
	download-check-unpack-file $src $dest "3F39DB89F4710269B3A8BF94178E07AA" >> $logFile
}
catch [system.exception]
{
	#we know this would happen, since "gdal-1.9.2.tar.gz" extracts to "gdal-1.9.2RC2.tar"
}
finally
{
	mv "gdal-1.9.2RC2.tar" "gdal-1.9.2.tar"
	unpack-file "gdal-1.9.2.tar" >> $logFile
}

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO GDAL
#------------------------------------------------------------------------------
unpack-file "..\gdal-1.9.2-patch.zip" >> $logFile
cp "gdal-1.9.2-patch\*" "gdal-1.9.2\" -recurse -force

#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL GDAL 
#------------------------------------------------------------------------------
cd "gdal-1.9.2"
if ($VSP_BUILD_ARCH -eq "x64")
{
	$Env:WIN64 = "YES"
}

nmake /NOLOGO /f Makefile.vc >> $logFile

cd swig

$PATH_BAK = $Env:PATH
$Env:PATH = "$VSP_INSTALL_PATH\swig;" + $Env:PATH

$VS90COMNTOOLS_BAK = $Env:VS90COMNTOOLS

if( $VSP_MSVC_VER -eq "10")
{
	$Env:VS90COMNTOOLS = $VS100COMNTOOLS
}
if( $VSP_MSVC_VER -eq "11")
{
	$Env:VS90COMNTOOLS = $VS110COMNTOOLS
}
nmake /NOLOGO /f makefile.vc python >> $logFile

cd python
&"$VSP_PYTHON_PATH\python" "setup.py" "build" >> $logFile
&"$VSP_PYTHON_PATH\python" "setup.py" "install" >> $logFile

cd ..\..

$Env:BINDIR = "$VSP_BIN_PATH"
$Env:INCDIR = "$VSP_INCLUDE_PATH"
$Env:LIBDIR = "$VSP_LIB_PATH"

create-directory-if-necessary "$VSP_SHARE_PATH\gdal"
create-directory-if-necessary "$VSP_DOC_PATH\gdal"
$Env:DATADIR = "$VSP_SHARE_PATH\gdal"
$Env:HTMLDIR = "$VSP_DOC_PATH\gdal"

nmake /NOLOGO /f makefile.vc devinstall >> $logFile

$Env:VS90COMNTOOLS = $VS90COMNTOOLS_BAK
$Env:PATH = $PATH_BAK

#------------------------------------------------------------------------------
# STEP 7: CLEANUP GDAL AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "gdal has been installed successfully!" -Foreground Green
