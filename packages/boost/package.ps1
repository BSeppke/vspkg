param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

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
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
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
$src="https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.zip"
$dest="$scriptPath\work\boost_1_78_0.zip"
download-check-unpack-file $src $dest "E193E5089060ED6CE5145C8EB05E67E3" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO BOOST
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD BOOST 
#------------------------------------------------------------------------------
cd "boost_1_78_0"
.\bootstrap.bat >> $logFile

$bitflags = "32"
if ($VSP_BUILD_ARCH -eq "x64")
{
	$bitflags = "64"
}
#Build static...
.\b2 "architecture=x86" "variant=release" "threading=multi" "link=static" "runtime-link=static" "address-model=$bitflags" "stage" >> $logFile
#...and dynamic libs:
.\b2 "architecture=x86" "variant=release" "threading=multi" "link=shared" "runtime-link=shared" "address-model=$bitflags" "stage" >> $logFile

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
