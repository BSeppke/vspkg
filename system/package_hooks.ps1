#----------------- ADDITIONAL PATHS FOR 3RD PARTY PACKAGES --------------------

$VSP_PERL_PATH     = $VSP_INSTALL_PATH + "\perl"
$VSP_PERL_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/perl"
add-to-envVar-if-necessary "$VSP_PERL_PATH\bin" "PATH"
Add-Content $VSP_ENV_BATCHFILE "SET PATH=$VSP_PERL_PATH;%PATH%"

$VSP_SWIG_PATH     = $VSP_INSTALL_PATH + "\swig"
$VSP_SWIG_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/swig"
add-to-envVar-if-necessary "$VSP_SWIG_PATH" "PATH"
Add-Content $VSP_ENV_BATCHFILE "SET PATH=$VSP_SWIG_PATH;%PATH%"

$VSP_PYTHON_PATH     = $VSP_INSTALL_PATH + "\python"
$VSP_PYTHON_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/python"
$Env:PYTHONHOME      = $VSP_PYTHON_PATH
Add-Content $VSP_ENV_BATCHFILE "SET PYTHONHOME=$VSP_PYTHON_PATH"


add-to-envVar-if-necessary $VSP_PYTHON_PATH "PATH"
add-to-envVar-if-necessary "$($VSP_PYTHON_PATH)\DLLs" "PATH"
add-to-envVar-if-necessary "$($VSP_PYTHON_PATH)\Scripts" "PATH"
Add-Content $VSP_ENV_BATCHFILE "SET PATH=$VSP_PYTHON_PATH;$VSP_PYTHON_PATH\DLLs;$VSP_PYTHON_PATH\Scripts;%PATH%"

$VSP_QT4_PATH     = $VSP_INSTALL_PATH + "\qt"
$VSP_QT4_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/qt"

$VSP_QT5_PATH     = $VSP_INSTALL_PATH + "\qt5"
$VSP_QT5_UNIXPATH = $VSP_INSTALL_UNIXPATH + "/qt5"

#Switch for qt4 or qt5 in PATH. You have to decide for ONE!
$Env:QTDIR        = $VSP_QT5_PATH
Add-Content $VSP_ENV_BATCHFILE "SET QTDIR=$VSP_QT5_PATH"

add-to-envVar-if-necessary "$Env:QTDIR\bin" "PATH"
Add-Content $VSP_ENV_BATCHFILE "SET PATH=$VSP_QT5_PATH\bin;%PATH%"
