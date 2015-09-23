param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF SWIG IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\swig"
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
			write-host "swig has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 3: INITIALIZE SWIG
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH SWIG
#------------------------------------------------------------------------------
$src="http://freefr.dl.sourceforge.net/project/swig/swigwin/swigwin-3.0.7/swigwin-3.0.7.zip"
$dest="$scriptPath\work\swigwin-3.0.7.zip"
download-check-unpack-file $src $dest "D8B5A9CE49C819CC1BFC1E797B85BA7A" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO SWIG
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD SWIG
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 7: INSTALL SWIG
#------------------------------------------------------------------------------
cd "swigwin-3.0.7"
create-directory-if-necessary "$VSP_INSTALL_PATH\swig"
cp "*"  "$VSP_INSTALL_PATH\swig\" -recurse -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP SWIG AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "swig has been installed successfully!" -Foreground Green
