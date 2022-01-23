param([switch]$silent)

#Define the scrips path as the internal systems path
$VSP_SYSTEM_PATH = split-path -parent $MyInvocation.MyCommand.Definition

#Load the current configuration(at same "." dir)
. "$VSP_SYSTEM_PATH\config.ps1" -silent $silent

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
		pushd "$VSP_VCVARS_PATH"
		cmd /c "vcvarsall.bat $($architecture)&set" |
		foreach {
			if ($_ -match "=") {
				$v=$_.split("=")
				set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
			}
		}
		popd
	}
}

# Set all depending variables
$ORIGINAL_PATH = "$Env:PATH"

$VSP_PKG_PATH     = "$VSP_BASE_PATH" + "\packages"
$VSP_INSTALL_PATH = "$VSP_BASE_PATH" + "\vc" + $VSP_MSVC_VER + "\" + $VSP_BUILD_ARCH
$VSP_INSTALL_REGISTRY_PATH = "$VSP_INSTALL_PATH" +"\installed_packages"

$VSP_PKG_UNIXPATH     = "$VSP_BASE_UNIXPATH" + "/packages"
$VSP_SYSTEM_UNIXPATH  = "$VSP_BASE_UNIXPATH" + "/system"
$VSP_INSTALL_UNIXPATH = "$VSP_BASE_UNIXPATH" + "/vc" + $VSP_MSVC_VER + "/" + $VSP_BUILD_ARCH
$VSP_INSTALL_REGISTRY_UNIXPATH = "$VSP_INSTALL_UNIXPATH" +"/installed_packages"

$VSP_ENV_BATCHFILE =  "$VSP_INSTALL_PATH" + "\environment.bat"


# Create Startup Batch file for current config:
if (Test-Path $VSP_ENV_BATCHFILE)
{
	rm $VSP_ENV_BATCHFILE
}



#-------------- SET AND CALL THE CORRESPONDING VC SETTINGS ------------------
$VSP_MSVC_ARCH_FLAGS = "x86"
if ($VSP_BUILD_ARCH -eq "x64")
{
	$VSP_MSVC_ARCH_FLAGS = "amd64"
}
add-vs-variables-if-necessary $VSP_MSVC_VER $VSP_MSVC_ARCH_FLAGS
Add-Content $VSP_ENV_BATCHFILE "@echo off"

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

$VSP_GIT_PATH =  $Env:LocalAppData + "\Programs\Git\bin"

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

#------------------ ADD VSP DIRECTORIES TO ENV -----------------------
set-item "Env:\VSP_INSTALL_PATH" $VSP_INSTALL_PATH 
add-to-envVar-if-necessary $VSP_LIB_PATH "LIB"
Add-Content $VSP_ENV_BATCHFILE "SET LIB=$VSP_LIB_PATH;%LIB%"

add-to-envVar-if-necessary $VSP_INCLUDE_PATH "INCLUDE"
Add-Content $VSP_ENV_BATCHFILE "SET INCLUDE=$VSP_INCLUDE_PATH;%INCLUDE%"

add-to-envVar-if-necessary $VSP_BIN_PATH "PATH"
add-to-envVar-if-necessary $VSP_GIT_PATH "PATH"
Add-Content $VSP_ENV_BATCHFILE "SET PATH=$VSP_BIN_PATH;$VSP_GIT_PATH;%PATH%"

#----------------- ADD ADDITIONAL PATHS FOR 3RD-PARTY APPS/LIBS--------------
$packageHooksScript  = join-path $VSP_SYSTEM_PATH "package_hooks.ps1"
. $packageHooksScript

Add-Content $VSP_ENV_BATCHFILE "cmd /k `"$VSP_VCVARS_PATH\vcvarsall.bat`" $VSP_MSVC_ARCH_FLAGS"

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