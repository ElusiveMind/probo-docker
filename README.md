# Containerized Open Source Probo.CI Server
The construction of an open source Probo.CI server within a docker container.

This README will serve as a placeholder. Coming soon will be the instructions for configuring your own Probo.CI open source server that you can run easily on your own hardware using the Docker container system. Check back here regularly for updates.

The goal of this project is to have a fully functional Open Source Probo.CI server complete with Drupal 8 based portal for administering and looking at builds in the system.

#### Last Updated: December 20, 2017

v.03 - December 20, 2017
  - Modified probo-proxy so it will properly point to the correct place for the container on the correct host
  - Allowed for configuration of the correct host as per above in the probo-proxy yml file.

v.02 - December 19, 2017
  - Fixed several configuration naming and path issues.
  - Search and replace environment names in configuration files with their values
  - Fly in patched version of probo-request-logger until new version incorporates fixes friendly to open source.
  - Fixes to exposed ports to matched our exported and public services

v.01 - December 18, 2017
  - Successfully built Container Manager.
  - Successfully built Bitbucket Handler (without complete configuration).
  - Successfully built Asset Manager.
  - Successfully built Proxy (run as root).
  - Successfully built Loom (with RethinkDB as a back end).
  - Successfully built Reaper although currently unimplemented.
  - Successfully built and configured RethinkDB.
  - Successfully configured custom Apache instance with PHP 7.0 for future Drupal 8 portal.
  - Included a docker-compose.yml file for building locally and testing before pushing to Docker Hub.