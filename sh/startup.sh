#!/bin/sh

# this is the script which processes all of our configuration files and
# assigns our configured environmental variables to their correct locations
# in those configuration files.

# Make it so the docker socket can be read.
chmod 777 /var/run/docker.sock

if [[ -z "${STORAGE_DATA_DIR}" ]]; then
  echo "STORAGE_DATA_DIR cannot be empty. A value must be provided."
  exit 1
fi

if [[ -z "${PROBO_DATA_DIRECTORY}" ]]; then
  echo "PROBO_DATA_DIRECTORY cannot be empty. A value must be provided."
  exit 1
fi

if [[ -z "${ASSET_RECEIVER_DATABASE_DIRECTORY}" ]]; then
  echo "ASSET_RECEIVER_DATABASE_DIRECTORY cannot be empty. A value must be provided."
  exit 1
fi

if [[ -z "${FILE_DATA_DIRECTORY}" ]]; then
  echo "FILE_DATA_DIRECTORY cannot be empty. A value must be provided."
  exit 1
fi

if [[ -n "${LOOM_SERVER_TOKEN}" ]]; then
  export PROBO_LOOM_SERVER_TOKEN="'${LOOM_SERVER_TOKEN}'"
  export LOOM_SERVER_TOKEN="tokens:"$'\n'  - ${LOOM_SERVER_TOKEN}
fi

if [[ -n "${ASSET_SERVER_TOKEN}" ]]; then
  export PROBO_ASSET_SERVER_TOKEN="'${ASSET_SERVER_TOKEN}'"
  export ASSET_SERVER_TOKEN="tokens:"$'\n' ${ASSET_SERVER_TOKEN}
fi

# Create our data directories and set permissions
mkdir -p $STORAGE_DATA_DIR
chmod 777 $STORAGE_DATA_DIR
chown probo:probo $STORAGE_DATA_DIR

mkdir -p $PROBO_DATA_DIRECTORY
chmod 777 $PROBO_DATA_DIRECTORY
chown probo:probo $PROBO_DATA_DIRECTORY

mkdir -p $ASSET_RECEIVER_DATABASE_DIRECTORY
chmod 777 $ASSET_RECEIVER_DATABASE_DIRECTORY
chown probo:probo $ASSET_RECEIVER_DATABASE_DIRECTORY

mkdir -p $FILE_DATA_DIRECTORY
chmod 777 $FILE_DATA_DIRECTORY
chown probo:probo $FILE_DATA_DIRECTORY

mkdir -p $RETHINK_DATA_DIR
chmod 777 $RETHINK_DATA_DIR
chown probo:probo $RETHINK_DATA_DIR

chown -R probo:probo $BASE_PROBO_DATA_DIR
chmod -R 777 $BASE_PROBO_DATA_DIR

# Substitute environment variables from docker-compose.yml into our yml files.
# TODO: Make sure all required variables have a valid value.
envsubst < /opt/probo/yml/assets-default.yml > /opt/probo/probo-asset-receiver/asset-receiver.yml
envsubst < /opt/probo/yml/probo-defaults.yml > /opt/probo/probo/defaults.yaml
envsubst < /opt/probo/yml/container-manager.yml > /opt/probo/probo/container-manager.yml
envsubst < /opt/probo/yml/loom-defaults.yml > /opt/probo/probo-loom/loom.yml
envsubst < /opt/probo/yml/proxy-defaults.yml > /opt/probo/probo-proxy/proxy.yml
envsubst < /opt/probo/yml/reaper-defaults.yml > /opt/probo/probo-reaper/reaper.yml
envsubst < /opt/probo/yml/notifier-defaults.yml > /opt/probo/probo-notifier/defaults.yaml

# start rethinkdb before we start the loom service and run it as probo to
# avoid permissions problems.
cd $RETHINK_DATA_DIR
rethinkdb --daemon --no-http-admin --runuser probo --rungroup probo

# lets do logging during development
mkdir -p /opt/probo/logs
chown probo:probo /opt/probo/logs

# start all of our probo processes as the probo user with the exception of
# the proxy in case the proxy is run on port 80.
su - probo -c '/opt/probo/probo/bin/probo container-manager -c /opt/probo/probo/container-manager.yml > /opt/probo/logs/container-manager.log &'

if [[ ! -z "${USE_GITHUB}" ]] && [ $USE_GITHUB = "1" ]; then
  envsubst < /opt/probo/yml/github-defaults.yml > /opt/probo/probo/github-handler.yml
  su - probo -c '/opt/probo/probo/bin/probo github-handler -c /opt/probo/probo/github-handler.yml > /opt/probo/logs/github-handler.log &'
fi

if [[ ! -z "${USE_BITBUCKET}" ]] && [ $USE_BITBUCKET = "1" ]; then
  envsubst < /opt/probo/yml/bitbucket-defaults.yml > /opt/probo/probo-bitbucket/bitbucket-handler.yml
  su - probo -c '/opt/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /opt/probo/probo-bitbucket/bitbucket-handler.yml > /opt/probo/logs/bitbucket-handler.log &'
fi

if [[ ! -z "${USE_GITLAB}" ]] && [ $USE_GITLAB = "1" ]; then
  envsubst < /opt/probo/yml/gitlab-defaults.yml > /opt/probo/probo-gitlab/gitlab-handler.yml
  su - probo -c '/opt/probo/probo-gitlab/bin/probo-gitlab-handler -c /opt/probo/probo-gitlab/gitlab-handler.yml > /opt/probo/logs/gitlab-handler.log &'
fi

su - probo -c '/opt/probo/probo-asset-receiver/bin/probo-asset-receiver -c /opt/probo/probo-asset-receiver/asset-receiver.yml > /opt/probo/logs/asset-receiver.log &'
su - probo -c 'mkdir /opt/probo/probo-loom/data'
su - probo -c 'chmod 777 /opt/probo/probo-loom/data'
su - probo -c '/opt/probo/probo-loom/bin/loom -c /opt/probo/probo-loom/loom.yml > /opt/probo/logs/probo-loom.log &'

# start the proxy as the root user
node /opt/probo/probo-proxy/index.js -c /opt/probo/probo-proxy/proxy.yml &

su - probo -c '/opt/probo/probo-reaper/bin/probo-reaper server &'
su - probo -c '/opt/probo/probo-notifier/bin/probo-notifier server'
