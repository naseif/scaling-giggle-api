<#
  This script changes the configuration for nginx so the user does not have to do anything
#>
Param (
  [Parameter(Mandatory=$true)]
  [string]$domainName
)

Push-Location $PSScriptRoot

$content = Get-Content scaling-giggle-nginx.conf -Raw
$content = $content.Replace("mydomain.com", $domainName)
$content | Set-Content /etc/nginx/sites-available/default

Pop-Location
