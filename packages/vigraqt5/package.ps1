param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF VIGRAQT5 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\vigraqt5"
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
			write-host "vigraqt5 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
#..\pyqt4\package.ps1 #P<Qt5 not supported yet
..\qt5\package.ps1
..\vigra\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE VIGRAQT5
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH VIGRAQT-Master
#------------------------------------------------------------------------------
unpack-file "..\vigraqt-master.zip"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO VIGRAQT5
#------------------------------------------------------------------------------
unpack-file "..\vigraqt4-0.6-patch.zip"  >> $logFile
cp "vigraqt4-0.6-patch\*" "vigraqt\" -recurse -force

cd "vigraqt"
&"$VSP_PYTHON_PATH\python" patch.py "$VSP_PKG_UNIXPATH/vigraqt5/work/vigraqt" "$VSP_INSTALL_UNIXPATH" >> $logFile


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL VIGRAQT5 
#------------------------------------------------------------------------------
cd "src\vigraqt"

qmake INSTALLBASE="$VSP_INSTALL_PATH" "QT+=widgets" >> $logFile
nmake /NOLOGO >> $logFile
nmake /NOLOGO install >> $logFile
cp "$VSP_LIB_PATH\VigraQt0.dll" "$VSP_BIN_PATH\" -force

#PyQt not supported yet...
#cd "..\sip"
#&"$VSP_PYTHON_PATH\python" configure.py >> $logFile
#
#nmake /NOLOGO >> $logFile
#nmake /NOLOGO install >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP VIGRAQT5 AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..\..
rd work -force -recurse
write-host "vigraqt5 has been installed successfully!" -Foreground Green
