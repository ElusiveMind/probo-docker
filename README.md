# Containerized Open Source Probo.CI Server
The construction of an open source Probo.CI server within a Docker container.

This README will serve as a placeholder. Coming soon will be the instructions for configuring your own Probo.CI open source server that you can run easily on your own hardware using the Docker container system. Check back here regularly for updates.

The goal of this project is to have a fully functional Open Source Probo.CI container with a companion Drupal 8 based portal container for administering and looking at builds in the system.

#### Table of Contents (Wiki Links)
  1. The Importance of Persistent Data in Docker Containers  
     https://github.com/ElusiveMind/probo-docker/wiki/The-Importance-of-Persistent-Data-in-Docker-Containers

  2. Changelog For ProboCI Open Source Server  
     https://github.com/ElusiveMind/probo-docker/wiki/Changelog-For-ProboCI-Open-Source-Server  

#### Last Updated: January 9, 2018

A complete set of changes can be found in the CHANGELOG.md file located in the same directory as this README.md file. Please see that for a complete list of changes since the inception of this project if needed.

v.12 - January 9, 2018
  - Convert logging path to environment variable which can be set in docker call or docker-compose.
  - Clean up of environment variable names to be in line with daemon names.
  - Allow for configuratiion of logging mode (on/off)

v.11 - January 8, 2018
  - Modified forked probo to provide only data we need to Drupal. Data pushed to Rest API (Drupal) if configured.

v.10 - January 7, 2018
  - Optimization of container by removing unnecessary packages from being installed
  - Change to the forked version of probo which provides status updates to Drupal's dashboard module.

v.09 - January 6, 2018
  - Removed default.yaml file so that default tokens would not be included in configuration.
  - Fixed remaining formatting bug with Loom tokens. Tokens now confirmed working with Loom.
  - Allow the proxy port to be configurable.
