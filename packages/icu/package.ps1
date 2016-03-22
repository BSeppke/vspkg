param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF ICU IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\icu"
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
			write-host "icu has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE ICU
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH ICU
#------------------------------------------------------------------------------
$src="http://download.icu-project.org/files/icu4c/50.1.2/icu4c-50_1_2-src.tgz"
$dest="$scriptPath\work\icu4c-50_1_2-src.tar.gz"
download-check-unpack-file $src $dest "BEB98AA972219C9FCD9C8A71314943C9" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO ICU
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD ICU
#------------------------------------------------------------------------------
cd "icu\source\allinone"
devenv allinone.sln /Upgrade >> $logFile
devenv allinone.sln /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL ICU
#------------------------------------------------------------------------------
$VSP_RELEASE_SUFFIX = ""
if($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_RELEASE_SUFFIX="64"
}

cp "..\..\bin$VSP_RELEASE_SUFFIX\*.*" "$VSP_BIN_PATH"
cp "..\..\lib$VSP_RELEASE_SUFFIX\*.*" "$VSP_LIB_PATH"
cp "..\..\include\*"                "$VSP_INCLUDE_PATH" -force -recurse


#------------------------------------------------------------------------------
# STEP 8: CLEANUP ICU AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..\..
rd work -force -recurse
write-host "icu has been installed successfully!" -Foreground Green
