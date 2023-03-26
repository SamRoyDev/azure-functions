param(
    [string]$EmailAddress
)

# Set your application credentials here
$AppId = "<Your-App-Id>"
$TenantId = "<Your-Tenant-Id>"
$ClientSecret = "<Your-Client-Secret>"

$ExchangeModuleUrl = "https://outlook.office365.com/PowerShell-LiveID?BasicAuthToOAuthConversion=true"
$Credential = New-Object PSCredential($AppId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeModuleUrl -Credential $Credential -Authentication OAuth -AllowRedirection -ErrorAction Stop

Import-PSSession $Session -DisableNameChecking
Connect-ExchangeOnline -AppId $AppId -CertificateFilePath $ClientSecret -TenantId $TenantId

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
