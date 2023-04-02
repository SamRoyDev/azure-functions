using namespace System.Net

param($Request, $TriggerMetadata)

# Need to import helper functions
. (Join-Path $PSScriptRoot "helpers/Authorization.ps1")
. (Join-Path $PSScriptRoot "ConvertToSharedMailbox.ps1")

# Load request body
$requestBody = Get-Content $Request -Raw | ConvertFrom-Json 

try {
    $result = isValidToken -AuthorizationHeader $Request.Headers.Authorization

    #$result = ConvertToSharedMailbox -parameter $requestBody.userId

    $response = @{
        StatusCode = [HttpStatusCode]::OK
        Body = $result
    }

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]$response)

} catch {
    $response = @{
        StatusCode = [HttpStatusCode]::Unauthorized
        Body = "Unauthorized access: $_"
    }
    
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]$response)
}
