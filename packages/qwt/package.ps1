param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF QWT IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\qwt"
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
..\qt4\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE QWT
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH QWT
#------------------------------------------------------------------------------
$src="http://downloads.sourceforge.net/project/qwt/qwt/6.1.2/qwt-6.1.2.zip"
$dest="$scriptPath\work\qwt-6.1.2.zip"
download-check-unpack-file $src $dest "B43A4E93C59B09FA3EB60B2406B4B37F"  >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO QWT
#------------------------------------------------------------------------------
unpack-file "..\qwt-6.1.2-patch.zip"  >> $logFile
cp "qwt-6.1.2-patch\*" "qwt-6.1.2\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD QWT 
#------------------------------------------------------------------------------
cd "qwt-6.1.2"

&"$VSP_QT4_PATH\bin\qmake" qwt.pro -recursive >> $logFile
nmake /NOLOGO >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL QT5-QWT 
#------------------------------------------------------------------------------
mv "src\*.h"   "$VSP_QT4_PATH\include" -force
mv "lib\*.dll" "$VSP_QT4_PATH\bin" -force
mv "lib\*"     "$VSP_QT4_PATH\lib" -force
mv "designer\plugins\designer\*" "$VSP_QT4_PATH\plugins\designer" -force

#------------------------------------------------------------------------------
# STEP 7: CLEANUP QWT AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "qwt (for Qt4) has been installed successfully!" -Foreground Green
