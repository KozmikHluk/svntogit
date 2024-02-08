param (
    [string] $username,
    [string] $password,
    [string] $BBInstance,
    [string] $Project,
    [string] $Repo,
    [string] $Desc,
    [string] $defaultBranchId
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

[System.UriBuilder]$builder = "https://$($BBInstance)"

$builder.Path = "j_atl_security_check"

$parameters = @{
    Uri         = $builder.Uri
    ContentType = 'application/x-www-form-urlencoded'
    Body        = "j_username=$($username)&j_password=$($password)&submit=Log+in"
    Method      = 'POST'
}

$response = Invoke-WebRequest @parameters -SessionVariable session

if ($response.StatusCode -ne 200) {
    Write-Error 'Credential is not valid' -ErrorAction Stop
}

$builder.Path = "rest/api/1.0/projects/$($Project)/repos/$($Repo)"

$isMissingRepo = $(
    try {
        Invoke-WebRequest -WebSession $session -Uri $builder.Uri -ErrorAction SilentlyContinue -UseBasicParsing
    } catch {
        $_.Exception.Response
    }
).StatusCode -eq 404

if ($isMissingRepo) {
    $builder.Path = "rest/api/1.0/projects/$($Project)/repos"

    $parameters = @{
        Uri     = $builder.Uri
        Method  = "POST"
        Body    = $(
            @{
                name  = "$($Repo)"
                scmId = "git"
            } |
                ConvertTo-Json -Compress
        )
        Headers = @{
            'Content-Type'      = 'application/json'
            'X-Atlassian-Token' = 'nocheck'
        }
    }

    $response = Invoke-RestMethod @parameters -UseBasicParsing -WebSession $session
} else {
    Write-Host "$($Repo) already exists. Skipping creation." -ForegroundColor Green
}

$builder.path = "projects/$($Project)/repos/$($Repo)/settings"

$parameters = @{
    Uri = $builder.Uri
}
[Microsoft.PowerShell.Commands.HtmlWebResponseObject] $response = Invoke-WebRequest -WebSession $session @parameters

$name = $response.Forms.Fields.name
IF ( [String]::IsNullOrEmpty($defaultBranchId)){
	$defaultBranchId = $response.Forms.Fields.'default-branch-field'
}
$token = $response.Forms.Fields.atl_token

$query = @(
    if ($name) {
        "name=$name"
    }

    if ($Desc) {
        "description=$Desc"
    }

    if ($defaultBranchId) {
        "defaultBranchId=$defaultBranchId"
    }

    "forkable=on"
    "git-enable-transcoding=off"

    if ($token) {
        "atl_token=$token"
    }

    "lfsRepoEnabled=on"
    "submit=Save"
) -join '&'

$parameters = @{
    Uri         = $builder.Uri
    ContentType = 'application/x-www-form-urlencoded'
    Body        = $query
    Method      = 'POST'
}

Invoke-WebRequest -WebSession $session @parameters
