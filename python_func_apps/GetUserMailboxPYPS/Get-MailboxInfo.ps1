param(
    [string]$EmailAddress
)

$TenantId = $env:TENANT_ID
$AppId = $env:APP_ID
$CertBase64 = $env:CERT_BASE64
$CertPassword = ConvertTo-SecureString -String $env:CERT_PASSWORD -Force -AsPlainText

Write-Host "TenantId: $TenantId"
Write-Host "AppId: $AppId"
Write-Host "CertBase64: $CertBase64"
Write-Host "Cert passwords: $env:CERT_PASSWORD --- $CertPassword"

try {
    # Convert the Base64 string to a byte array
    $certBytes = [Convert]::FromBase64String($CertBase64)
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($certBytes,$CertPassword)
    $cert
}
catch {
    Write-Host "Error: Could not create X509 certificate. Details: $_)"
    exit 1
}

# Check if NuGet provider is already installed
if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Scope CurrentUser -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

# Import Exchange Online Management module
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force

# Connect to Exchange Online
#Connect-ExchangeOnline -Credential $credential -ErrorAction Stop
Connect-ExchangeOnline -Certificate $cert -AppId $AppId -Organization $TenantId -ShowBanner:$false

$Mailbox = Get-Mailbox -Identity $EmailAddress
if ($Mailbox) {
    Write-Output "Mailbox information for $($EmailAddress):"
    Write-Output "DisplayName: $($Mailbox.DisplayName)"
    Write-Output "Alias: $($Mailbox.Alias)"
    Write-Output "PrimarySmtpAddress: $($Mailbox.PrimarySmtpAddress)"
} else {
    Write-Output "Mailbox not found for $($EmailAddress)"
}

Disconnect-ExchangeOnline -Confirm:$false
Remove-PSSession $Session

exit 0