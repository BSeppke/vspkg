param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF OPENSSL IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\openssl"
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
			write-host "openssl has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\perl\package.ps1 -silent

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE OPENSSL
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH OPENSSL
#------------------------------------------------------------------------------
$src="http://mirrors.ibiblio.org/openssl/source/old/1.0.2/openssl-1.0.2e.tar.gz"
$dest="$scriptPath\work\openssl-1.0.2e.tar.gz"
download-check-unpack-file $src $dest "5262bfa25b60ed9de9f28d5d52d77fc5" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO OPENSSL
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD OPENSSL
#------------------------------------------------------------------------------
cd  "openssl-1.0.2e"

$Env:PERL5LIB="$VSP_LIB_PATH\perl5"

$VSP_SSL_CONFIG_FLAG = "VC-WIN32"
$VSP_SSL_BUILD_BATCH = "do_ms.bat"

if(-not ($VSP_BUILD_ARCH -eq "Win32"))
{
	$VSP_SSL_CONFIG_FLAG = "VC-WIN64A"
	$VSP_SSL_BUILD_BATCH = "do_win64a.bat"
}

perl Configure  "--prefix=$VSP_INSTALL_PATH" "no-asm" "enable-camellia" "disable-idea" "$VSP_SSL_CONFIG_FLAG" >> $logFile
& "ms\$VSP_SSL_BUILD_BATCH" >> $logFile

nmake /NOLOGO /f ms\ntdll.mak >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL OPENSSL
#------------------------------------------------------------------------------
nmake /NOLOGO /f ms\ntdll.mak install >> $logFile

#------------------------------------------------------------------------------
# STEP 8: CLEANUP OPENSSL AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "openssl has been installed successfully!" -Foreground Green
