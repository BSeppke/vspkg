param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF BOOST IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\boost"
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
			write-host "boost has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\python\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE BOOST
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH BOOST
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.zip"
$dest="$scriptPath\work\boost_1_59_0.zip"
download-check-unpack-file $src $dest "08D29A2D85DB3EBC8C6FDFA3A1F2B83C" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO BOOST
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD BOOST 
#------------------------------------------------------------------------------
cd "boost_1_59_0\tools\build\"
.\bootstrap.bat >> $logFile
.\b2 "--prefix=$VSP_INSTALL_PATH"  >> $logFile
cd ..\..

$64bitflags = ""
if ($VSP_BUILD_ARCH -eq "x64")
{
	$64bitflags = "address-model=64"
}
#Build static...
b2 "toolset=msvc-$VSP_MSVC_VER.0" "architecture=x86" "variant=release" "threading=multi" "link=static" "runtime-link=static" $64bitflags "stage" >> $logFile
#...and dynamic libs:
b2 "toolset=msvc-$VSP_MSVC_VER.0" "architecture=x86" "variant=release" "threading=multi" "link=shared" "runtime-link=shared" $64bitflags "stage" >> $logFile

#------------------------------------------------------------------------------
# STEP 7: INSTALL BOOST 
#------------------------------------------------------------------------------
cp "stage\lib\*.dll" "$VSP_BIN_PATH" -force
cp "stage\lib\*.lib" "$VSP_LIB_PATH" -force
cp "boost" "$VSP_INCLUDE_PATH" -recurse -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP BOOST AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "boost has been installed successfully!" -Foreground Green
