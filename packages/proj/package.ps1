param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PROJ IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\proj"
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
			write-host "proj has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PROJ
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PROJ
#------------------------------------------------------------------------------
$src="http://download.osgeo.org/proj/proj-4.8.0.zip"
$dest="$scriptPath\work\proj-4.8.0.zip"
download-check-unpack-file $src $dest "B83D63DE1243BD8BCCBCE9B72B2CCEE4" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PROJ
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD PROJ
#------------------------------------------------------------------------------
cd  "proj-4.8.0/src"
$Env:INSTDIR = $VSP_INSTALL_PATH
nmake /NOLOGO /f Makefile.vc  >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL PROJ
#------------------------------------------------------------------------------
nmake /NOLOGO /f Makefile.vc  install >> $logFile

cp "$VSP_LIB_PATH/proj_i.lib" "$VSP_LIB_PATH/proj.lib"
cp "$VSP_LIB_PATH/proj.lib" "$VSP_LIB_PATH/libproj.lib"

#------------------------------------------------------------------------------
# STEP 8: CLEANUP PROJ AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "proj has been installed successfully!" -Foreground Green
