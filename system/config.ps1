param([switch]$silent)

# ------------- DEFINE SOME VERY HANDY FUNCTIONS -----------------------

#Download a file from the web to some destination
function download-file { 
	param($source, $dest)
	
	$webclient = New-Object System.Net.WebClient
	$webclient.DownloadFile($source, $dest)
}

#Returns the (upcase) MD5 value of a file
function md5-file {
	param($file)
	
	$algo = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
	$stream = New-Object System.IO.FileStream($file, [System.IO.FileMode]::Open, 
		[System.IO.FileAccess]::Read)
	
	$md5StringBuilder = New-Object System.Text.StringBuilder
	$algo.ComputeHash($stream) | % { [void] $md5StringBuilder.Append($_.ToString("x2")) }
	$md5StringBuilder.ToString().ToUpper()
	
	$stream.Dispose()
}

#Checks, if 7zip is installed and installs it if needed... Returns the path to the
#binary after all.
function check-install-7zip
{
	$7Zip=$true
	try
	{
		$7ZipPath = Resolve-Path -Path ((Get-Item -Path HKLM:\SOFTWARE\7-Zip -ErrorAction SilentlyContinue).GetValue("Path") + "\7z.exe");
		
		if (-not $7ZipPath)
		{
		$7Zip = $false;
		}
	}
	catch 
	{
		$7Zip = $false;
	}

	if (-not $7zip)
	{
		$7ZipPath = "$env:ProgramFiles\7-Zip\7z.exe"

		Write-Host "Did not find an installation of 7zip!"
		Write-Host "Will now download latest version..."
		
		$web = New-Object System.Net.WebClient
		$page = $web.DownloadString("http://www.7-zip.org/download.html")
		
		$64bit = ''
		
		if ($env:PROCESSOR_ARCHITECTURE -match '64')
		{
			$64bit = 'x64'
		}
		
		$pattern = "(http://.*?${64bit}\.msi)"
		$url = $page | Select-String -Pattern $pattern | Select-Object -ExpandProperty Matches -First 1 | foreach { $_.Value }
		
		$file = "$env:TEMP\7z.msi"
		if (Test-Path $file)
		{    
			rm $file | Out-Null
		}
		
		$web.DownloadFile($url, $file)
		
		Write-Host "Installing 7zip $($64bit)..."
		Write-Host "(Note: please approve the User Account Control (UAC) popup if necessary...)"
		
		& "$file /passive" > $null
		
		while (-not (Test-Path $7ZipPath))
		{
			start-sleep -Seconds 10
		}
		Write-Host "Done!"
	}
	return $7ZipPath
}

#Unpacks any known file using 7zip
function unpack-file
{
	param($file)
	
	$7ZipPath = check-install-7zip
	
	& "$7ZipPath" "x" $file "-aoa"
	$unpackedfile = ([io.fileinfo]$file).basename
	if( ([io.fileinfo] $unpackedfile).Extension -eq ".tar")
	{
		& "$7ZipPath" "x" $unpackedfile "-aoa"
		rm $unpackedfile
	}
}

#Check the MD5 hash and unpack a file
function check-unpack-file
{
	param($file, $md5)
	
	$checksum =  md5-file($file)
	if ($checksum -eq $md5)
	{
		unpack-file $file
	}
	else
	{
		throw "Checksums does not match!"
	}
}

#Download a file, check the MD5 hash and unpack it
function download-check-unpack-file
{
	param($source, $dest, $md5)
	
	download-file $source $dest
	check-unpack-file $dest $md5
}

#Prepend a String to an environment variable (given as its string name)
function add-to-envVar-if-necessary
{
	Param($var, $envVar)
	
	$envContent = (get-item -path "ENV:\\$($envVar)").Value
	
	if(-not ($envContent -match [regex]::escape($var)))
	{
		$envContent = $var + ";" + $envContent
		set-item -force -path "ENV:\$($envVar)" -value "$($envContent)"
	}
}

#Create a new directory (if it does not already exist)
function create-directory-if-necessary
{
	Param($newDir)
	
	if(-not (test-path  $newDir))
	{
		$null = md $newDir
	}
}

#Add the VS parameters to the environment if necessary
function add-vs-variables-if-necessary
{
	param($version, $architecture)
	
	if(-not $env:VCINSTALLDIR)
	{
		pushd "C:\Program Files (x86)\Microsoft Visual Studio $($version).0\VC"
		cmd /c "vcvarsall.bat $($architecture)&set" |
		foreach {
			if ($_ -match "=") {
				$v=$_.split("=")
				set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
			}
		}
	}
	popd
	if(-not $silent)
	{
		Write-Host "Visual Studio command prompt variables have been set!" -ForegroundColor Yellow
	}
}

#------------ SET WINDOWS VERSION TO BUILD FOR: WIN32 OR WIN64 --------------
#$VSP_BUILD_ARCH = "Win32"
$VSP_BUILD_ARCH = "x64"

#------- SET THE VERSION OF VISUAL STUDIO (10 = 2010) OR (11 = 2012)---------
#$VSP_MSVC_VER = "10"
$VSP_MSVC_VER = "11"


#----------------------- SET THE BASE (INSTALLATION) PATH -------------------
$VSP_BASE_PATH = "C:\vspkg"
$VSP_BASE_UNIXPATH = "C:/vspkg"


