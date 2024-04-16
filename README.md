# powershell-http-monitor-plugin (Windows)

Rundeck plugin to perform various HTTP monitoring operations for a website, such as:
* Submit a reqeust to an HTTP URL and look for a specific string in the response
* Check an HTTPS URL to see how long before it expires, and fail/alert if that date falls within a specified threshold.

If you are responsible for monitoring an HTTP application for availability or SSL certificate expirations, you can create a job using this plugin and schedule it to check your site on a recurring basis.

## Usage

### powershell / http / monitor

For a given HTTP URL and string to look for in the response, if that string isn't found in the response it will trigger a failure. This can in turn trigger Notifications or more advanced error processing.

### Pre-Requisites

#### Rundeck setup

If you plan to pass a username and password for server authentication, create an item in Rundeck's [Key Storage](<https://www.rundeck.com/blog/use-rundecks-key-storage-to-manage-passwords-and-secrets>) to store the password.

#### Step inputs

The following fields can passed to the step:

| Input Name | Purpose | Example | Required? |
|:----------:|:-------:|:-------:|:---------:|
| url | URL to submit Request against | _https://some-url.com_ | Y |
| test-string | String to look for in the HTTP Response. No special characters. If entry contains spaces, wrap in single quotes. | _'Homepage loaded'_, _stringwithnospaces_ | Y |
| method | Which HTTP method to use in the Request. POST is default. | _GET_ | Y |
| user | Provide a username to use for server authentication | _username_ | N |
| password | Provide a password to use for server authentication | _Key Storage entry_ | N |

Given the input above, a `Invoke-WebRequest` command will be issued like this:

```powershell
Invoke-WebRequest -Uri $url -Method $method -UseBasicParsing [-Credential $mycreds]
```

The result will be searched to see if it contains the test-string.

#### Exit Codes

This step returns the following exit codes:

| Exit Code |  Reason  |
|:----------:|:-------- |
|      0     | Success. The test string was found in the Response. |
|      1     | Fail. The test string was not found in the Response. |

### powershell / cert / monitor

For a given **valid** HTTPS URL and a threshold measured in days, if that URL's HTTPS certificate will expire in the specified number of days or less, it will trigger a failure. This in turn can trigger Notifications or more advanced error processing.

Note that the URL provided must be reachable from the target node that the Rundeck job will execute on. To test this, you can try running the following command directly on the target node in Powershell:

```powershell
[Net.HttpWebRequest]::Create("https://your-url-here")
```

This job step is lightweight in that it can check any certificate for any website that the target node has access to. It does not require interaction with the SSL keystore or the web server itself. It is the equivalent of loading the URL in your browser and examining the returned SSL certificate.

#### Exit Codes

This step returns the following exit codes:

| Exit Code |  Reason  |
|:----------:|:-------- |
|      0     | Success. Certificate is valid for the period of time specified. |
|      1     | Certificate expiration falls within notification threshhold. Time to renew. |

## Log Filtering (Optional)

Exit codes are assigned to "RUNDECK:DATA:EXIT_CODE" for use in Key-Value log filtering, if desired. [See here for more information.](https://docs.rundeck.com/docs/manual/log-filters/key-value-data.html)

## Building

1. To build the plugin, simply move up a directory and zip it but, exclude the .git files:

    ```powershell
    zip -r powershell-http-monitor-plugin.zip powershell-http-monitor-plugin -x *.git*
    ```

2. Then copy the zip file to the plugins directory: `$RDECK_BASE/libext`