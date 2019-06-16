# Containerized Open Source Probo.CI Server
The construction of an open source ProboCI server within a Docker container.

The goal of this project is to have a fully functional Open Source Probo.CI container with a companion Drupal 8 based portal container for administering and looking at builds on the Open Source ProboCI Server.

### Complete Documentation Wiki
For complete information on this project including expanded documentation, please visit the Wiki page for this project on GitHub located at:  

https://github.com/ElusiveMind/probo-docker/wiki  

You can view additional documentation on the Probo Open Source initiative at:  

https://docs.probo.ci/open-source/  

### Configuration Environment Variables

**API_TOKEN**  
_Default: null_  
The API token used to access the container manager.  

**ASSET_RECEIVER_TOKEN**  
_Default: null_  
The token used for uploading assets to the receiver. Needs to be part of the request to push files to the asset receiver. If not specified, no token will be required which is a security issue.  

**ASSET_RECEIVER_URL**  
_Default: http://example.com:3070_  
The URL (with port) of your asset receiver process. This needs to be the URL with domain name and not an IP address as this will be looked up from within Docker containers. Probo uses this URL to fetch your assets from the asset receiver as part of the build process.  

**AWS_ACCESS_KEY_ID**  
_Default: null_  
When AwsS3Storage is configured as the asset receiver storage method, this is the access key id for the account used to store files.  

**AWS_SECRET_ACCESS_KEY**  
_Default: null_  
When AwsS3Storage is configured as the asset receiver storage method, this is the secret access key for the account used to store files.  

**AWS_BUCKET**  
_Default: null_  
When AwsS3Storage is configured as the asset receiver storage method, this is the name of the bucket where the files are stored.  

**BB_ACCESS_TOKEN**  
_Default: null_  
The Bitbucket access token for this application. This must be obtained through the process laid out in the Wiki documentation using the Bitbucket configuration generation feature of the Drupal 8 module.  

**BB_CLIENT_KEY**  
_Default: null_  
The Bitbucket client key configured in your Bitbucket application.  

**BB_CLIENT_SECRET**  
_Default: null_  
The Bitbucket client secret configured in your Bitbucket application.  

**BB_REFRESH_TOKEN**  
_Default: null_  
The Bitbucket refresh token for this application. This must be obtained through the process laid out in the Wiki documentation using the Bitbucket configuration generation feature of the Drupal 8 module.  

**BB_WEBHOOK_URL**  
_Default: /bitbucket-webhook_  
The endpoint of the Bitbucket webhook. This is used in the path configured in your webhook on Bitbucket.  

**BYPASS_TIMEOUT**  
_Default: 0_  
A flag as to whether or not probo docker containers should timeout after a period of time. Setting this to 1 prevents container timeouts.  

**CM_INSTANCE_NAME**  
_Default: OSProboCI_  
The name of your ProboCI instance. This will be used as part of the context build string viewable on your code repository status screen. This should be different for each probo server you run and should be custom set for your instance.  

**CREATE_LOOM_TASK_LOG**  
_Default: 0_  
Determines whether individual logs for Probo loom tasks are created. Good for debugging, bad for production.  

**ENCRYPTION_CIPHER**  
_Default: aes-256-cbc_  
Determines the cipher used to encrypt the assets. See https://www.openssl.org/docs/manmaster/apps/ciphers.html for options.  

**ENCRYPTION_PASSWORD**  
_Default: password_  
A salt for ENCRYPTION_CIPHER.  

**FILE_STORAGE_PLUGIN**  
_Default: LocalFiles_  
This is for the asset receiver. This defines the plugin that will be used for file storage, Currently there are two options, LocalFiles and AwsS3Storage. AwsS3Storage requires the keys and a bucket for storing files on Amazon S3. Be sure NOT to put your docker-compose.yml file or other configuration file in any kind of public source repository with this data in it. It's bad. Very, very bad. Trust me.  

