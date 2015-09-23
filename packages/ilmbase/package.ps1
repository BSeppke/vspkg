param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF ILMBASE IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\ilmbase"
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
			write-host "ilmbase has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE ILMBASE
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH ILMBASE
#------------------------------------------------------------------------------
$src="http://mirror.lihnidos.org/GNU/savannah/openexr/ilmbase-1.0.2.tar.gz"

$dest="$scriptPath\work\ilmbase-1.0.2.tar.gz"
download-check-unpack-file $src $dest "26C133EE8CA48E1196FBFB3FFE292AB4" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO ILMBASE
#------------------------------------------------------------------------------
unpack-file "..\ilmbase-1.0.2-patch.zip" >> $logFile
cp "ilmbase-1.0.2-patch\*" "ilmbase-1.0.2" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD ILMBASE
#------------------------------------------------------------------------------
cd  "ilmbase-1.0.2\vc\vc$($VSP_MSVC_VER)\IlmBase"
devenv IlmBase.sln /Build "Release|$($VSP_BUILD_ARCH)" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL ILMBASE
#------------------------------------------------------------------------------
cd ..\..\..\..\..

cp "Deploy\bin\$VSP_BUILD_ARCH\Release\*.exe"  "$VSP_BIN_PATH" -force

cp "Deploy\bin\$VSP_BUILD_ARCH\Release\*.dll"  "$VSP_BIN_PATH" -force
cp "Deploy\lib\$VSP_BUILD_ARCH\Release\*.lib"  "$VSP_LIB_PATH" -force
cp "Deploy\lib\$VSP_BUILD_ARCH\Release\*.exp"  "$VSP_LIB_PATH" -force

cp "Deploy\include\*.h" "$($VSP_INCLUDE_PATH)" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP ILMBASE AND FINISH
#------------------------------------------------------------------------------
rd Deploy -force -recurse
rd work -force -recurse
write-host "ilmbase has been installed successfully!" -Foreground Green
