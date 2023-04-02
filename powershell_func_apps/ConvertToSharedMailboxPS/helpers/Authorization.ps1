using namespace System.IdentityModel.Tokens.Jwt
using namespace Microsoft.IdentityModel.Tokens

# Validate AAD token and get user's claims
function isValidToken {
    param(
        [string]$AuthorizationHeader
    )

    $clientSecret = $env:APP_REGISTRATION_SECRET
    $tenantId = $env:AZURE_TENANT_ID

    if (-not $AuthorizationHeader.StartsWith("Bearer ")) {
        throw "Missing or invalid Authorization header"
    }

    $extractedToken = $AuthorizationHeader.Substring("Bearer ".Length)

    try {
        $openIdConfigUrl = "https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration"
        $openIdConfig = Invoke-RestMethod -Uri $openIdConfigUrl

        $tokenValidationParameters = @{
            ValidateAudience   = $false
            ValidateIssuer     = $true
            ValidIssuer        = $openIdConfig.issuer
            IssuerSigningKey   = [Microsoft.IdentityModel.Tokens.JsonWebKey]::CreateFromSecret($clientSecret)
            ValidateLifetime   = $true
        }

        $jwtHandler = New-Object JwtSecurityTokenHandler
        $jwtHandler.ValidateToken($extractedToken, $tokenValidationParameters, [ref]$null)

        return $true
    }
    catch {
        return $_.Exception.Message
    }
}