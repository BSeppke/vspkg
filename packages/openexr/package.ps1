param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF OPENEXR IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\openexr"
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
			write-host "openexr has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1
..\ilmbase\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE OPENEXR
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH OPENEXR
#------------------------------------------------------------------------------
$src="http://mirror.lihnidos.org/GNU/savannah/openexr/openexr-1.7.0.tar.gz"

$dest="$scriptPath\work\openexr-1.7.0.tar.gz"
download-check-unpack-file $src $dest "27113284F7D26A58F853C346E0851D7A" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO OPENEXR
#------------------------------------------------------------------------------
unpack-file "..\openexr-1.7.0-patch.zip" >> $logFile
cp "openexr-1.7.0-patch\*" "openexr-1.7.0" -recurse -force

create-directory-if-necessary  "..\Deploy\"
create-directory-if-necessary  "..\Deploy\include\"
create-directory-if-necessary  "..\Deploy\bin\"
create-directory-if-necessary  "..\Deploy\bin\$VSP_BUILD_ARCH\"
create-directory-if-necessary  "..\Deploy\bin\$VSP_BUILD_ARCH\Release\"
create-directory-if-necessary  "..\Deploy\lib\"
create-directory-if-necessary  "..\Deploy\lib\$VSP_BUILD_ARCH\"
create-directory-if-necessary  "..\Deploy\lib\$VSP_BUILD_ARCH\Release\"

cp "$VSP_INCLUDE_PATH\half*.h"  "..\Deploy\include\" -recurse -force
cp "$VSP_INCLUDE_PATH\Iex*.h"   "..\Deploy\include\" -recurse -force
cp "$VSP_INCLUDE_PATH\Ilm*.h"   "..\Deploy\include\" -recurse -force
cp "$VSP_INCLUDE_PATH\Imath*.h" "..\Deploy\include\" -recurse -force

cp "$VSP_BIN_PATH\createDLL.exe" "..\Deploy\bin\$VSP_BUILD_ARCH\Release\" -recurse -force

cp "$VSP_BIN_PATH\Half.dll"      "..\Deploy\bin\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_BIN_PATH\Iex.dll"       "..\Deploy\bin\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_BIN_PATH\IlmThread.dll" "..\Deploy\bin\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_BIN_PATH\Imath.dll"     "..\Deploy\bin\$VSP_BUILD_ARCH\Release\" -recurse -force

cp "$VSP_LIB_PATH\Half.*"      "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_LIB_PATH\Iex.*"       "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_LIB_PATH\IlmThread.*" "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_LIB_PATH\Imath.*"     "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force

cp "$VSP_BIN_PATH\zlibwapi.dll" "..\Deploy\bin\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_LIB_PATH\zlibwapi.lib" "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_LIB_PATH\zlibwapi.exp" "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_LIB_PATH\zlibwapi.map" "..\Deploy\lib\$VSP_BUILD_ARCH\Release\" -recurse -force
cp "$VSP_INCLUDE_PATH\zlib.h"   "..\Deploy\include\" -recurse -force
cp "$VSP_INCLUDE_PATH\zconf.h"  "..\Deploy\include\" -recurse -force

#------------------------------------------------------------------------------
# STEP 6: BUILD OPENEXR
#------------------------------------------------------------------------------
cd  "openexr-1.7.0\vc\vc$($VSP_MSVC_VER)\OpenEXR"
devenv OpenEXR.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL OPENEXR
#------------------------------------------------------------------------------
cd ..\..\..\..\..

cp "Deploy\bin\$($VSP_BUILD_ARCH)\Release\*.exe"  "$($VSP_BIN_PATH)" -force

cp "Deploy\bin\$($VSP_BUILD_ARCH)\Release\*.dll"  "$($VSP_BIN_PATH)" -force
cp "Deploy\lib\$($VSP_BUILD_ARCH)\Release\*.lib"  "$($VSP_LIB_PATH)" -force
cp "Deploy\lib\$($VSP_BUILD_ARCH)\Release\*.exp"  "$($VSP_LIB_PATH)" -force

cp "Deploy\include\*.h" "$($VSP_INCLUDE_PATH)" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP OPENEXR AND FINISH
#------------------------------------------------------------------------------
rd Deploy -force -recurse
rd work -force -recurse
write-host "openexr has been installed successfully!" -Foreground Green
