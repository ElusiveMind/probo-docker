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

**PROBO_LOGGING**  
_Default: 0_  
Boolean value (either 1 or 0). Setting a value of 1 will cause each enabled process to log output to the location of the PROBO_LOGGING_DIR directory setting. These logs are typically used for debugging builds and are not recommended for production server configurations.  