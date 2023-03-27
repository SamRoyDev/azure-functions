import logging
import azure.functions as func
import os
import windows_tools.powershell


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    tenant_id = os.environ.get('TENANT_ID')
    app_id = os.environ.get('APP_ID')
    cert_base64 = os.environ.get('CERT_BASE64')

    # Print the environment variables for debugging
    print(f"TenantId: {tenant_id}")
    print(f"AppId: {app_id}")
    print(f"CertBase64: {cert_base64}")

    email = req.params.get('email')
    if not email:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            email = req_body.get('email')

    if email:
        # Find the PowerShell executable
        powershell_runner = windows_tools.powershell.PowerShellRunner()

        # Set the PowerShell script path
        current_directory = os.path.dirname(os.path.abspath(__file__))
        powershell_script_path = os.path.join(current_directory, "Get-MailboxInfo.ps1")

        try:
            exit_code, output = powershell_runner.run_script(
                powershell_script_path, email)
            # Return the output as an HTTP response
            return func.HttpResponse(output, status_code=200)
        except Exception as e:
            logging.error(
                f"An error occurred while running the PowerShell script: {str(e)}")
            return func.HttpResponse(
                f"Error running PowerShell script: {str(e)}",
                status_code=500
            )
    else:
        return func.HttpResponse(
            "Please pass an email on the query string or in the request body",
            status_code=400
        )
