param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF QT5 IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\qt5"
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
			write-host "qt5 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1
..\jpeg\package.ps1
..\png\package.ps1
..\tiff\package.ps1
..\freetype\package.ps1
#Temporary removed Webkit's dependencies, since WebKit fails to compile anyhow:
#------------------------------------------------------------------------------------------------
#YarrJIT.cpp
#C:\vspkg\vc11\x64\include\Opcode.h(154) : error C2065: 'Py_LT': nichtdeklarierter Bezeichner
#C:\vspkg\vc11\x64\include\Opcode.h(154) : error C2065: 'Py_LE': nichtdeklarierter Bezeichner
#C:\vspkg\vc11\x64\include\Opcode.h(154) : error C2065: 'Py_EQ': nichtdeklarierter Bezeichner
#C:\vspkg\vc11\x64\include\Opcode.h(154) : error C2065: 'Py_NE': nichtdeklarierter Bezeichner
#C:\vspkg\vc11\x64\include\Opcode.h(154) : error C2065: 'Py_GT': nichtdeklarierter Bezeichner
#C:\vspkg\vc11\x64\include\Opcode.h(154) : error C2065: 'Py_GE': nichtdeklarierter Bezeichner
#------------------------------------------------------------------------------------------------
#..\icu\package.ps1
#..\gperf\package.ps1
#..\ruby\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE QT5
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
    rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH QT5
#------------------------------------------------------------------------------
$src="http://download.qt.io/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.zip"
$dest="$scriptPath\work\qt-everywhere-opensource-src-5.5.1.zip"
download-check-unpack-file $src $dest "D071CDAA1B8F34FB49F6DEAC94039C2C" >> $logFile

#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO QT5
#------------------------------------------------------------------------------
$VSP_QT5_SRC_DIR="$scriptPath\work\qt-everywhere-opensource-src-5.5.1"
add-to-envVar-if-necessary "$VSP_QT5_SRC_DIR\qtbase\bin" "PATH"
add-to-envVar-if-necessary "$VSP_QT5_SRC_DIR\gnuwin32\bin" "PATH"

#------------------------------------------------------------------------------
# STEP 6: BUILD QT5
#------------------------------------------------------------------------------
cd  "qt-everywhere-opensource-src-5.5.1"
#remove unix file, so that windows can find and execute the batch file!
rm "configure"
.\configure -prefix "$VSP_INSTALL_PATH\qt5" -I "$VSP_INCLUDE_PATH" -L "$VSP_LIB_PATH" -opensource -nomake tests -nomake examples -release -confirm-license -no-audio-backend -no-sql-sqlite -no-sql-sqlite2 -no-sql-psql -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-tds -no-dbus -no-cups -no-nis -release -shared -system-zlib -system-libpng -system-libjpeg -no-freetype >> $logFile

nmake /NOLOGO >> $logFile

#------------------------------------------------------------------------------
# STEP 7: INSTALL QT5
#------------------------------------------------------------------------------
nmake /NOLOGO install >> $logFile
mv "$VSP_INSTALL_PATH\qt5\lib\*.dll" "$VSP_INSTALL_PATH\qt5\bin\" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP QT5 AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "qt5 has been installed successfully!" -Foreground Green
