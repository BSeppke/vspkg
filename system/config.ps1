param([switch]$silent)

#------------ SET WINDOWS VERSION TO BUILD FOR: WIN32 OR WIN64 --------------
#$VSP_BUILD_ARCH = "Win32"
$VSP_BUILD_ARCH = "x64"

#------- SET THE VERSION OF VISUAL STUDIO (10 = 2010) OR (11 = 2012)---------
#$VSP_MSVC_VER = "10"
$VSP_MSVC_VER = "11"


#----------------------- SET THE BASE (INSTALLATION) PATH -------------------
$VSP_BASE_PATH = "C:\vspkg"
$VSP_BASE_UNIXPATH = "C:/vspkg"
