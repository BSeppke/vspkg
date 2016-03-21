param([switch]$force, [switch]$silent)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
."..\..\system\tools.ps1" -silent
."..\..\system\environment.ps1" -silent

#------------------------------------------------------------------------------
# STEP 1: CHECK, IF PERL IS ALREADY INSTALLED
#------------------------------------------------------------------------------
$logFile="$($VSP_INSTALL_REGISTRY_PATH)\perl"
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
			write-host "perl has already been installed!" -Foreground Yellow
			write-host "If you want to force installation, call this script again with the '-force' flag!" -Foreground Yellow
		}
		return
	}
}


#------------------------------------------------------------------------------
# STEP 2: INSTALL DEPENDENCIES
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# STEP 3: INITIALIZE PERL
#------------------------------------------------------------------------------
cd $scriptPath
if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PERL
#------------------------------------------------------------------------------
$src="http://www.cpan.org/src/5.0/perl-5.20.2.tar.gz"
$dest="$scriptPath\work\perl-5.20.2.tar.gz"
download-check-unpack-file $src $dest "81B17B9A4E5EE18E54EFE906C9BF544D" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PERL
#------------------------------------------------------------------------------
unpack-file "..\perl-5.20.2-patch.zip" >> $logFile
cp "perl-5.20.2-patch\*" "perl-5.20.2" -recurse -force


#------------------------------------------------------------------------------
# STEP 6: BUILD PERL
#------------------------------------------------------------------------------
cd  "perl-5.20.2\win32"

#The filename of the makefile is: "Makefile.msvc[10,11]-[Win32,x64]"
cp "Makefile.msvc$VSP_MSVC_VER-$VSP_BUILD_ARCH" "Makefile"

nmake /NOLOGO  >> $logFile


#------------------------------------------------------------------------------
# STEP 7: INSTALL PERL
#------------------------------------------------------------------------------
nmake /NOLOGO install >> $logFile


#------------------------------------------------------------------------------
# STEP 8: CLEANUP PERL AND FINISH
#------------------------------------------------------------------------------
cd ..\..\..
rd work -force -recurse
write-host "perl has been installed successfully!" -Foreground Green
