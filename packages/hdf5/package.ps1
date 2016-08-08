param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF HDF5 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\hdf5"
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
			write-host "hdf5 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1
..\szip\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE HDF5
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH HDF5
#------------------------------------------------------------------------------
$src="http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/hdf5-1.10.0-patch1.zip"
$dest="$scriptPath\work\hdf5-1.10.0-patch1.zip"
download-check-unpack-file $src $dest "5b4f6be0b170bacc85b77fa3424a580b" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO HDF5
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL HDF5 (Static version)
#------------------------------------------------------------------------------
cd  "hdf5-1.10.0-patch1"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DHDF5_BUILD_FORTRAN=OFF" "-DBUILD_TESTING=OFF" "-DHDF5_BUILD_HL_LIB=ON" "-DHDF5_BUILD_EXAMPLES=OFF" "-DHDF5_BUILD_CPP_LIB=ON" "-DHDF5_BUILD_TOOLS=ON" "-DBUILD_SHARED_LIBS=OFF" ".." >> $logFile

devenv HDF5.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv HDF5.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv HDF5.sln /Clean >> $logFile

#------------------------------------------------------------------------------
# STEP 7: BUILD AND INSTALL HDF5 (DLL version)
#------------------------------------------------------------------------------
rm CMakeCache.txt
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH"  "-DHDF5_BUILD_FORTRAN=OFF" "-DBUILD_TESTING=OFF" "-DHDF5_BUILD_HL_LIB=ON" "-DHDF5_BUILD_EXAMPLES=OFF" "-DHDF5_BUILD_CPP_LIB=ON" "-DHDF5_BUILD_TOOLS=ON" "-DBUILD_SHARED_LIBS=ON" ".." >> $logFile

devenv HDF5.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv HDF5.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP HDF5 AND FINISH
#------------------------------------------------------------------------------

#CMake alredy provides finding HDF5
rm "$VSP_INSTALL_PATH\cmake" -force -recurse

#Repair/re-copy docs
mv "$VSP_INSTALL_PATH\COPYING" "$VSP_DOC_PATH\hf5" -force
mv "$VSP_INSTALL_PATH\RELEASE.txt" "$VSP_DOC_PATH\hdf5" -force
mv "$VSP_INSTALL_PATH\USING_HDF5_CMake.txt" "$VSP_DOC_PATH\hf5" -force
mv "$VSP_INSTALL_PATH\USING_HDF5_VS.txt" "$VSP_DOC_PATH\hdf5" -force

cd ..\..\..
rd work -force -recurse
write-host "hdf5 has been installed successfully!" -Foreground Green
