param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF VIGRAQT4 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\vigraqt4"
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
			write-host "vigraqt4 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\pyqt4\package.ps1
..\vigra\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE VIGRAQT4
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH VIGRAQT4
#------------------------------------------------------------------------------
$src="http://kogs-www.informatik.uni-hamburg.de/~meine/software/vigraqt/vigraqt4-0.6.tar.gz"
$dest="$scriptPath\work\vigraqt4-0.6.tar.gz"
download-check-unpack-file $src $dest "CD030E8BA74120E8D5F5A0339F45E483"  >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO VIGRAQT4
#------------------------------------------------------------------------------
unpack-file "..\vigraqt4-0.6-patch.zip"  >> $logFile
cp "vigraqt4-0.6-patch\*" "vigraqt4-0.6\" -recurse -force

cd "vigraqt4-0.6"
&"$VSP_PYTHON_PATH\python" patch.py "$VSP_PKG_UNIXPATH/vigraqt4/work/vigraqt4-0.6" "$VSP_INSTALL_UNIXPATH" >> $logFile


#------------------------------------------------------------------------------
# STEP 6: BUILD AND INSTALL VIGRAQT4 
#------------------------------------------------------------------------------
cd "src\vigraqt"

qmake INSTALLBASE="$VSP_INSTALL_PATH" >> $logFile
nmake /NOLOGO >> $logFile
nmake /NOLOGO install >> $logFile
cp "$VSP_LIB_PATH\VigraQt0.dll" "$VSP_BIN_PATH\" -force

cd "..\sip"
&"$VSP_PYTHON_PATH\python" configure.py >> $logFile

nmake /NOLOGO >> $logFile
nmake /NOLOGO install >> $logFile


#------------------------------------------------------------------------------
# STEP 7: CLEANUP VIGRAQT4 AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..\..
rd work -force -recurse
write-host "vigraqt4 has been installed successfully!" -Foreground Green
