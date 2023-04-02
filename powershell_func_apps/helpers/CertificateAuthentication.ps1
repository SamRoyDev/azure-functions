function GetExchangeAuthCertificate {
    param (
        [Parameter(Mandatory = $true)][string]$CertBase64,
        [Parameter(Mandatory = $true)][securestring]$CertPassword
    )

    try {
        # Convert the Base64 string to a byte array
        $certBytes = [Convert]::FromBase64String($CertBase64)
        $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($certBytes, $CertPassword)
        
        return $cert
    }
    catch {
        $body = @{
            status  = "error"
            message = "Error: Could not create X509 certificate. Details: $_"
        } | ConvertTo-Json

        return $body
    }
}