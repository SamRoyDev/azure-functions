using namespace System.Net

param($Request, $TriggerMetadata)

# import helper functions
. (Join-Path $PSScriptRoot "../helpers/CertificateAuthentication.ps1")

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

try {
    # Generate certificate using helper function
    $SecureCertPassword = $env:CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
    $Certificate = GetExchangeAuthCertificate -CertBase64 $env:CERT_BASE64 -CertPassword $SecureCertPassword

    # Load Exchange Online Management module
    Import-Module ExchangeOnlineManagement
    Get-Module ExchangeOnlineManagement

    # Connect to Exchange Online
    Connect-ExchangeOnline -Certificate $Certificate -AppId $env:AZURE_APP_ID -Organization $env:AZURE_ORG
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