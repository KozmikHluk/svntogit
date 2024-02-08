param(
    [switch] $whatif,
    [string] $V_SVNProjectName = $(Read-Host "Name defined for SVN project to use ex. TCSBI"),
    [string] $V_BBInstanceUrl = $(Read-Host "Enter URL to Bitbucket Instance"),
    [string] $V_BBProj = $(Read-Host "Enter BB Project Key")
)

write-host $V_BBInstanceUrl, $V_BBProj, $V_SVNProjectName