**GITHUB_API_TOKEN**  
_Default: personal token here_  
The GitHub API token configured in your GitHub account.  

**GITHUB_WEBHOOK_PATH**
_Default: /github-webhook_  
The endpoint of the GitHub webhook. This is used in the path configured in your webhook on GitHub.  

**GITHUB_WEBHOOK_SECRET**  
_Default: null_  
This value should be modified to a secure string as well. This is a random token containing a string value that you select and will need to be used when you configure your webhook in GitHub.  

**GITLAB_CLIENT_KEY**  
_Default: null_  
The GitLab client key configured in your GitLab application.  

**GITLAB_CLIENT_SECRET**  
_Default: null_  
The GitLab client secret configured in your GitLab application.  

**GITLAB_WEBHOOK_URL**  
_Default: /gitlab-webhook_  
The endpoint of the GitLab webhook. This is used in the path configured in your webhook on GitLab.  

**LOOM_SERVER_TOKEN**  
_Default: null_  
A token used for accessing the loom server. The loom server is currently used to provide event information to a web service. The web service calls the loom server using this token for all requests. If not configured, no token will be required to make requests. It is a best practice to configure a unique server token.

**LOOM_EVENT_API_URL**  
_Default: null_  

**PROBO_BUILD_URL**  
_Default: http://{{buildId}}.example.com:3050/_  
URL template string for viewing each build. {{buildId}} expands to the id of the build. Must include the port number if not using a standard port number (port 80).  

**PROXY_CACHE_ENABLED**  
_Default: true_  
Enable a caching mechanism for the proxy server. This will cache items locally for the proxy and result in better performance.  

**PROXY_CACHE_MAX**  
_Default: 500_  
Max number of proxy lookup responses to cache.  

**PROXY_CACHE_MAX_AGE**  
_Default: 5m_  
Max age of proxy lookup responses in cache, in any unit (units default to ms).  

**PROXY_HOSTNAME_IP**  
_Default: localhost_  
The host name where docker lives. Note that this should be the intranet IP address of where your root docker installation lives. Without this, proxying will fail.  

**PROBO_LOGGING**  
_Default: 0_  
Boolean value (either 1 or 0). Setting a value of 1 will cause each enabled process to log output. These logs are typically used for debugging builds and are not recommended for production server configurations.  

**PROXY_PORT**  
_Default: 3050_  
Port that the proxy server is running on.  

**PROXY_SERVER_TIMEOUT**  
_Default: 10m_  
Server timeout, in any unit.  

**REAPER_DRY_RUN**  
_Default: true_  

**REAPER_OUTPUT_FORMAT**  
_Default: text_  
The output format used for --status command. Options are:
- json: JSON output - one line per JSON object
- text: (default) - human readable hearchical output

**REAPER_BRANCH_BUILD_LIMIT**  
_Default: 1_  
Limit the number of builds per branch of code.  

**RECIPHERED_OUTPUT_DIR**  
_Default: null_  

**REDIRECT_URL**  
_Default: null_  
The URL to send people too when a build cannot be found or is in the process of being built. Also used for reaped builds. Sends query string at the end.  

**SERVICE_ENDPOINT_URL**  
_Default: http://www.example.com/probo-api/service-endpoint.json_  
An optional configuration for a URL to receive notification of service events. A JSON object will be sent to this URL with each build object containing information about the current build in process including tasks. This is designed specifically for use with the Drupal 8 module for the Probo Open Source Server available at: https://github.com/ElusiveMind/probo-drupal  

**UPLOADS_PAUSED**  
_Default: null_  

**USE_BITBUCKET**  
_Default: 0_  
A boolean value to communicate whether or not the Bitbucket handler should be configured and started as part of the server.  

**USE_GITLAB**  
_Default: 0_  
A boolean value to communicate whether or not the GitLab handler should be configured and started as part of the server.  

**USE_GITHUB**  
_Default: 0_  
A boolean value to communicate whether or not the GitHub handler should be configured and started as part of the server.  
