param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYTHON IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\python"
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
			write-host "python has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\openssl\package.ps1
..\sqlite\package.ps1

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PYTHON
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PYTHON
#------------------------------------------------------------------------------
$src="https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz"
$dest="$scriptPath\work\Python-2.7.9.tar.gz"
download-check-unpack-file $src $dest "5EEBCAA0030DC4061156D3429657FB83" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYTHON
#------------------------------------------------------------------------------
unpack-file "..\Python-2.7.9-patch.zip"  >> $logFile
cp "Python-2.7.9-patch\*" "Python-2.7.9\" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD PYTHON 
#------------------------------------------------------------------------------
cd "Python-2.7.9\PCBuild"
devenv pcbuild.sln /upgrade >> $logFile

devenv pcbuild.sln  /Project _ctypes /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project _elementtree /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project _multiprocessing /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project _socket /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project _hashlib /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project _ssl /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project _sqlite3 /Build "Release|$VSP_BUILD_ARCH" >> $logFile

devenv pcbuild.sln  /Project pyexpat /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project select /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project unicodedata /Build "Release|$VSP_BUILD_ARCH" >> $logFile

devenv pcbuild.sln  /Project python /Build "Release|$VSP_BUILD_ARCH" >> $logFile
devenv pcbuild.sln  /Project pythonw /Build "Release|$VSP_BUILD_ARCH" >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL PYTHON 
#------------------------------------------------------------------------------
create-directory-if-necessary "$VSP_PYTHON_PATH"
create-directory-if-necessary "$VSP_PYTHON_PATH\include"
create-directory-if-necessary "$VSP_PYTHON_PATH\DLLs"
create-directory-if-necessary "$VSP_PYTHON_PATH\libs"

$VSP_RELEASE_DIR = "." 
if(-not ($VSP_BUILD_ARCH -eq "Win32"))
{
	$VSP_RELEASE_DIR="amd64"
}

cp "$VSP_RELEASE_DIR\*.exe" "$VSP_PYTHON_PATH" -force
cp "$VSP_RELEASE_DIR\*.dll" "$VSP_PYTHON_PATH" -force
cp "$VSP_RELEASE_DIR\*.exp" "$VSP_PYTHON_PATH\libs" -force
cp "$VSP_RELEASE_DIR\*.lib" "$VSP_PYTHON_PATH\libs" -force
cp "$VSP_RELEASE_DIR\*.pyd" "$VSP_PYTHON_PATH\DLLs" -force

cp "..\Include\*.h" "$VSP_PYTHON_PATH\include" -force
cp "..\PC\pyconfig.h" "$VSP_PYTHON_PATH\include" -force

&"$VSP_PYTHON_PATH\python" "../patch.py" "../Lib/distutils/msvc9compiler.py" "../Lib/distutils/cygwinccompiler.py" >> $logFile
cp "..\Lib" "$VSP_PYTHON_PATH" -recurse -force

cp "$VSP_PYTHON_PATH\include\*" "$VSP_INCLUDE_PATH" -force
cp "$VSP_PYTHON_PATH\libs\*"    "$VSP_LIB_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP PYTHON AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "python has been installed successfully!" -Foreground Green
