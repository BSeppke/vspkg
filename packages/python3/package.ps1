param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PYTHON IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\python3"
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
			write-host "python3 has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------

# The get_external.bat script is used herein. It needs to have svn in path!

# Dependencies are already shipped with python:
#   bzip2-1.0.6
#   sqlite-3.8.11.0
#   xz-5.0.5

# Optional: If "%IncludeSSL%" is not "false".
#  -> Necessary for downloads from https!
#   nasm-2.11.06
#   openssl-1.0.2h

# Optional: If %IncludeTkinter% is not "false".
# -> Not really necessary...
#   tcl-core-8.6.4.2
#   tk-8.6.4.2
set-item "Env:\IncludeTkinter" "false"

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
$src="https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz"
$dest="$scriptPath\work\Python-3.5.2.tar.gz"
download-check-unpack-file $src $dest "3fe8434643a78630c61c6464fe2e7e72" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PYTHON
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 6: BUILD PYTHON 
#------------------------------------------------------------------------------
cd "Python-3.5.2\PCBuild"
.\build.bat -e -p $VSP_BUILD_ARCH --no-tkinter >> $logFile

#------------------------------------------------------------------------------
# STEP 7: INSTALL PYTHON 
#------------------------------------------------------------------------------
create-directory-if-necessary "$VSP_PYTHON_PATH"
create-directory-if-necessary "$VSP_PYTHON_PATH\include"
create-directory-if-necessary "$VSP_PYTHON_PATH\DLLs"
create-directory-if-necessary "$VSP_PYTHON_PATH\libs"

$VSP_RELEASE_DIR = "Win32" 
if($VSP_BUILD_ARCH -eq "x64")
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

cp "..\Lib" "$VSP_PYTHON_PATH" -recurse -force

cp "$VSP_PYTHON_PATH\include\*" "$VSP_INCLUDE_PATH" -force
cp "$VSP_PYTHON_PATH\libs\*"    "$VSP_LIB_PATH" -force


#------------------------------------------------------------------------------
# STEP 8: CLEANUP PYTHON AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "python3 has been installed successfully!" -Foreground Green
