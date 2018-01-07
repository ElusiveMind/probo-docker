# Changelog For ProboCI Open Source Server

Please note that this file can also be seen on the WIKI page for this project at:  
https://github.com/ElusiveMind/probo-docker/wiki/Changelog-For-ProboCI-Open-Source-Server

#### Last Updated: January 7, 2018

v.10 - January 7, 2018
  - Optimization of container by removing unnecessary packages from being installed

v.09 - January 6, 2018
  - Removed default.yaml file so that default tokens would not be included in configuration.
  - Fixed remaining formatting bug with Loom tokens. Tokens now confirmed working with Loom.
  - Allow the proxy port to be configurable.

v.08 - January 1, 2018
  - Worked on token system with loom. No token configuration if no token set in configuration.
  - Worked on token system with asset receiver. No token configuration if no token set in configuration.
  - Some bash scripting cleanup (and debugging)

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