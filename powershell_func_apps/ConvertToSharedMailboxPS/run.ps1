using namespace System.Net

param($Request, $TriggerMetadata)

# Import functions
. (Join-Path $PSScriptRoot "ConvertToSharedMailbox.ps1")

$email = $Request.Query.Identity

if (-not $email) {
    $email = $Request.Body.Identity
}

if (-not $email) {
    $body = @{
        status  = "error"
        message = "Please provide a valid Identity."
    } | ConvertTo-Json

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = $body
    })
}

try {
    $result = ConvertToSharedMailbox -Identity $email

    $response = @{
        StatusCode = [HttpStatusCode]::OK
        Body = $result
    }

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]$response)

} catch {
    $response = @{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = "Error: $_"
    }
    
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]$response)
}
