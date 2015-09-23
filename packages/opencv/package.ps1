param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF OPENCV IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\opencv"
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
			write-host "opencv has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\jpeg\package.ps1
..\png\package.ps1
..\hdf5\package.ps1
..\openexr\package.ps1
..\tiff\package.ps1
..\numpy\package.ps1
..\python\package.ps1
..\sphinx\package.ps1
..\qt4\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE OPENCV
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH OPENCV
#------------------------------------------------------------------------------
$src="https://codeload.github.com/Itseez/opencv/zip/2.4.11"
$dest="$scriptPath\work\opencv-2.4.11.zip"
download-check-unpack-file $src $dest "B517E83489C709EEE1D8BE76B16976A7" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO OPENCV
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD OPENCV
#------------------------------------------------------------------------------
cd "opencv-2.4.11"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DWITH_OPENEXR=1" "-DWITH_QT=1" "-DWITH_JPEG=1" "-DWITH_PNG=1" "-DWITH_TIFF=1" "-DBUILD_opencv_python=1" "-DBUILD_SHARED_LIBS=1" ".." >> $logFile

devenv OpenCV.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 6: INSTALL OPENCV
#------------------------------------------------------------------------------
devenv OpenCV.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP OPENCV AND FINISH
#------------------------------------------------------------------------------

cd ..\..\..
rd work -force -recurse
write-host "opencv has been installed successfully!" -Foreground Green
