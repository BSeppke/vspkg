param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF FREEGLUT IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\freeglut"
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
			write-host "freeglut has already been installed!" -Foreground Yellow
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
# STEP 3: INITIALIZE FREEGLUT
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH FREEGLUT
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/freeglut/freeglut/3.0.0/freeglut-3.0.0.tar.gz"
$dest="$scriptPath\work\freeglut-3.0.0.tar.gz"
download-check-unpack-file $src $dest "90C3CA4DD9D51CF32276BC5344EC9754" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO FREEGLUT
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD FREEGLUT
#------------------------------------------------------------------------------
cd "freeglut-3.0.0"
md build >> $logFile
cd build

$VSP_CMAKE_MSVC_GENERATOR = "Visual Studio " + $VSP_MSVC_VER
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_CMAKE_MSVC_GENERATOR = $VSP_CMAKE_MSVC_GENERATOR + " Win64"
}
&"$VSP_BIN_PATH\cmake.exe" "-G$VSP_CMAKE_MSVC_GENERATOR" "-Wno-dev" "-DCMAKE_INSTALL_PREFIX=$VSP_INSTALL_PATH" "-DCMAKE_PREFIX_PATH=$VSP_INSTALL_PATH" ".." >> $logFile

devenv freeglut.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 6: INSTALL FREEGLUT
#------------------------------------------------------------------------------
cp "bin\Release\*" "$VSP_BIN_PATH\" -force
cp "lib\Release\*" "$VSP_LIB_PATH\" -force

create-directory-if-necessary "$VSP_INCLUDE_PATH\GL"
cp "..\include\GL\*" "$VSP_INCLUDE_PATH\GL\" -recurse -force

#------------------------------------------------------------------------------
# STEP 8: CLEANUP FREEGLUT AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "freeglut has been installed successfully!" -Foreground Green
