using namespace System.Security.Claims

# Validate AAD token and get user's claims
function Get-UserClaims {
    param(
        [string]$AuthorizationHeader
    )

    if (-not $AuthorizationHeader.StartsWith("Bearer ")) {
        throw "Missing or invalid Authorization header"
    }

    $accessToken = $AuthorizationHeader.Substring(7)
    $validationParameters = New-Object Microsoft.IdentityModel.Tokens.TokenValidationParameters
    $validationParameters.ValidateIssuer = $true
    $validationParameters.ValidAudience = $env:APP_REGISTRATION_CLIENT_ID
    $validationParameters.IssuerSigningKey = $env:APP_REGISTRATION_SIGNING_KEY

    $jwtHandler = New-Object Microsoft.IdentityModel.JsonWebTokens.JsonWebTokenHandler
    $validatedToken = $jwtHandler.ValidateToken($accessToken, $validationParameters)

    return $validatedToken.Claims
}