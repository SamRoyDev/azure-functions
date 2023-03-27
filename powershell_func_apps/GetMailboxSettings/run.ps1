using namespace System.Net

param($Request, $TriggerMetadata)

$email = $Request.Query.email

if (-not $email) {
    $email = $Request.Body.email
}

if (-not $email) {
    $body = @{
        status  = "error"
        message = "Please provide an email address."
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = $body
    })
}

$TenantId = $env:AZURE_ORG
$AppId = $env:AZURE_APP_ID
$CertBase64 = $env:CERT_BASE64
$CertPassword = ConvertTo-SecureString -String $env:CERT_PASSWORD -Force -AsPlainText

try {
    # Convert the Base64 string to a byte array
    $certBytes = [Convert]::FromBase64String($CertBase64)
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($certBytes,$CertPassword)
    $cert
}
catch {
    $body = @{
        status  = "error"
        message = "Error: Could not create X509 certificate. Details: $_"
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = $body
    })
}

try {
    # Load Exchange Online Management module
    Import-Module ExchangeOnlineManagement
    Get-Module ExchangeOnlineManagement

    # Connect to Exchange Online
    Connect-ExchangeOnline -Certificate $cert -AppId $AppId -Organization $TenantId -ShowBanner:$false
}
catch {
    $body = @{
        status  = "error"
        message = "Error: Could not connect to exchange online. Details: $_"
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = $body
    })
}

# Retrieve mailbox settings
$mailboxSettings = Get-Mailbox -Identity $email

# Disconnect from Exchange Online
Disconnect-ExchangeOnline

if ($mailboxSettings) {
    $body = @{
        status        = "success"
        mailboxSettings = $mailboxSettings
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $body
    })
} else {
    $body = @{
        status  = "error"
        message = "Mailbox settings not found for the given email address."
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::NotFound
        Body = $body
    })
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})