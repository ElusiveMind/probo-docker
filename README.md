# Containerized Open Source Probo.CI Server
The construction of an open source Probo.CI server within a Docker container.

This README will serve as a placeholder. Coming soon will be the instructions for configuring your own Probo.CI open source server that you can run easily on your own hardware using the Docker container system. Check back here regularly for updates.

The goal of this project is to have a fully functional Open Source Probo.CI container with a companion Drupal 8 based portal container for administering and looking at builds in the system.

#### Table of Contents (Wiki Links)
  1. The Importance of Persistent Data in Docker Containers  
     https://github.com/ElusiveMind/probo-docker/wiki/The-Importance-of-Persistent-Data-in-Docker-Containers

  2. Changelog For ProboCI Open Source Server  
     https://github.com/ElusiveMind/probo-docker/wiki/Changelog-For-ProboCI-Open-Source-Server  

#### Last Updated: December 28, 2017

A complete set of changes can be found in the CHANGELOG.md file located in the same directory as this README.md file. Please see that for a complete list of changes since the inception of this project if needed.

v.07 - December 28, 2017
  - Implemented a public Loom service with a token. Token strongly suggested since this can noe be accessed publically.
  - Set permissions on log file paths to proper owners and read/write permissions.

v.06 - December 27, 2017  
  - Add GitLab handler code. (Currently patched due to case-sensitivity bug).
  - Moved Container Manager and Bitbucket handler yaml code into template replacement like the the other yaml templates.
  - Made the inclusion of git handlers configurable based on environment variables. They are  only included if they are specified in the docker-compose.yml file.

v.05 - December 25, 2017
  - Added checks for various database, file and data file storage directory environmental vars for the purposes of data persistence into volumes.
  - Added instructions into the README regarding the importance of persistence of database files  and other files especially asset files not hosted on S3.
  - Added a CHANGELOG file that keeps lists of changes instead of keeping all of these in the README. README now limited to the last three updates. CHANGELOG contains everything.

v.04 - December 21, 2017
  - Remove web components from Probo server container. Separate web portal to its own container.
  - Change all messagging to Kafka in preparation for Probo Notifier
  - Disabled web admin port (8080) for RethinkDB so we can repurpose.
  - Added Probo Notifier service and configured for Kafka (untested)
  - Enabled Probo Reaper service and configured for Kafka (untested)