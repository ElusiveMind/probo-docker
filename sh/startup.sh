#!/bin/sh

# this is the script which processes all of our configuration files and
# assigns our configured environmental variables to their correct locations
# in those configuration files.

# Make it so the docker socket can be read.
chmod 777 /var/run/docker.sock

if [[ -n "${LOOM_SERVER_TOKEN}" ]]; then
  export PROBO_LOOM_SERVER_TOKEN="${LOOM_SERVER_TOKEN}"
  export LOOM_SERVER_TOKEN="tokens:"$'\n'"  - ${LOOM_SERVER_TOKEN}"
fi

if [[ -n "${ASSET_RECEIVER_TOKEN}" ]]; then
  export PROBO_ASSET_RECEIVER_TOKEN="${ASSET_RECEIVER_TOKEN}"
  export ASSET_RECEIVER_TOKEN="tokens: '${ASSET_RECEIVER_TOKEN}'"
fi

# Create our data directories and set permissions
mkdir -p -m 777 /opt/probo/data/database/loom
chown probo:probo /opt/probo/data/database/loom

mkdir -p -m 777 /opt/probo/data/container-manager-data
chown probo:probo /opt/probo/data/container-manager-data

mkdir -p -m 777 /opt/probo/data/databases/asset-receiver
chown probo:probo /opt/probo/data/databases/asset-receiver

mkdir -p -m 777 /opt/probo/data/files/asset-receiver
chown probo:probo /opt/probo/data/files/asset-receiver

mkdir -p -m 777 /opt/probo/data/database/rethinkdb
chown probo:probo /opt/probo/data/database/rethinkdb

# Substitute environment variables from docker-compose.yml into our yml files.
# TODO: Make sure all required variables have a valid value.
envsubst < /opt/probo/yml/assets-default.yml > /opt/probo/probo-asset-receiver/asset-receiver.yml
envsubst < /opt/probo/yml/probo-defaults.yml > /opt/probo/probo/defaults.yaml
envsubst < /opt/probo/yml/container-manager.yml > /opt/probo/probo/container-manager.yml
envsubst < /opt/probo/yml/loom-defaults.yml > /opt/probo/probo-loom/loom.yml
envsubst < /opt/probo/yml/proxy-defaults.yml > /opt/probo/probo-proxy/proxy.yml
envsubst < /opt/probo/yml/reaper-defaults.yml > /opt/probo/probo-reaper/reaper.yml
#envsubst < /opt/probo/yml/notifier-defaults.yml > /opt/probo/probo-notifier/defaults.yaml
cp /opt/probo/yml/loom-default-defaults.yml /opt/probo/probo-loom/defaults.yaml

# start rethinkdb before we start the loom service and run it as probo to
# avoid permissions problems.
cd /opt/probo/data/database/rethinkdb
rethinkdb --daemon --no-http-admin --runuser probo --rungroup probo

# logging directory for process logging if configured to do so. create the directory
# anyway. it will just be empty if not configured for use.
mkdir -p -m 777 /opt/probo/data/logs
chown probo:probo /opt/probo/data/logs

# start all of our probo processes as the probo user with the exception of
# the proxy in case the proxy is run on port 80.
if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
  su - probo -c "/opt/probo/probo/bin/probo container-manager -c /opt/probo/probo/container-manager.yml > /opt/probo/data/logs/container-manager.log &"
else
  su - probo -c "/opt/probo/probo/bin/probo container-manager -c /opt/probo/probo/container-manager.yml &"
fi

if [[ ! -z "${USE_GITHUB}" ]] && [ $USE_GITHUB = "1" ]; then
  envsubst < /opt/probo/yml/github-defaults.yml > /opt/probo/probo/github-handler.yml
  if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
    su - probo -c "/opt/probo/probo/bin/probo github-handler -c /opt/probo/probo/github-handler.yml > /opt/probo/data/logs/github-handler.log &"
  else
    su - probo -c "/opt/probo/probo/bin/probo github-handler -c /opt/probo/probo/github-handler.yml &"
  fi
fi

if [[ ! -z "${USE_BITBUCKET}" ]] && [ $USE_BITBUCKET = "1" ]; then
  envsubst < /opt/probo/yml/bitbucket-defaults.yml > /opt/probo/probo-bitbucket/bitbucket-handler.yml
  if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
    su - probo -c "/opt/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /opt/probo/probo-bitbucket/bitbucket-handler.yml > /opt/probo/data/logs/bitbucket-handler.log &"
  else
    su - probo -c "/opt/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /opt/probo/probo-bitbucket/bitbucket-handler.yml &"
  fi
fi

if [[ ! -z "${USE_GITLAB}" ]] && [ $USE_GITLAB = "1" ]; then
  envsubst < /opt/probo/yml/gitlab-defaults.yml > /opt/probo/probo-gitlab/gitlab-handler.yml
  if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
    su - probo -c "/opt/probo/probo-gitlab/bin/probo-gitlab-handler -c /opt/probo/probo-gitlab/gitlab-handler.yml > /opt/probo/data/logs/gitlab-handler.log &"
  else
    su - probo -c "/opt/probo/probo-gitlab/bin/probo-gitlab-handler -c /opt/probo/probo-gitlab/gitlab-handler.yml &"
  fi
fi

if [[ ! -z "${PROBO_LOGGING}" ]] && [ $PROBO_LOGGING = "1" ]; then
  su - probo -c "/opt/probo/probo-asset-receiver/bin/probo-asset-receiver -c /opt/probo/probo-asset-receiver/asset-receiver.yml > /opt/probo/data/logs/asset-receiver.log &"
  su - probo -c "/opt/probo/probo-loom/bin/loom -c /opt/probo/probo-loom/loom.yml > /opt/probo/data/logs/probo-loom.log &"
  # start the proxy as the root user just in case we're on port 80.
  node /opt/probo/probo-proxy/index.js -c /opt/probo/probo-proxy/proxy.yml > /opt/probo/data/logs/probo-proxy.log &
else
  su - probo -c "/opt/probo/probo-asset-receiver/bin/probo-asset-receiver -c /opt/probo/probo-asset-receiver/asset-receiver.yml &"
  su - probo -c "/opt/probo/probo-loom/bin/loom -c /opt/probo/probo-loom/loom.yml &"
  # start the proxy as the root user just in case we're on port 80.
  node /opt/probo/probo-proxy/index.js -c /opt/probo/probo-proxy/proxy.yml &
fi

su - probo -c '/opt/probo/probo-reaper/bin/probo-reaper server'
