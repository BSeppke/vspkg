param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF USB IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\usb"
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
			write-host "usb has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE USB
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH USB
#------------------------------------------------------------------------------
check-unpack-file "$scriptPath\libusb-patched.zip" "B83B5E8E5C51B284819171D128DE82D1" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO USB
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD USB
#------------------------------------------------------------------------------
cd  "libusb-patched"
devenv "msvc/libusb_2012.sln" /Upgrade >> $logFile
devenv "msvc/libusb_2012.sln" /Build "Release|$($VSP_BUILD_ARCH)"  >> $logFile
devenv "msvc/libusb_2012.sln" /Project "libusb-1.0 (dll)" /Build "Release|$($VSP_BUILD_ARCH)"  >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL USB
#------------------------------------------------------------------------------
$VSP_RELEASE_PREFIX = "."
if ($VSP_BUILD_ARCH -ne "Win32")
{
	$VSP_RELEASE_PREFIX = $VSP_BUILD_ARCH
}

cp "$VSP_BUILD_ARCH\Release\examples\*.exe"  "$VSP_BIN_PATH" -force

cp "$VSP_BUILD_ARCH\Release\dll\*.dll"  "$VSP_BIN_PATH" -force
cp "$VSP_BUILD_ARCH\Release\dll\*.lib"  "$VSP_LIB_PATH" -force
cp "$VSP_BUILD_ARCH\Release\dll\*.exp"  "$VSP_LIB_PATH" -force

cp "$VSP_BUILD_ARCH\Release\lib\libusb-1.0.lib"  "$VSP_LIB_PATH\libusb-1.0-static.lib" -force

cp "libusb\libusb.h"  "$VSP_INCLUDE_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP USB AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "usb has been installed successfully!" -Foreground Green
