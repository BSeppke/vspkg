param([switch]$silent)

# ------------- SOME VERY HANDY FUNCTIONS -----------------------

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
	
	#If file.tar.gz unzips to file.tar, we will unzip file.tar, too.
	$file_tar = ([io.fileinfo]$file).basename
	if( ([io.fileinfo] $file_tar).Extension -eq ".tar")
	{
		if (Test-Path $file_tar)
		{
			& "$7ZipPath" "x" $file_tar "-aoa"
			rm $file_tar
		}
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
		throw "Checksums does not match! $checksum != $md5"
	}
}

#Download a file, check the MD5 hash and unpack it
function download-check-unpack-file
{
	param($source, $dest, $md5)
	
	download-file $source $dest
	check-unpack-file $dest $md5
}

