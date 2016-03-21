#----------------- SET ADDITIONAL PATHS FOR PERL, PYTHON AND QT--------------
$VSP_PERL_PATH     = $VSP_INSTALL_PATH + "\perl"
$VSP_PERL_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/perl"

$VSP_PYTHON_PATH     = $VSP_INSTALL_PATH + "\python"
$VSP_PYTHON_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/python"
$Env:PYTHONHOME      = $VSP_PYTHON_PATH

$VSP_QT4_PATH     = $VSP_INSTALL_PATH + "\qt"
$VSP_QT4_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/qt"

$VSP_QT5_PATH     = $VSP_INSTALL_PATH + "\qt5"
$VSP_QT5_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/qt5"

#Switch for qt4 or qt5
$Env:QTDIR        = $VSP_QT5_PATH

#------------------ ADD ADDITIONAL DIRECTORIES TO ENV -----------------------
add-to-envVar-if-necessary "$VSP_PERL_PATH\bin" "PATH"

add-to-envVar-if-necessary $VSP_PYTHON_PATH "PATH"
add-to-envVar-if-necessary "$($VSP_PYTHON_PATH)\DLLs" "PATH"
add-to-envVar-if-necessary "$($VSP_PYTHON_PATH)\Scripts" "PATH"

add-to-envVar-if-necessary "$Env:QTDIR\bin" "PATH"