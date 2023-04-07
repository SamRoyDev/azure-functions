using namespace System.Net

param($Request, $TriggerMetadata)

# import helper functions
. (Join-Path $PSScriptRoot "../helpers/CertificateAuthentication.ps1")

$email = $Request.Body.email
$customAttribute = $Request.Body.customAttribute
$customAttributeValue = $Request.Body.customAttributeValue

function SendErrorResponse ($message) {
    $body = @{
        status  = "error"
        message = $message
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = $body
    })
}

if (-not $email) {
    SendErrorResponse "Please provide an email address."
} elseif (-not $customAttribute) {
    SendErrorResponse "Please provide a customAttribute."
} elseif (-not $customAttributeValue) {
    SendErrorResponse "Please provide a customAttributeValue."
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

# Update the custom attribute
$updateUser = Set-Mailbox -Identity $UserPrincipalName -$CustomAttributeName $CustomAttributeValue

# Verify the custom attribute has been updated
$updatedUser = Get-Mailbox -Identity $UserPrincipalName -PropertySets Minimum

# Disconnect from Exchange Online
Disconnect-ExchangeOnline

if ($updateUser) {
    $body = @{
        status        = "success"
        updatedUser = $updatedUser
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $body
    })
} else {
    $body = @{
        status  = "error"
        message = "User attribute updates not completed. Check that the user exists or the custom attribute is correct."
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