# Containerized Open Source Probo.CI Server
The construction of an open source Probo.CI server within a Docker container.

This README will serve as a placeholder. Coming soon will be the instructions for configuring your own Probo.CI open source server that you can run easily on your own hardware using the Docker container system. Check back here regularly for updates.

The goal of this project is to have a fully functional Open Source Probo.CI container with a companion Drupal 8 based portal container for administering and looking at builds in the system.

#### Table of Contents (Wiki Links)
  1. The Importance of Persistent Data in Docker Containers  
     https://github.com/ElusiveMind/probo-docker/wiki/The-Importance-of-Persistent-Data-in-Docker-Containers

  2. Changelog For ProboCI Open Source Server  
     https://github.com/ElusiveMind/probo-docker/wiki/Changelog-For-ProboCI-Open-Source-Server  

#### Last Updated: January 6, 2018

A complete set of changes can be found in the CHANGELOG.md file located in the same directory as this README.md file. Please see that for a complete list of changes since the inception of this project if needed.

v.09 - January 6, 2018
  - Removed default.yaml file so that default tokens would not be included in configuration.
  - Fixed remaining formatting bug with Loom tokens. Tokens now confirmed working with Loom.

v.08 - January 1, 2018
  - Worked on token system with loom. No token configuration if no token set in configuration.
  - Worked on token system with asset receiver. No token configuration if no token set in configuration.
  - Some bash scripting cleanup (and debugging)

v.07 - December 28, 2017
  - Implemented a public Loom service with a token. Token strongly suggested since this can noe be accessed publically.
  - Set permissions on log file paths to proper owners and read/write permissions.
