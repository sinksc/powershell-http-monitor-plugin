param(
    [Parameter(Mandatory=$true)][string]$url,
    [Parameter(Mandatory=$true)][string]$test,
    [Parameter(Mandatory=$false)][string]$user,
    [Parameter(Mandatory=$false)][string]$password,
    [Parameter(Mandatory=$false)][string]$method = 'Get'
)

$ProgressPreference = "SilentlyContinue"

# Strip spaces from test string
$test = $test.Trim()

# Create a password object
if ($user -and $password) {
    $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
}

# Send a web request
if ($mycreds) {
    $response = Invoke-WebRequest -Uri $url -Method $method -Credential $mycreds -UseBasicParsing
} else {
    $response = Invoke-WebRequest -Uri $url -Method $method -UseBasicParsing
}

# Search the response content for the test string
if ($response.Content -notmatch $test) {
    Write-Error "Test string '$test' not found in response from '$url'"
    $exit_code=1
} else {
    Write-Output "Test string '$test' found in response from '$url'"
    $exit_code=0
}

Write-Output "RUNDECK:DATA:EXIT_CODE=$exit_code"
exit $exit_code