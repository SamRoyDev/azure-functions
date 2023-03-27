# Set certificate parameters
$certName = "AzureFunctions2023"
$certSubject = "CN=AzureFunctions2023"
$certPassword = ConvertTo-SecureString -String "cortica" -Force -AsPlainText
$certStartDate = Get-Date
$certEndDate = $certStartDate.AddYears(1)

# Generate a self-signed certificate
$NewCert = New-SelfSignedCertificate -DnsName $certSubject -CertStoreLocation "cert:\LocalMachine\My" -NotAfter $certEndDate -NotBefore $certStartDate -FriendlyName $certName -KeySpec Signature -KeyUsage DigitalSignature

# Export the certificate to PFX and CER files
$PFXFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "$certName.pfx"
$CERFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "$certName.cer"
$CertThumbprint = $NewCert.Thumbprint
Export-PfxCertificate -Cert "cert:\LocalMachine\My\$CertThumbprint" -FilePath $PFXFilePath -Password $certPassword
Export-Certificate -Cert "cert:\LocalMachine\My\$CertThumbprint" -FilePath $CERFilePath