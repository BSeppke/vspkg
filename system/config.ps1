param([switch]$silent)

#------------ SET WINDOWS VERSION TO BUILD FOR: WIN32 OR WIN64 --------------
#$VSP_BUILD_ARCH = "Win32"
$VSP_BUILD_ARCH = "x64"

#------------------- SET THE VERSION OF VISUAL STUDIO ------------------------
# Allowed version: 10 (= 2010), 11 (= 2012), 12 (= 2013), 14 (= 2015), 15 (=2017)
#$VSP_MSVC_VER = "10"
#$VSP_MSVC_VER = "11"
#$VSP_MSVC_VER = "12"
#$VSP_MSVC_VER = "14"
$VSP_MSVC_VER = "15"

#----------------- SET THE PATH TO THE VCVARSALL.BAT FILE OF VISUAL STUDIO -----------------
#$VSP_VCVARS_PATH = "C:\Program Files (x86)\Microsoft Visual Studio $VSP_MSVC_VER.0\VC"
$VSP_VCVARS_PATH = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build"

#----------------------- SET THE BASE (INSTALLATION) PATH -------------------
$VSP_BASE_PATH = "C:\vspkg"
$VSP_BASE_UNIXPATH = "C:/vspkg"