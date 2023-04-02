using namespace System.Net
using namespace System.Web

# import helper functions
. (Join-Path $PSScriptRoot "../helpers/CertificateAuthentication.ps1")
function ConvertToSharedMailbox {
    param (
        [Parameter(Mandatory = $true)][string]$Identity
    )

    try {
        # Generate certificate using helper function
        $SecureCertPassword = $env:CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
        $Certificate = GetExchangeAuthCertificate -CertBase64 $env:CERT_BASE64 -CertPassword $SecureCertPassword

        # Check if the ExchangeOnlineManagement module is already imported
        if (-not (Get-Module -Name ExchangeOnlineManagement)) {
            # If the module is not imported, import it
            Import-Module ExchangeOnlineManagement -ErrorAction Stop
        }
        
        # Connect to Exchange Online
        Connect-ExchangeOnline -Certificate $Certificate -AppId $env:AZURE_APP_ID -Organization $env:AZURE_ORG

        # Convert user mailbox to shared mailbox
        #Set-Mailbox -Identity $userId -Type Shared -ErrorAction Stop
        $result = Get-Mailbox -Identity $Identity

        # Disconnect from Exchange Online
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction Stop

        if ($result) {
            $body = @{
                status = "success"
                result = $result
            } | ConvertTo-Json
        }
        else {
            $body = @{
                status  = "error"
                message = "[ConvertToSharedMailbox] Error: No response"
            } | ConvertTo-Json
        }

        return $body
    }
    catch {
        return "[ConvertToSharedMailbox] Error: $_"
    }
}