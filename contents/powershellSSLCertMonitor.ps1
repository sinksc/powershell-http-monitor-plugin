param(
    [Parameter(Mandatory=$true)]
    [string]$url,
    
    [Parameter(Mandatory=$false)]
    [int]$threshold = 30
)

# Create a web request to the URL
$request = [Net.HttpWebRequest]::Create($url)

# Set the request to use SSL/TLS and ignore certificate errors
$request.UseDefaultCredentials = $true
$request.Method = "GET"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Get the response from the server
$response = $request.GetResponse()

# Get the SSL certificate from the ServicePointManager
$certificate = [System.Net.ServicePointManager]::FindServicePoint($url).Certificate

# Get the expiration date of the certificate
$expirationDate = $certificate.GetExpirationDateString()

# Calculate the number of days left before the certificate expires
$daysLeft = (New-TimeSpan -Start (Get-Date) -End $expirationDate).Days

# Check if the days left is less than the threshold
if ($daysLeft -lt $threshold) {
    Write-Output "The SSL certificate for $url expires in less than $threshold days, on $expirationDate. $daysLeft days left; Please renew it."
    $exit_code=1
} else {
    $exit_code=0
    Write-Output "The SSL certificate for $url expires on: $expirationDate, which is in $daysLeft days."
}
    
Write-Output "RUNDECK:DATA:EXIT_CODE=$exit_code"
exit $exit_code