#================== DO NOT EDIT THE LINES BELOW =============================
#====== They are only used to derive dependent properties and to set ========
#====== variables according to the manually chosen set of variables.  =======
#============================================================================
$ORIGINAL_PATH = "$Env:PATH"

$VSP_PKG_PATH     = "$VSP_BASE_PATH" + "\packages"
$VSP_SCRIPT_PATH  = "$VSP_BASE_PATH" + "\scripts"
$VSP_INSTALL_PATH = "$VSP_BASE_PATH" + "\vc" + $VSP_MSVC_VER + "\" + $VSP_BUILD_ARCH
$VSP_INSTALL_REGISTRY_PATH = "$VSP_INSTALL_PATH" +"\installed_packages"

$VSP_PKG_UNIXPATH     = "$VSP_BASE_UNIXPATH" + "/packages"
$VSP_SCRIPT_UNIXPATH  = "$VSP_BASE_UNIXPATH" + "/scripts"
$VSP_INSTALL_UNIXPATH = "$VSP_BASE_UNIXPATH" + "/vc" + $VSP_MSVC_VER + "/" + $VSP_BUILD_ARCH
$VSP_INSTALL_REGISTRY_UNIXPATH = "$VSP_INSTALL_UNIXPATH" +"/installed_packages"


#-------------- SET AND CALL THE CORRESPONDING VC SETTINGS ------------------
$VSP_MSVC_ARCH_FLAGS = "x86"
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_MSVC_ARCH_FLAGS = "amd64"
}
add-vs-variables-if-necessary $VSP_MSVC_VER $VSP_MSVC_ARCH_FLAGS

#------------------ DEFINE CURRENT DEV DIRECTORIES  -----------------------
$VSP_BIN_PATH = $VSP_INSTALL_PATH + "\bin"
$VSP_LIB_PATH = $VSP_INSTALL_PATH + "\lib"
$VSP_INCLUDE_PATH = $VSP_INSTALL_PATH + "\include"
$VSP_DOC_PATH = $VSP_INSTALL_PATH + "\doc"
$VSP_SHARE_PATH= $VSP_INSTALL_PATH + "\share"

$VSP_BIN_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/bin"
$VSP_LIB_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/lib"
$VSP_INCLUDE_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/include"
$VSP_DOC_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/doc"
$VSP_SHARE_UNIXPATH= $VSP_INSTALL_UNIXPATH + "/share"

#-------------------- Create paths if necessary ----------------------------
#-------------------- and install 3rd-party tools --------------------------
#-- These are needed for downloading and installing other packages    ---------

create-directory-if-necessary $VSP_INSTALL_PATH
create-directory-if-necessary $VSP_INSTALL_REGISTRY_PATH
create-directory-if-necessary $VSP_BIN_PATH
create-directory-if-necessary $VSP_LIB_PATH
create-directory-if-necessary $VSP_INCLUDE_PATH
create-directory-if-necessary $VSP_DOC_PATH
create-directory-if-necessary $VSP_SHARE_PATH


#----------------- SET ADDITIONAL PATHS FOR PERL, PYTHON AND QT--------------
$VSP_PERL_PATH     = $VSP_INSTALL_PATH + "\perl"
$VSP_PERL_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/perl"

$VSP_PYTHON_PATH     = $VSP_INSTALL_PATH + "\python"
$VSP_PYTHON_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/python"
$Env:PYTHONHOME      = $VSP_PYTHON_PATH

$VSP_QT4_PATH     = $VSP_INSTALL_PATH + "\qt"
$VSP_QT4_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/qt"
$Env:QTDIR        = $VSP_QT4_PATH

#------------------ ADD VSP DIRECTORIES TO ENV -----------------------
set-item "Env:\VSP_INSTALL_PATH" $VSP_INSTALL_PATH 
add-to-envVar-if-necessary $VSP_LIB_PATH "LIB"
add-to-envVar-if-necessary $VSP_INCLUDE_PATH "INCLUDE"
add-to-envVar-if-necessary "$($VSP_PERL_PATH)\bin" "PATH"
add-to-envVar-if-necessary $VSP_PYTHON_PATH "PATH"
add-to-envVar-if-necessary "$($VSP_PYTHON_PATH)\DLLs" "PATH"
add-to-envVar-if-necessary "$($VSP_PYTHON_PATH)\Scripts" "PATH"
add-to-envVar-if-necessary "$($VSP_QT4_PATH)\bin" "PATH"
add-to-envVar-if-necessary $VSP_BIN_PATH "PATH"


#------------ DISPLAY CONFIGURATION STATUS FOR MANUAL CHECKUP ----------------
if(-not $silent)
{
	Write-Host "Configured vspkg"
	Write-Host "-------------------------------------------------------"
	Write-Host "     Build architecture: " $VSP_BUILD_ARCH
	Write-Host ""
	Write-Host "     Visual Studio version: " $VSP_MSVC_VER
	Write-Host ""
	Write-Host "     CMake build command: " $VSP_CMAKE_BUILD_CMD
	Write-Host ""
	Write-Host "     Path environment variable: " $Env:PATH
	Write-Host ""
	Write-Host "     Include environment variable: " $Env:INCLUDE
	Write-Host ""
	Write-Host "     Lib environment variable: " $Env:LIB
	Write-Host "-------------------------------------------------------"
	Write-Host "All environment variables have been set!"
}