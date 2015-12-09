param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF FREENECT IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\freenect"
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
			write-host "freenect has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\cmake\package.ps1
..\usb\package.ps1
..\pthreads-win32\package.ps1
..\freeglut\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE FREENECT
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH FREENECT
#------------------------------------------------------------------------------
$src="https://github.com/OpenKinect/libfreenect/archive/v0.5.2.zip"
$dest="$scriptPath\work\libfreenect-0.5.2.zip"
download-check-unpack-file $src $dest "AF69651661D0BAD47AE175ABD2EBF8E5" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO FREENECT
#------------------------------------------------------------------------------
unpack-file "..\libfreenect-0.5.2-patch.zip"  >> $logFile
cp "libfreenect-0.5.2-patch\*" "libfreenect-0.5.2\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD FREENECT
#------------------------------------------------------------------------------
cd "libfreenect-0.5.2"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
#PYTHONS CYTHON STILL MISSING FOR PYTHON WRAPPER SUPPORT :(
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DLIBUSB_1_INCLUDE_DIR=$VSP_INCLUDE_PATH" "-DLIBUSB_1_LIBRARY=$VSP_LIB_PATH\libusb-1.0.lib" "-DBUILD_PYTHON=OFF" ".." >> $logFile

devenv libfreenect.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 6: INSTALL FREENECT
#------------------------------------------------------------------------------
cp "bin\Release\*.exe"  "$VSP_BIN_PATH" -force
cp "bin\Release\*.lib"  "$VSP_LIB_PATH" -force
cp "bin\Release\*.exp"  "$VSP_LIB_PATH" -force

cp "lib\Release\*.dll"  "$VSP_BIN_PATH" -force
cp "lib\Release\*.lib"  "$VSP_LIB_PATH" -force
cp "lib\Release\*.exp"  "$VSP_LIB_PATH" -force

cp "..\include\*.h" "$VSP_INCLUDE_PATH"-force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP FREENECT AND FINISH
#------------------------------------------------------------------------------

cd ..\..\..
rd work -force -recurse
write-host "freenect has been installed successfully!" -Foreground Green
