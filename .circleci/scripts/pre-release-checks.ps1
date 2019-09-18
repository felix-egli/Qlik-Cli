param (
  $Path
)

$ErrorActionPreference = "Stop"

if ($Path) { Push-Location $Path }

if ((Test-ModuleManifest -Path ./Qlik-Cli.psd1).Version -le (Find-Module -Name Qlik-Cli).Version) {
  Write-Error "Module version already exists"
}

$release = Invoke-RestMethod `
  -Method Get `
  -Uri "https://api.github.com/repos/ahaydon/qlik-cli/releases/latest"

if ((Test-ModuleManifest -Path ./Qlik-Cli.psd1).Version -le [System.Version]$release.tag_name) {
  Write-Error "Module version must be newer than last published version"
}

$version = (Test-ModuleManifest -Path ./Qlik-Cli.psd1).Version
$release = $null
$null = try {
  $release = Invoke-RestMethod `
    -Method Get `
    -Uri "https://api.github.com/repos/ahaydon/qlik-cli/releases/tags/$version" `
    -ErrorAction SilentlyContinue
} catch [System.Net.Http.HttpRequestException] {
  if ($_.Exception.Response.StatusCode -ne "NotFound") {
    Throw $_
  }
  $Error | Out-Null #clear the error so we exit cleanly
}

if ($release) {
  Write-Error "Module version already exists"
}
