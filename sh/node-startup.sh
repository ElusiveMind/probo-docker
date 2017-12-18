#!/bin/sh

# start rethinkdb before we start the loom service and run it as probo to
# avoid permissions problems.
cd /opt/probo/probo-loom
rethinkdb --daemon --runuser probo --rungroup probo

# start all of our probo processes as the probo user with the exception of
# the proxy in case the proxy is run on port 80.
su - probo -c '/opt/probo/probo/bin/probo container-manager -c /opt/probo/probo/cm.yaml > /dev/null &'
su - probo -c '/opt/probo/probo-bitbucket/bin/probo-bitbucket-handler -c /opt/probo/probo-bitbucket-handler/defaults.yaml > /dev/null &'
su - probo -c '/opt/probo/probo-asset-receiver/bin/probo-asset-receiver -c /opt/probo/probo-asset-receiver/defaults.config.yaml > /dev/null &'
su - probo -c '/opt/probo/probo-loom/bin/loom > /dev/null &'

# start the proxy as the root user
node /opt/probo/probo-proxy/index.js -c /opt/probo/probo-proxy/defaults.yaml > /dev/null &

# start the web server
rm -rf /run/httpd/* /tmp/httpd*
exec /usr/sbin/apachectl -DFOREGROUND