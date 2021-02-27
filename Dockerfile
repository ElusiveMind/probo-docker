FROM ubuntu:20.04

# Set our our meta data for this container.
LABEL name="ProboCI"
LABEL author="Michael R. Bagnall <mbagnall@zivtech.com>"

WORKDIR /root

ENV TERM xterm

RUN apt-get -y update
RUN apt-get -y install curl dirmngr apt-transport-https lsb-release ca-certificates sudo apt-utils
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  git \
  netcat-openbsd \
  nodejs \
  openjdk-8-jre \
  software-properties-common \
  sudo \
  vim \
  wget \
  zip \
  gcc \
  g++ \
  make \
  curl \
  gettext \
  python

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get -y update \
  && apt-get -y install yarn

# Switch to the probo user. Then create the Probo directory and change its permissions.
RUN useradd -ms /bin/bash probo \
  && groupadd docker \
  && usermod -aG docker probo

# probo-coordinator: 8.17.0
# probo-db: 4.9.1
# probo-shell: 4.9.1
# probo-stash-handler: 4.9.1
# probo-web: 4.9.1

USER probo

ENV NVM_DIR   /home/probo/.nvm
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH

RUN mkdir /home/probo/.nvm \
  && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install 14.15.5 \
  && nvm install 4.9.1 \
  && nvm install 8.17.0 \
  && nvm install 12.20.2 \
  && nvm alias default 14.15.5 \
  \
  && nvm use 4.9.1 \
  && git clone --depth=1 https://github.com/ProboCI/loom.git /home/probo/loom \
  && cd /home/probo/loom \
  && npm install \
  \
  && nvm use 12.20.2 \
  && git clone --depth=1 -b 2020-03-06-Sprint-6 https://github.com/ProboCI/probo-asset-receiver.git /home/probo/probo-asset-receiver \
  && cd /home/probo/probo-asset-receiver \
  && npm install \
  \
  && git clone --depth=1 -b feature/node-12 https://github.com/ProboCI/probo-proxy.git /home/probo/probo-proxy \
  && cd /home/probo/probo-proxy \
  && npm install \
  \
  && nvm use 12.20.2 \
  && git clone --depth=1 -b feature/node-12 https://github.com/ProboCI/probo-notifier.git /home/probo/probo-notifier \
  && cd /home/probo/probo-notifier \
  && npm install \
  \
  && git clone --depth=1 -b feature/node-12 https://github.com/ProboCI/probo-reaper.git /home/probo/probo-reaper \
  && cd /home/probo/probo-reaper \
  && npm install \
  \
  && git clone --depth=1 https://github.com/ProboCI/probo-gitlab.git /home/probo/probo-gitlab \
  && cd /home/probo/probo-gitlab \
  && npm install \
  \
  && git clone --depth=1 --branch=2020-03-06-Sprint-6 https://github.com/ProboCI/probo.git /home/probo/probo \
  && cd /home/probo/probo \
  && nvm use 8.17.0 \
  && npm install \
  \
  && git clone --depth=1 https://github.com/ProboCI/probo-bitbucket.git /home/probo/probo-bitbucket \
  && cd /home/probo/probo-bitbucket \
  && nvm use 4.9.1 \
  && npm install

USER root
COPY sh/startup.sh /startup.sh
RUN mkdir /etc/probo
COPY yml/* /etc/probo/
RUN chown -R probo:probo /etc/probo
RUN chown probo:probo /startup.sh
USER probo



WORKDIR /home/probo

CMD ["/startup.sh"]
