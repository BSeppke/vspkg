param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SZIP IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\szip"
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
			write-host "szip has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\cmake\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SZIP
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SZIP
#------------------------------------------------------------------------------
$src="https://support.hdfgroup.org/ftp/lib-external/szip/previous/2.1/src/szip-2.1.tar.gz"
$dest="$scriptPath\work\szip-2.1.tar.gz"
download-check-unpack-file $src $dest "902F831BCEFB69C6B635374424ACBEAD" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SZIP
#------------------------------------------------------------------------------
unpack-file "..\szip-2.1-patch.zip" >> $logFile
cp "szip-2.1-patch\*" "szip-2.1" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL SZIP (Static version)
#------------------------------------------------------------------------------
cd  "szip-2.1"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DBUILD_SHARED_LIBS=OFF" ".." >> $logFile

devenv SZIP.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv SZIP.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv SZIP.sln /Clean >> $logFile

#------------------------------------------------------------------------------
# STEP 7: BUILD AND INSTALL SZIP (DLL version)
#------------------------------------------------------------------------------
rm CMakeCache.txt
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" "-DBUILD_SHARED_LIBS=ON" ".." >> $logFile

devenv SZIP.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv SZIP.sln /Project INSTALL /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP SZIP AND FINISH
#------------------------------------------------------------------------------
create-directory-if-necessary "$VSP_DOC_PATH\szip"
mv "$VSP_SHARE_PATH\COPYING" "$VSP_DOC_PATH\szip\" -force
mv "$VSP_SHARE_PATH\HISTORY.txt" "$VSP_DOC_PATH\szip\" -force
mv "$VSP_SHARE_PATH\INSTALL" "$VSP_DOC_PATH\szip\" -force
mv "$VSP_SHARE_PATH\README" "$VSP_DOC_PATH\szip\" -force
mv "$VSP_SHARE_PATH\RELEASE.txt" "$VSP_DOC_PATH\szip\" -force

cd ..\..\..
rd work -force -recurse
write-host "szip has been installed successfully!" -Foreground Green
