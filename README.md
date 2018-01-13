# Containerized Open Source Probo.CI Server
The construction of an open source Probo.CI server within a Docker container.

This README will serve as a placeholder. Coming soon will be the instructions for configuring your own Probo.CI open source server that you can run easily on your own hardware using the Docker container system. Check back here regularly for updates.

The goal of this project is to have a fully functional Open Source Probo.CI container with a companion Drupal 8 based portal container for administering and looking at builds in the system.

#### Table of Contents (Wiki Links)
  1. The Importance of Persistent Data in Docker Containers  
     https://github.com/ElusiveMind/probo-docker/wiki/The-Importance-of-Persistent-Data-in-Docker-Containers

  2. Changelog For ProboCI Open Source Server  
     https://github.com/ElusiveMind/probo-docker/wiki/Changelog-For-ProboCI-Open-Source-Server  

#### Last Updated: January 13, 2018

#### Configuration Environment Variables

A complete list of configurations and default values can be viewed on the Probo Docker wiki page:  

https://github.com/ElusiveMind/probo-docker/wiki/Configuration-Environment-Variables  

**ASSET_RECEIVER_URL**
_Default: http://example.com:3070_  
The URL (with port) of your asset receiver process. This needs to be the URL with domain name and not an IP address as this will be looked up from within Docker containers. Probo uses this URL to fetch your assets from the asset receiver as part of the build process.

**CM_INSTANCE_NAME**  
_Default: OSProboCI_  
The name of your ProboCI instance. This will be used as part of the context build string viewable on your code repository status screen. This should be different for each probo server you run and should be custom set for your instance.

**PROBO_BUILD_URL**  
_Default: http://{{buildId}}.example.com:3050/_  
URL template string for viewing each build. {{buildId}} expands to the id of the build.  

**PROBO_LOGGING**  
_Default: 0_  
Boolean value (either 1 or 0). Setting a value of 1 will cause each enabled process to log output. These logs are typically used for debugging builds and are not recommended for production server configurations.  

**SERVICE_ENDPOINT_URL**  
_Default: http://www.example.com/probo-api/service-endpoint.json_  
An optional configuration for a URL to receive notification of service events. A JSON object will be sent to this URL with each build object containing information about the current build in process including tasks. This is designed specifically for use with the Drupal 8 module for the Probo Open Source Server available at: https://github.com/ElusiveMind/probo-drupal