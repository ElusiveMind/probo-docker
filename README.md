# Containerized Open Source Probo.CI Server
The construction of an open source Probo.CI server within a Docker container.

This README will serve as a placeholder. Coming soon will be the instructions for configuring your own Probo.CI open source server that you can run easily on your own hardware using the Docker container system. Check back here regularly for updates.

The goal of this project is to have a fully functional Open Source Probo.CI container with a companion Drupal 8 based portal container for administering and looking at builds in the system.

#### Table of Contents (Wiki Links)
  1. [[The Importance of Persistent Data in Docker Containers|The-Importance-of-Persistent-Data-in-Docker-Containers]]
     https://github.com/ElusiveMind/probo-docker/wiki/The-Importance-of-Persistent-Data-in-Docker-Containers

  2. [[Changelog|Changelog-For-ProboCI-Open-Source-Server]]  
     https://github.com/ElusiveMind/probo-docker/wiki/Changelog-For-ProboCI-Open-Source-Server  

#### Last Updated: December 25, 2017

A complete set of changes can be found in the CHANGELOG.md file located in the same directory as this README.md file. Please see that for a complete list of changes since the inception of this project if needed.

v.05 - December 25, 2017
  - Added checks for various database, file and data file storage directory environemtnal vars
  - Added instructions into the README regarding the importance of persistence of database files
    and other files especially asset files not hosted on S3.
  - Added a CHANGELOG file that keeps lists of changes instead of keeping all of these in the 
    README. README now limited to the last three updates. CHANGELOG contains everything.

v.04 - December 21, 2017
  - Remove web components from Probo server container. Separate web portal to its own container.
  - Change all messagging to Kafka in preparation for Probo Notifier
  - Disabled web admin port (8080) for RethinkDB so we can repurpose.
  - Added Probo Notifier service and configured for Kafka (untested)
  - Enabled Probo Reaper service and configured for Kafka (untested)
  
v.03 - December 20, 2017
  - Modified probo-proxy so it will properly point to the correct place for the container on the correct host
  - Allowed for configuration of the correct host as per above in the probo-proxy yml file.