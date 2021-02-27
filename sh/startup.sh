#!/bin/bash

# this is the script which processes all of our configuration files and
# assigns our configured environmental variables to their correct locations
# in those configuration files.

# Make it so the docker socket can be read.
chmod 777 /var/run/docker.sock

if [[ -n "${LOOM_SERVER_TOKEN}" ]]; then
  export PROBO_LOOM_SERVER_TOKEN="${LOOM_SERVER_TOKEN}"
  export LOOM_SERVER_TOKEN="tokens:"$'\n'"  - ${LOOM_SERVER_TOKEN}"
fi

if [[ -n "${COORDINATOR_API_URL}" ]]; then
  export COORDINATOR_API_URL="${COORDINATOR_API_URL}"
else
  export COORDINATOR_API_URL="http://localhost:3020"
fi

if [[ ! -z "${CREATE_LOOM_TASK_LOGS}" ]] && [ $CREATE_LOOM_TASK_LOGS = "1" ]; then
  export LOOM_STORAGE_DATA_DIR="storageDataDir: \"/home/probo/data/database/loom\""
else
  export LOOM_STORAGE_DATA_DIR=""
fi

if [[ -n "${ASSET_RECEIVER_TOKEN}" ]]; then
  export PROBO_ASSET_RECEIVER_TOKEN="${ASSET_RECEIVER_TOKEN}"
  export ASSET_RECEIVER_TOKEN="tokens: '${ASSET_RECEIVER_TOKEN}'"
fi

# Create our data directories and set permissions
mkdir -p -m 777 /home/probo/data/database/loom
chown probo:probo /home/probo/data/database/loom

mkdir -p -m 777 /home/probo/data/container-manager-data
chown probo:probo /home/probo/data/container-manager-data

mkdir -p -m 777 /home/probo/data/databases/asset-receiver
chown probo:probo /home/probo/data/databases/asset-receiver

mkdir -p -m 777 /home/probo/data/files/asset-receiver
chown probo:probo /home/probo/data/files/asset-receiver

mkdir -p -m 777 /home/probo/data/database/rethinkdb
chown probo:probo /home/probo/data/database/rethinkdb

# Substitute environment variables from docker-compose.yml into our yml files.
# TODO: Make sure all required variables have a valid value.
envsubst < /yml/assets-default.yml > /etc/probo/asset-receiver.yaml
envsubst < /yml/probo-defaults.yml > /home/probo/probo/defaults.yaml
envsubst < /yml/container-manager.yml > /etc/probo/container-manager.yml
envsubst < /yml/github-defaults.yml > /etc/probo/github-handler.yml
envsubst < /yml/bitbucket-defaults.yml > /etc/probo/bitbucket-handler.yml
envsubst < /yml/gitlab-defaults.yml > /etc/probo/gitlab-handler.yml
envsubst < /yml/loom-defaults.yml > /etc/probo/loom.yml
envsubst < /yml/proxy-defaults.yml > /etc/probo/proxy.yml
envsubst < /yml/reaper-defaults.yml > /etc/probo/reaper.yml
envsubst < /yml/notifier-defaults.yml > /etc/probo/notifier.yaml

# start rethinkdb before we start the loom service and run it as probo to
# avoid permissions problems.
# cd /home/probo/data/database/rethinkdb
# rethinkdb --daemon --bind all --runuser probo --rungroup probo

# logging directory for process logging if configured to do so. create the directory
# anyway. it will just be empty if not configured for use.
mkdir -p -m 777 /home/probo/data/logs
chown probo:probo /home/probo/data/logs

# start all of our probo processes as the probo user with the exception of
# the proxy in case the proxy is run on port 80.
if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
  su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo/bin/probo container-manager -c /etc/probo/container-manager.yml > /home/probo/data/logs/container-manager.log &"
else
  su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo/bin/probo container-manager -c /etc/probo/container-manager.yml &"
fi

if [[ ! -z "${USE_GITHUB}" ]] && [ $USE_GITHUB = "1" ]; then
  envsubst < /home/probo/yml/github-defaults.yml > /home/probo/probo/github-handler.yml
  if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
    su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo/bin/probo github-handler -c /etc/probo/github-handler.yml > /home/probo/data/logs/github-handler.log &"
  else
    su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo/bin/probo github-handler -c /etc/probo/github-handler.yml &"
  fi
fi

if [[ ! -z "${USE_BITBUCKET}" ]] && [ $USE_BITBUCKET = "1" ]; then
  envsubst < /home/probo/yml/bitbucket-defaults.yml > /home/probo/probo-bitbucket/bitbucket-handler.yml
  if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
    su - probo -c "NODE_VERSION=4.9.1 /home/probo/.nvm/nvm-exec /home/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /etc/probo/bitbucket-handler.yml > /home/probo/data/logs/bitbucket-handler.log &"
  else
    su - probo -c "NODE_VERSION=4.9.1 /home/probo/.nvm/nvm-exec /home/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /etc/probo/bitbucket-handler.yml &"
  fi
fi

if [[ ! -z "${USE_GITLAB}" ]] && [ $USE_GITLAB = "1" ]; then
  envsubst < /home/probo/yml/gitlab-defaults.yml > /home/probo/probo-gitlab/gitlab-handler.yml
  if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
    su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo-gitlab/bin/probo-gitlab-handler -c /opt/probo/gitlab-handler.yml > /home/probo/data/logs/gitlab-handler.log &"
  else
    su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo-gitlab/bin/probo-gitlab-handler -c /opt/probo/gitlab-handler.yml &"
  fi
fi

if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
  su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo-asset-receiver/bin/probo-asset-receiver > /home/probo/data/logs/asset-receiver.log &"
  su - probo -c "NODE_VERSION=4.9.1 /home/probo/.nvm/nvm-exec /home/probo/probo-loom/bin/loom -c /etc/probo/loom.yml > /home/probo/data/logs/loom.log &"
  # start the proxy as the root user just in case we're on port 80.
  NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo-proxy/bin/probo-proxy -c /home/probo/probo-proxy/proxy.yml > /home/probo/data/logs/probo-proxy.log &
else
  su - probo -c "NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo-asset-receiver/bin/probo-asset-receiver &"
  su - probo -c "NODE_VERSION=4.9.1 /home/probo/.nvm/nvm-exec /home/probo/probo-loom/bin/loom -c /etc/probo/loom.yml &"
  # start the proxy as the root user just in case we're on port 80.
  NODE_VERSION=12.20.2 /home/probo/.nvm/nvm-exec /home/probo/probo-proxy/bin/probo-proxy -c /etc/probo/proxy.yml &
fi

#su - probo -c "/home/probo/probo-reaper/bin/probo-reaper server > /home/probo/data/logs/reaper.log &"
#su - probo -c "/home/probo/probo-notifier/bin/probo-notifier server > /home/probo/data/logs/notifier.log &"

tail -f /dev/null
