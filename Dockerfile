FROM centos:7
MAINTAINER Michael R. Bagnall <mrbagnall@icloud.com>
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

# Install all of the NodeJS dependencies as well as other Probo dependencies we will need
# to successfully build Probo.
RUN yum -y makecache fast
RUN yum -y install nodejs \
  node-gyp \
  mocha \
  nodejs-should \
  rethinkdb \
  make \
  gcc*

# Set up our firewall rules. (may not be necessary in a container)
#RUN firewall-cmd --zone=public --add-port=3010/tcp --permanent
#RUN firewall-cmd --zone=public --add-port=3012/tcp --permanent
#RUN firewall-cmd --zone=public --add-port=3050/tcp --permanent
#RUN firewall-cmd --zone=public --add-port=3070/tcp --permanent
#RUN systemctl restart firewalld

# Install our common set of commands that we will need to do the various things.
RUN yum -y install \
  curl \
  git2u \
  mariadb \
  msmtp \
  net-tools \
  python34 \
  vim \
  wget \
  rsync \ 
  docker-client

# Install PHP and PHP modules 
RUN yum -y install \
  php70u \
  php70u-curl \
  php70u-gd \
  php70u-imap \
  php70u-mbstring \
  php70u-mcrypt \
  php70u-mysql \
  php70u-odbc \
  php70u-pear \
  php70u-mysqlnd \
  php70u-pecl-imagick \
  php70u-pecl-json \
  php70u-pecl-zendopcache \
  php70u-redis \
  php70u-bcmath

# Get the rethinkdb daemon (deprecated)
RUN wget http://download.rethinkdb.com/centos/7/`uname -m`/rethinkdb.repo \
  -O /etc/yum.repos.d/rethinkdb.repo

# Perform yum cleanup 
RUN yum -y upgrade && \
  yum clean all

# Install Composer and Drush 
RUN curl -sS https://getcomposer.org/installer | php -- \
  --install-dir=/usr/local/bin \
  --filename=composer \
  --version=1.2.0 && \
  composer \
  --working-dir=/usr/local/src/ \
  global \
  require \
  drush/drush:8.* && \
  ln -s /usr/local/src/vendor/bin/drush /usr/bin/drush

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
RUN git clone https://github.com/ProboCI/probo.git /opt/probo/probo
RUN git clone https://github.com/ProboCI/probo-asset-receiver.git /opt/probo/probo-asset-receiver
RUN git clone https://github.com/ProboCI/probo-loom.git /opt/probo/probo-loom
RUN git clone https://github.com/ProboCI/probo-proxy.git /opt/probo/probo-proxy
RUN git clone https://github.com/ProboCI/probo-reaper.git /opt/probo/probo-reaper
RUN git clone -b bitbucket-open-source https://github.com/ElusiveMind/probo-bitbucket.git /opt/probo/probo-bitbucket

# Compile the main Probo daemon. This contains the container manager and everything we need to
# do the heavy lifting that IS probo.
WORKDIR /opt/probo/probo
RUN cd /opt/probo/probo
RUN npm install /opt/probo/probo

WORKDIR /opt/probo/probo-bitbucket
RUN cd /opt/probo/probo-bitbucket
RUN npm install /opt/probo/probo-bitbucket

WORKDIR /opt/probo/probo-asset-receiver
RUN cd /opt/probo/probo-asset-receiver
RUN npm install /opt/probo/probo-asset-receiver

WORKDIR /opt/probo/probo-loom
RUN cd /opt/probo/probo-loom
RUN npm install /opt/probo/probo-loom

WORKDIR /opt/probo/probo-proxy
RUN cd /opt/probo/probo-proxy
RUN npm install /opt/probo/probo-proxy

WORKDIR /opt/probo/probo-reaper
RUN cd /opt/probo/probo-reaper
RUN npm install /opt/probo/probo-reaper

EXPOSE 3010 3012 3050 3070

WORKDIR /opt/probo

CMD [ "/opt/probo/probo/bin/probo", "container-manager", "-c /opt/probo/probo/defaults.yaml" ];
