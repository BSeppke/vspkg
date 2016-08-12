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

#does not work for vc14 - so we just copy the appropriate files from vc12
if ($VSP_MSVC_VER -eq 14)
{
	unpack-file "perl-vc12-$VSP_BUILD_ARCH.zip" >> $logFile
	cp perl "$VSP_INSTALL_PATH" -recurse -force
	rd perl -force -recurse
	write-host "perl has been installed as VS2013 version, since VS2015 compilation is not possible yet!" -Foreground Green
	return 
}

if(test-path("$scriptPath\work"))
{
	rd work -force -recurse
}
md work >> $logFile
cd work


#------------------------------------------------------------------------------
# STEP 4: FETCH PERL
#------------------------------------------------------------------------------
$src="http://www.cpan.org/src/5.0/perl-5.24.0.tar.gz"
$dest="$scriptPath\work\perl-5.24.0.tar.gz"
download-check-unpack-file $src $dest "c5bf7f3285439a2d3b6a488e14503701" >> $logFile


#------------------------------------------------------------------------------
# STEP 5: APPLY PATCHES TO PERL
#------------------------------------------------------------------------------
unpack-file "..\perl-5.24.0-patch.zip" >> $logFile
cp "perl-5.24.0-patch\*" "perl-5.24.0" -recurse -force

if ($VSP_MSVC_VER -eq 14)
{
	#---Still not working...---------------
	#cp perl-5.24.0\win32\config.vc14   perl-5.24.0\win32\config.vc -force
	#cp perl-5.24.0\win32\config_H.vc14 perl-5.24.0\win32\config_H.vc -force	
	#cp perl-5.24.0\perlio.c14          perl-5.24.0\perlio.c -force	
	#cp perl-5.24.0\win32\win32.c14     perl-5.24.0\win32\win32.c -force	
	#cp perl-5.24.0\win32\win32sck.c14  perl-5.24.0\win32\win32sck.c -force	
	#cp perl-5.24.0\win32\win32.h14     perl-5.24.0\win32\win32.h -force	
}

#------------------------------------------------------------------------------
# STEP 6: BUILD PERL
#------------------------------------------------------------------------------
cd  "perl-5.24.0\win32"

#The filename of the makefile is: "Makefile.msvc[10,11,12,14]-[Win32,x64]"
cp "Makefile.msvc$VSP_MSVC_VER-$VSP_BUILD_ARCH" "Makefile" >> $logFile

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
