param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF QT5-QWT IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\qt5-qwt"
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
			write-host "qwt has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\qt5\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE QT5-QWT
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH QT5-QWT
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/qwt/qwt/6.1.2/qwt-6.1.2.zip"
$dest="$scriptPath\work\qwt-6.1.2.zip"
download-check-unpack-file $src $dest "B43A4E93C59B09FA3EB60B2406B4B37F"  >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO QT5-QWT
#------------------------------------------------------------------------------
unpack-file "..\qwt-6.1.2-patch.zip"  >> $logFile
cp "qwt-6.1.2-patch\*" "qwt-6.1.2\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD QT5-QWT 
#------------------------------------------------------------------------------
cd "qwt-6.1.2"

&"$VSP_QT5_PATH\bin\qmake" qwt.pro -recursive >> $logFile
nmake /NOLOGO >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL QT5-QWT 
#------------------------------------------------------------------------------
mv "src\*.h"   "$VSP_QT5_PATH\include" -force
mv "lib\*.dll" "$VSP_QT5_PATH\bin" -force
mv "lib\*"     "$VSP_QT5_PATH\lib" -force
mv "designer\plugins\designer\*" "$VSP_QT5_PATH\plugins\designer" -force


#------------------------------------------------------------------------------
# STEP 7: CLEANUP QT5-QWT AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "qt5-qwt has been installed successfully!" -Foreground Green
