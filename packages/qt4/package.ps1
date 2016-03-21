param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF QT4 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\qt4"
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
			write-host "qt4 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\jpeg\package.ps1
..\png\package.ps1
..\tiff\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE QT4
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH QT4
#------------------------------------------------------------------------------
$src="http://download.qt.io/official_releases/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.zip"
$dest="$scriptPath\work\qt-everywhere-opensource-src-4.8.6.zip"
download-check-unpack-file $src $dest "61F7D0EBE900ED3FB64036CFDCA55975" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO QT4
#------------------------------------------------------------------------------
unpack-file "..\qt-4.8.6-patch.zip" >> $logFile
cp "qt-4.8.6-patch\*" "qt-everywhere-opensource-src-4.8.6\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD QT4
#------------------------------------------------------------------------------
cd  "qt-everywhere-opensource-src-4.8.6"
.\configure  -prefix "$VSP_INSTALL_PATH\qt" -opensource -I "$VSP_INCLUDE_PATH" -L "$VSP_LIB_PATH" -confirm-license -nomake demos -nomake examples -webkit -no-phonon -no-phonon-backend -no-sql-sqlite -no-sql-sqlite2 -no-sql-psql -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-tds -no-dbus -no-cups -no-nis -shared -system-zlib -system-libtiff -system-libjpeg -system-libpng -debug-and-release -no-qt3support >> $logFile

nmake /NOLOGO >> $logFile

#------------------------------------------------------------------------------
# STEP 7: INSTALL QT4
#------------------------------------------------------------------------------
nmake /NOLOGO install >> $logFile
mv "$VSP_INSTALL_PATH\qt\lib\*.dll" "$VSP_INSTALL_PATH\qt\bin\" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP QT4 AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "Qt4 has been installed successfully!" -Foreground Green
