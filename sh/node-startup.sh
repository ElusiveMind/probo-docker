#!/bin/sh

# this is the script which processes all of our configuration files and
# assigns our configured environmental variables to their correct locations
# in those configuration files.

#########################################################
# CONTAINER MANAGER CONFIGURATION FILE PROCESSOR
#########################################################
exec 3<> /opt/probo/probo/container_manager.yaml
echo "hostname: localhost" >&3
echo "port: 3020" >&3
echo "" >&3
echo "instanceName: '$CM_INSTANCE_NAME'" >&3
echo "api:" >&3
echo "  url: 'http://localhost:3012'" >&3
echo "" >&3
echo "auth:" >&3
echo "  url: 'http://localhost:3012/auth_lookup'" >&3
echo "" >&3
echo "loom:" >&3
echo "  url: 'http://localhost:3060'" >&3
echo "" >&3
echo "assets:" >&3
echo "  url: '$ASSETS_URL'" >&3
echo "" >&3
echo "buildUrl: '$BUILD_URL'" >&3
echo "endpointUrl: '$ENDPOINT_URL'" >&3
exec 3>&-

#########################################################
# BITBUCKET CONFIGURATION FILE PROCESSOR
#########################################################
exec 4<> /opt/probo/probo-bitbucket/bitbucket-handler.yaml
echo "port: 3012" >&4
echo "hostname: 0.0.0.0" >&4
echo "" >&4
echo "bbWebhookUrl: '${BB_WEBHOOK_URL}'" >&4
echo "" >&4
echo "# Bitbucket client key and client secret. These are generated for you" >&4
echo "# when you create a new OAuth client in Bitbucket" >&4
echo "bbClientKey: ${BB_CLIENT_KEY}" >&4
echo "bbClientSecret: ${BB_CLIENT_SECRET}" >&4
echo "bbAccessToken: ${BB_ACCESS_TOKEN}" >&4
echo "bbRefreshToken: ${BB_REFRESH_TOKEN}" >&4
echo "" >&4
echo "# Settings for the API or Container Manager server port" >&4
echo "api:" >&4
echo "  url: 'http://localhost:3020'" >&4
exec 4>&-

# start rethinkdb before we start the loom service and run it as probo to
# avoid permissions problems.
cd /opt/probo/probo-loom
rethinkdb --daemon --runuser probo --rungroup probo

# start all of our probo processes as the probo user with the exception of
# the proxy in case the proxy is run on port 80.
su - probo -c '/opt/probo/probo/bin/probo container-manager -c /opt/probo/probo/contanier-manager.yaml > /dev/null &'
su - probo -c '/opt/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /opt/probo/probo-bitbucket/bitbucket-handler.yaml > /dev/null &'
su - probo -c '/opt/probo/probo-asset-receiver/bin/probo-asset-receiver -c /opt/probo/probo-asset-receiver/asset-receiver.yaml > /dev/null &'
su - probo -c '/opt/probo/probo-loom/bin/loom > /dev/null &'

# start the proxy as the root user
node /opt/probo/probo-proxy/index.js -c /opt/probo/probo-proxy/defaults.yaml > /dev/null &

# start the web server
rm -rf /run/httpd/* /tmp/httpd*
exec /usr/sbin/apachectl -DFOREGROUND