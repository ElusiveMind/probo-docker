FROM centos:7

# Set our our meta data for this container.
LABEL name="Containerized Open Source Probo.CI Server"
LABEL description="This is our Docker container for the open source version of ProboCI."
LABEL author="Michael R. Bagnall <mbagnall@zivtech.com>"
LABEL vendor="ProboCI, LLC."
LABEL version="0.28"

# Set up our standard binary paths.
ENV PATH /usr/local/src/vendor/bin/:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm 

# Fix command line compile issue with bundler.
ENV LC_ALL en_US.utf8

# Our default environment variables
ENV PROBO_LOGGING="0" \
    CM_INSTANCE_NAME="OSProboCI" \
    ASSET_RECEIVER_URL="http://example.com:3070" \
    ASSET_MANAGER_DIRECT_CALL_REDIRECT="http://www.example.com" \
    PROBO_BUILD_URL="http://{{buildId}}.example.com:3050/" \
    SERVICE_ENDPOINT_URL="http://www.example.com/probo-api/service-endpoint.json" \
    BYPASS_TIMEOUT="0" \
    USE_GITHUB="1" \
    GITHUB_WEBHOOK_PATH="/github-webhook" \
    GITHUB_WEBHOOK_SECRET="CHANGE-ME" \
    GITHUB_API_TOKEN="personal token here" \
    USE_BITBUCKET="0" \
    BB_WEBHOOK_URL="/bitbucket-webhook" \
    BB_CLIENT_KEY="" \
    BB_CLIENT_SECRET="" \
    BB_ACCESS_TOKEN="" \
    BB_REFRESH_TOKEN="" \
    USE_GITLAB="0" \
    GITLAB_WEBHOOK_URL="/gitlab-webhook" \
    GITLAB_CLIENT_KEY="" \
    GITLAB_CLIENT_SECRET="" \
    FILE_STORAGE_PLUGIN="LocalFiles" \
    ENCRYPTION_CIPHER="aes-256-cbc" \
    ENCRYPTION_PASSWORD="password" \
    RECIPHERED_OUTPUT_DIR="" \
    ASSET_RECEIVER_TOKEN="" \
    UPLOADS_PAUSED="false" \
    AWS_ENDPOINT="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_BUCKET="" \
    LOOM_SERVER_TOKEN="" \
    LOOM_EVENT_API_URL="" \
    CREATE_LOOM_TASK_LOG="0" \
    REAPER_DRY_RUN="true" \
    REAPER_OUTPUT_FORMAT="text" \
    REAPER_BRANCH_BUILD_LIMIT="1" \
    PROXY_PORT="3050" \
    PROXY_HOSTNAME_IP="localhost" \
    PROXY_CACHE_ENABLED="true" \
    PROXY_CACHE_MAX="500" \
    PROXY_CACHE_MAX_AGE="5m" \
    PROXY_SERVER_TIMEOUT="10m" \
    REDIRECT_URL=""

# Create the Probo user for the adding in of all our Probo daemons.
RUN useradd -ms /bin/bash probo

# Install and enable repositories
RUN yum -y update && \
  yum -y install epel-release && \
  rpm -Uvh https://centos7.iuscommunity.org/ius-release.rpm && \
  yum -y update && \
  curl -sL https://rpm.nodesource.com/setup_12.x | bash -

# Install our common set of commands that we will need to do the key functions.
# gettext is for our envsubst command.
RUN yum -y install \
  curl \
  git2u \
  wget \
  gettext \
  docker-client

# Get the rethinkdb YUM repository information so we can install.
RUN wget http://download.rethinkdb.com/centos/7/`uname -m`/rethinkdb.repo \
    -O /etc/yum.repos.d/rethinkdb.repo

# Install all of the NodeJS dependencies as well as other Probo dependencies we will need
# to successfully build Probo.
RUN yum -y makecache fast && \
  yum -y install rethinkdb \
    nodejs \
    node-gyp \
    mocha \
    nodejs-should \
    make \
    gcc \
    g++

# Perform yum cleanup 
RUN yum -y upgrade && \
  yum clean all

# Switch to the probo user. Then create the Probo directory and change its permissions.
RUN groupadd docker && \
  usermod -aG docker probo && \
  mkdir /opt/probo && \
  chmod 755 -R /opt/probo && \
  chown probo:probo /opt && \
  chown probo:probo /opt/probo && \
  cd /opt/probo

USER probo

# Compile the main Probo daemons. This contains the container manager and everything we need to
# do the heavy lifting that IS probo as well as the secondary containers that support the main
# handler.

RUN git clone --depth=1 https://github.com/ProboCI/probo-loom.git /opt/probo/probo-loom
WORKDIR /opt/probo/probo-loom
RUN npm install

RUN git clone --depth=1 --branch=minio-endpoint https://github.com/ElusiveMind/probo-asset-receiver.git /opt/probo/probo-asset-receiver
WORKDIR /opt/probo/probo-asset-receiver
RUN npm install

RUN git clone --depth=1 https://github.com/ProboCI/probo-proxy.git /opt/probo/probo-proxy && rm -rf /opt/probo/probo-proxy/.git
WORKDIR /opt/probo/probo-proxy
RUN npm install

#RUN git clone --depth=1 --branch=feature/node-12 https://github.com/ProboCI/probo-notifier.git /opt/probo/probo-notifier && rm -rf /opt/probo/probo-notifier/.git
#WORKDIR /opt/probo/probo-notifier
#RUN npm install

RUN git clone --depth=1 --branch=feature/node-12 https://github.com/ProboCI/probo-reaper.git /opt/probo/probo-reaper
WORKDIR /opt/probo/probo-reaper
RUN npm install

RUN git clone --depth=1 --branch=feature/node-12 https://github.com/ProboCI/probo-gitlab.git /opt/probo/probo-gitlab && rm -rf /opt/probo/probo-gitlab/.git
WORKDIR /opt/probo/probo-gitlab
RUN npm install

RUN git clone --depth=1 --branch=elusivemind-pr https://github.com/ElusiveMind/probo.git /opt/probo/probo
WORKDIR /opt/probo/probo
RUN npm install

RUN git clone --depth=1 --branch=bitbucket-open-source-node-12 https://github.com/ElusiveMind/probo-bitbucket.git /opt/probo/probo-bitbucket && rm -rf /opt/probo/probo-bitbucket/.git
WORKDIR /opt/probo/probo-bitbucket
RUN npm install

USER root
COPY sh/startup.sh /opt/probo/startup.sh
RUN chmod 755 /opt/probo/startup.sh && chown probo:probo /opt/probo/startup.sh

RUN mkdir /opt/probo/yml
COPY yml/* /opt/probo/yml/
RUN chmod 755 /opt/probo/yml/* && chown -R probo:probo /opt/probo/yml

# Until a patch is made to correct variable sanity checking in probo-request-logger, we need to
# use this repo and branch and patch it directly into the node_modules directory.
#RUN rm -rf /opt/probo/probo/node_modules/probo-request-logger
#RUN git clone --depth=1 --branch=variable-sanity-checking https://github.com/ElusiveMind/probo-request-logger.git /opt/probo/probo/node_modules/probo-request-logger && rm -rf /opt/probo/probo-loom/node_modules/probo-request-logger/.git

WORKDIR /opt/probo

CMD ["/opt/probo/startup.sh"]
