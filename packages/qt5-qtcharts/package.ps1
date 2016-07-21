param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF qt5-qtcharts IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\qt5-qtcharts"
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
..\perl\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE qt5-qtcharts
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH qt5-qtcharts
#------------------------------------------------------------------------------
#$src="https://github.com/qt/qtcharts/archive/v5.7.0.zip"
#$dest="$scriptPath\work\qtcharts-5.7.0.zip"
#download-check-unpack-file $src $dest "3AF4E15191724B9EF82E2991B3AD7C64"  >> $logFile

#------------------------------------------------------------------------------
# STEP 4: Use the shipped distr. from github
#------------------------------------------------------------------------------
unpack-file "..\qtcharts.zip" >> $logFile

#------------------------------------------------------------------------------
# STEP 5: QMake qt5-qtcharts 
#------------------------------------------------------------------------------
cd "qtcharts"
&"$VSP_QT5_PATH\bin\qmake" -recursive .\qtcharts.pro >> $logFile
nmake /NOLOGO >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL qt5-qtcharts 
#------------------------------------------------------------------------------
nmake install /NOLOGO >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP qt5-qtcharts AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "qt5-qtcharts has been installed successfully!" -Foreground Green
