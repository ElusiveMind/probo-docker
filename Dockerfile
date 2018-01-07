FROM centos:7

# Set our our meta data for this container.
LABEL name="Containerized Open Source Probo.CI Server"
LABEL description="This is our Docker container for the open source version of ProboCI."
LABEL author="Michael R. Bagnall <mrbagnall@icloud.com>"
LABEL vendor="ProboCI, LLC."
LABEL version="0.09"

# Set up our standard binary paths.
ENV PATH /usr/local/src/vendor/bin/:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm 

# Fix command line compile issue with bundler.
ENV LC_ALL en_US.utf8

# Create the Probo user for the adding in of all our Probo daemons.
RUN useradd -ms /bin/bash probo

# Install and enable repositories RUN yum -y update && \
RUN yum -y install epel-release && \
  rpm -Uvh https://centos7.iuscommunity.org/ius-release.rpm && \
  yum -y update

# Install our common set of commands that we will need to do the key functions.
# gettext is for our envsubst command.
RUN yum -y install \
  curl \
  git2u \
  net-tools \
  vim \
  wget \
  gettext \
  docker-client 

# Get the rethinkdb YUM repository information so we can install.
RUN wget http://download.rethinkdb.com/centos/7/`uname -m`/rethinkdb.repo \
    -O /etc/yum.repos.d/rethinkdb.repo

# Install all of the NodeJS dependencies as well as other Probo dependencies we will need
# to successfully build Probo.
RUN yum -y makecache fast
RUN yum -y install rethinkdb
RUN yum -y install nodejs \
  node-gyp \
  mocha \
  nodejs-should \
  make \
  gcc*

# Get the rethinkdb daemon (deprecated)
RUN wget http://download.rethinkdb.com/centos/7/`uname -m`/rethinkdb.repo \
  -O /etc/yum.repos.d/rethinkdb.repo

# Perform yum cleanup 
RUN yum -y upgrade && \
  yum clean all

# Switch to the probo user. Then create the Probo directory and change its permissions.
RUN groupadd docker
RUN usermod -aG docker probo
RUN mkdir /opt/probo
RUN chmod 755 -R /opt/probo
RUN chown probo:probo /opt
RUN chown probo:probo /opt/probo
RUN cd /opt/probo
USER probo

# Get all of our relevant Probo repositories.
RUN git clone --depth=1 https://github.com/ProboCI/probo.git /opt/probo/probo
RUN git clone --depth=1 https://github.com/ProboCI/probo-asset-receiver.git /opt/probo/probo-asset-receiver
RUN git clone --depth=1 https://github.com/ProboCI/probo-loom.git /opt/probo/probo-loom
RUN git clone --depth=1 --branch=hostname-replace-docker-hosting https://github.com/ElusiveMind/probo-proxy.git /opt/probo/probo-proxy && rm -rf /opt/probo/probo-proxy/.git
RUN git clone --depth=1 https://github.com/ProboCI/probo-reaper.git /opt/probo/probo-reaper
RUN git clone --depth=1 --branch=bitbucket-open-source https://github.com/ElusiveMind/probo-bitbucket.git /opt/probo/probo-bitbucket && rm -rf /opt/probo/probo-bitbucket/.git
RUN git clone --depth=1 --branch=switch-to-kafka https://github.com/ElusiveMind/probo-notifier.git /opt/probo/probo-notifier && rm -rf /opt/probo/probo-notifier/.git
RUN git clone --depth=1 --branch=case-normalization https://github.com/ElusiveMind/probo-gitlab.git /opt/probo/probo-gitlab && rm -rf /opt/probo/probo-gitlab/.git

# Compile the main Probo daemons. This contains the container manager and everything we need to
# do the heavy lifting that IS probo as well as the secondary containers that support the main
# handler.
WORKDIR /opt/probo/probo
RUN cd /opt/probo/probo
RUN npm install /opt/probo/probo

WORKDIR /opt/probo/probo-loom
RUN cd /opt/probo/probo-loom
RUN npm install /opt/probo/probo-loom

WORKDIR /opt/probo/probo-bitbucket
RUN cd /opt/probo/probo-bitbucket
RUN npm install /opt/probo/probo-bitbucket

WORKDIR /opt/probo/probo-asset-receiver
RUN cd /opt/probo/probo-asset-receiver
RUN npm install /opt/probo/probo-asset-receiver

WORKDIR /opt/probo/probo-proxy
RUN cd /opt/probo/probo-proxy
RUN npm install /opt/probo/probo-proxy

WORKDIR /opt/probo/probo-notifier
RUN cd /opt/probo/probo-notifier
RUN npm install /opt/probo/probo-notifier

WORKDIR /opt/probo/probo-reaper
RUN cd /opt/probo/probo-reaper
RUN npm install /opt/probo/probo-reaper

WORKDIR /opt/probo/probo-gitlab
RUN cd /opt/probo/probo-gitlab
RUN npm install /opt/probo/probo-gitlab

USER root
COPY sh/startup.sh /opt/probo/startup.sh
RUN chmod 755 /opt/probo/startup.sh
RUN chown probo:probo /opt/probo/startup.sh

RUN mkdir /opt/probo/yml
COPY yml/* /opt/probo/yml/
RUN chmod 755 /opt/probo/yml/*
RUN chown -R probo:probo /opt/probo/yml

# Until a patch is made to correct variable sanioty checking in probo-request-logger, we need to
# use this repo and branch and patch it directly into the node_modules directory.
RUN rm -rf /opt/probo/probo/node_modules/probo-request-logger
RUN git clone --depth=1 --branch=variable-sanity-checking https://github.com/ElusiveMind/probo-request-logger.git /opt/probo/probo/node_modules/probo-request-logger && rm -rf /opt/probo/probo-loom/node_modules/probo-request-logger/.git

WORKDIR /opt/probo

CMD ["/opt/probo/startup.sh"]
