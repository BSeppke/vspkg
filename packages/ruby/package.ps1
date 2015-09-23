param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\config.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF RUBY IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\ruby"
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
			write-host "ruby has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, all this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------
..\zlib\package.ps1 -silent

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE RUBY
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH RUBY
#------------------------------------------------------------------------------
$src="https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz"
$dest="$scriptPath\work\ruby-2.2.3.tar.gz"
download-check-unpack-file $src $dest "150A5EFC5F5D8A8011F30AA2594A7654" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO RUBY
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# STEP 6: BUILD RUBY
#------------------------------------------------------------------------------
cd  "ruby-2.2.3"
$VSP_TARGET_FLAG=""
if($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_TARGET_FLAG="--target=x64-mswin64"
}
&"win32\configure" "--prefix=$VSP_INSTALL_PATH" $VSP_TARGET_FLAG >> $logFile
nmake /NOLOGO >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL RUBY
#------------------------------------------------------------------------------
nmake /NOLOGO install >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP RUBY AND FINISH
#------------------------------------------------------------------------------
cd ..\..
rd work -force -recurse
write-host "ruby has been installed successfully!" -Foreground Green
