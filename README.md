vspkg
=====

A linux-like package manager for Windows, especially for MS Visual Studio

The aim of this project is to port at least some of the functionality of a powerful package manager (like dpkg for linux or MacPorts for Mac) to Windows / Microsoft Visual Studio. If successful, this will greatly enhance the work using (open source) tools like we know it from Linux systems. Fortunately, the Windows PowerShell provides at least a usable shell to implement such a system.

1. Prerequisites
----------------
vspkg is written using the Windows PowerShell 2.0. This implies, that you need to have at least Windows XP installed on your Computer. It should also work with any newer Windows Version, and hopefully any newer PowerShell version, accordingly.
Many packages will be compiled using C/C++ and thus require Microsoft Visual Studio to be installed, too. Currently, the packages shall compile fine for Visual Studio 2010 and 2012 (for both, 32- and 64-bit). Please make sure to have the lastest Service Packs installed, too.

2. Installation
---------------
Just clone the repo into a directory, let's say "C:\vspkg". 
Before the first start, you may need to edit the file "C:\vspkg\system\config.ps1" to work with the desired Visual Studio version and to produce either 32-bit or 64-bit binaries as well as setting the output path on your hdd. These settings can be performed at lines 200 -- 215.

3. Using the vspkg system
---------------------------------
So far, the real use of this package manager is quite limited. It only supports building and installation of the desired packages and (recursive) dependencies of packages. An uninstall procedure is still missing. And the amount of available packages is still very small. But nevertheless, for me this has become a really valuable piece of software. 

The package script for each package can be found in subfolders named like the package. E.g. if you want to install the HDF5 package and all its dependencies, perform the following tasks:

1. Open a new PowerShell console
2. Browse to the package directory and run the package script:

> PS C:\> cd C:\vspkg\packages\hdf5

> PS C:\vspkg\packages\hdf5> .\package.ps1

This should create the hdf5 package.

4. Understanding the vspkg system
---------------------------------
The vspkg system is quite small, since literally consists of recipes and patches of the packages, neither the source code nor the binaries are included. Thus, every "package.ps1" call need to perform some actions to install a package:

1. Determine if package has already been installed (see installed_packages below).
2. If not: 
  - Install all the dependencies.
  - Fetch the source archive and unpack it.
  - Patch it if necessary.
  - Build the binaries
  - Install binaries, headers, docs and shared files.
  - Mark package as installed.

It's worth mentioning, that the download of packages is secured using the MD5 hashes of the packages. 

The directory structure of the vspkg results is yet very simple: "C:\vspkg\system\config.ps1" contains all the stuff to initialize the system and the main functions e.g. for downloading and compiling as well as defining the most important paths. These are (by default) Linux-line sub-folders of "C:\vspkg\vc{10|11}\{Win32|x64}":

- **bin** for binaries and DLLs
- **doc** for documentations 
- **include** for header files
- **installed_packages** each installed package creates a log file here. Is also used to determine if a package has been installed.
- **lib** for lib files (static libs and include lib-files for DLLs)
- **man** for Linux-like manpages
- **perl** holding perl, if it has been installed as a package
- **python** holding python, if it has been installed as a package
- **share** shared files for different packages
- **ssl** holding ssl-specific files, if the openssl has been installed as a package




