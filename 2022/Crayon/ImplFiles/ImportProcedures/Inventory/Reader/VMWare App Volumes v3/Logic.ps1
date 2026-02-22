# Security Protocol = TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function GetVersion {
	param (
		[Parameter(Mandatory = $true)]
		[string]$WebServicesURI
	)

	$uri = $WebServicesURI + "/version"

	try {
		$result = Invoke-RestMethod -Method Get -Uri $uri -ErrorAction Stop
	} catch {
		throw "Error when invoking REST method"
	}

	Write-Verbose "VMWare App Volumes version: '$($result.internal)'"

	if (!($result.internal -match "[0-9]*\.[0-9]*.*"))
	{
		throw "ERROR: The App Volumes version '$($result.internal)' is not in a recognisable format.  Expecting it to start with 'X.Y'"
	}

	$versionParts = $result.internal -split "\."
	$version = "$($versionParts[0]).$($versionParts[1])"

	Write-Verbose "VMWare App Volumes major.minor version: '$version'"

	$obj = New-Object -TypeName PSObject
	$obj | Add-Member -MemberType NoteProperty -Name Version -Value $version

	return $obj
}


function TestConnection {
	param (
		[Parameter(Mandatory = $true)]
		[string]$WebServicesURI,
		[Parameter(Mandatory = $true)]
		[string]$Username,
		[Parameter(Mandatory = $true)]
		[string]$Password
	)

	try	{
		$session = GetSession $WebServicesURI $Username $Password
		$result = 'OK'		
	}	
	catch {
		Write-Error "Test connection failure - `r`n$($_.Exception.Message)" -ErrorAction Continue
		exit
	}

	return $result
}


function GetSession {
	param (
		[Parameter(Mandatory = $true)]
		[string]$WebServicesURI,
		[Parameter(Mandatory = $true)]
		[string]$Username,
		[Parameter(Mandatory = $true)]
		[string]$Password
	)

	$body = @{
		username = $username
		password = $password
    }

	$uri = $WebServicesURI + "/sessions"

	try	{
		$result = Invoke-RestMethod -SessionVariable apiSession -Method Post -Uri $uri -Body $body -ErrorAction Stop
	}
	catch {
		throw
	}

	return $apiSession
}


function GetPackages {
	param (
		[Parameter(Mandatory = $true)]
		[string]$WebServicesURI,
		[Parameter(Mandatory = $true)]
		[string]$Username,
		[Parameter(Mandatory = $true)]
		[string]$Password
	)

	$packageObj = New-Object PSObject -Property @{
		PackageID = $null
		PackageName	= ""
		Status = ""
	}
	
	try	{
		$session = GetSession $WebServicesURI $Username $Password

		$appStacksURI = $WebServicesURI + "/appstacks"
		$pkgs = Invoke-RestMethod -WebSession $session -Method Get -Uri $appStacksURI -ErrorAction Stop
		Write-Verbose "Number of App Volumes packages: $($pkgs.count)"

		foreach($pkg in $pkgs)
		{
			$packageObj.PackageID = $pkg.id
			$packageObj.PackageName	= $pkg.name
			$packageObj.Status = $pkg.status
			$packageObj
		}
	}	
	catch {
		throw
	}
}


function GetPackageAssignments {
	param (
		[Parameter(Mandatory = $true)]
		[string]$WebServicesURI,
		[Parameter(Mandatory = $true)]
		[string]$Username,
		[Parameter(Mandatory = $true)]
		[string]$Password
	)

	$packageAssignmentObj = New-Object PSObject -Property @{
		PackageID = $null
		ObjectSID = ""
		ObjectType = ""
	}
	
	try	{
		$session = GetSession $WebServicesURI $Username $Password

		$appStacksURI = $WebServicesURI + "/appstacks"
		$pkgs = Invoke-RestMethod -WebSession $session -Method Get -Uri $appStacksURI -ErrorAction Stop
		Write-Verbose "Number of App Volumespackages: $($pkgs.count)"

		foreach($pkg in $pkgs)
		{
			Write-Verbose "Retrieved package id=$($pkg.id) name='$($pkg.name)' status=$($pkg.status)"

			$assignmentsURI = $appStacksURI + "/"+ $pkg.id+"/assignments"
			$pkgAssignments = Invoke-RestMethod -WebSession $session -Method Get -Uri $assignmentsURI -ErrorAction Stop
			Write-Verbose "Number of assignments to this package: $($pkgAssignments.count)"

			foreach($pkgAssignment in $pkgAssignments)
			{
				if ($pkgAssignment.entity_type -iin ("user", "group")) 
				{
					try {
						$tmp = $pkgAssignment.name.Split(">")[1]
						$objectSID = ADObjToSID($tmp.Substring(0, $tmp.length - 3))
					} catch {
						Write-Verbose $_.Exception.Message
						continue
					}

					$packageAssignmentObj.PackageID = $pkg.id
					$packageAssignmentObj.ObjectSID = $objectSID
					$packageAssignmentObj.ObjectType = $pkgAssignment.entity_type
					$packageAssignmentObj
				}
				else
				{
					Write-Verbose "Skipping package assignment '$($pkgAssignment.name)' as its entity_type '$($pkgAssignment.entity_type)' is not supported by this adapter"
				}
			}
		}

	}	
	catch {
		throw
	}


}


function GetApplications {
	param (
		[Parameter(Mandatory = $true)]
		[string]$WebServicesURI,
		[Parameter(Mandatory = $true)]
		[string]$Username,
		[Parameter(Mandatory = $true)]
		[string]$Password
	)

	$applicationObj = New-Object PSObject -Property @{
		ApplicationID = $null
		DisplayName = ""
		Version	= ""
		Publisher = ""
		PackageID = $null
	}
	
	try	{
		$session = GetSession $WebServicesURI $Username $Password

		$appStacksURI = $WebServicesURI + "/appstacks"
		$pkgs = Invoke-RestMethod -WebSession $session -Method Get -Uri $appStacksURI -ErrorAction Stop
		Write-Verbose "Number of App Volumespackages: $($pkgs.count)"

		foreach($pkg in $pkgs)
		{
			Write-Verbose "Retrieved package id=$($pkg.id) name='$($pkg.name)' status=$($pkg.status)"

			$applicationsURI = $appStacksURI + "/"+ $pkg.id+"/applications"
			$pkgApplications = Invoke-RestMethod -WebSession $session -Method Get -Uri $applicationsURI -ErrorAction Stop
			Write-Verbose "Number of applications in this package: $($pkgApplications.count)"

			foreach($pkgApplication in $pkgApplications.applications)
			{
				$applicationObj.ApplicationID = $pkgApplication.id
				$applicationObj.DisplayName = $pkgApplication.name
				$applicationObj.Version = $pkgApplication.version
				$applicationObj.Publisher = $pkgApplication.publisher
				$applicationObj.PackageID = $pkg.id
				$applicationObj
			}
		}
	}	
	catch {
		throw
	}
}


function ADObjToSID([string] $AdObject)
{
    $AdObj = New-Object System.Security.Principal.NTAccount($AdObject)

    Try
    {
        $strSID = $AdObj.Translate([System.Security.Principal.SecurityIdentifier])
    }
    catch
    {
        throw "AD Object '$AdObject' not found"
    }

    Return $strSID.Value
}
