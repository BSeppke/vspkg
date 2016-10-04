param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

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
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
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
..\qt5\package.ps1

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
$src="https://codeload.github.com/Itseez/opencv/zip/3.1.0"
$dest="$scriptPath\work\opencv-3.1.0.zip"
download-check-unpack-file $src $dest "6082EE2124D4066581A7386972BFD52A" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO OPENCV (needed after build)
#------------------------------------------------------------------------------
unpack-file "..\opencv-3.1.0-patch.zip" .  >> $logFile


#------------------------------------------------------------------------------
# STEP 6: BUILD OPENCV
#------------------------------------------------------------------------------
cd "opencv-3.1.0"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DCMAKE_BUILD_TYPE=Release" "-DWITH_OPENEXR=1" "-DWITH_QT=1" "-DWITH_JPEG=1" "-DWITH_PNG=1" "-DWITH_TIFF=1" "-DBUILD_SHARED_LIBS=1" ".." >> $logFile

devenv OpenCV.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 6: INSTALL OPENCV
#------------------------------------------------------------------------------
devenv OpenCV.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile

#------------------------------------------------------------------------------
# STEP 7: CLEANUP OPENCV'S STRANGE INSTALLATION
#------------------------------------------------------------------------------
$VSP_OPENCV_DIST_FLAG = "x86"
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_OPENCV_DIST_FLAG = "x64"
}
$VSP_OPENCV_DIST_FOLDER = "$VSP_INSTALL_PATH\$VSP_OPENCV_DIST_FLAG\vc$VSP_MSVC_VER"

cp "$VSP_OPENCV_DIST_FOLDER\bin\*" "$VSP_BIN_PATH" -force
cp "$VSP_OPENCV_DIST_FOLDER\lib\*.lib" "$VSP_LIB_PATH"  -force
cp "$VSP_OPENCV_DIST_FOLDER\lib\*.cmake" "$VSP_LIB_PATH"  -force
cp "$VSP_OPENCV_DIST_FOLDER\staticlib\*.lib" "$VSP_LIB_PATH"  -force

md "$VSP_SHARE_PATH\cmake\opencv" -force >> $logFile
mv "$VSP_INSTALL_PATH\*.cmake" "$VSP_SHARE_PATH\cmake\opencv" -force

#patch cmake files to new install dir
cp "..\..\opencv-3.1.0-patch\share\cmake\opencv\*.cmake" "$VSP_SHARE_PATH\cmake\opencv" -force
cp "..\..\opencv-3.1.0-patch\lib\*.cmake" "$VSP_LIB_PATH"  -force

md "$VSP_DOC_PATH\opencv" -force >> $logFile
mv "$VSP_DOC_PATH\*.png" "$VSP_DOC_PATH\opencv" -force
mv "$VSP_DOC_PATH\*.ico" "$VSP_DOC_PATH\opencv" -force
mv "$VSP_INSTALL_PATH\LICENSE" "$VSP_DOC_PATH\opencv" -force
rd "$VSP_INSTALL_PATH\$VSP_OPENCV_DIST_FLAG" -force -recurse >> $logFile

#------------------------------------------------------------------------------
# STEP 8: FINAL/BASIC CLEANUP OPENCV AND FINISH
#------------------------------------------------------------------------------

cd ..\..\..
rd work -force -recurse

write-host "opencv has been installed successfully!" -Foreground Green
