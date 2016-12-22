FROM ubuntu:14.04

MAINTAINER Rajesh Taneja <rajesh.taneja@gmail.com>

#================================================
# Customize sources for apt-get
#================================================

RUN apt-get update \
 && apt-get install -y wget 

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

RUN apt-get update -y \
  && apt-get -y --no-install-recommends install \
    xvfb \
    bzip2 \
    ca-certificates \
    default-jdk \
    sudo \
    unzip \
    wget \
    curl \
    bzip2 \
    libfreetype6 \
    libfontconfig \
    libwebp-dev \
    libicu-dev \
    libxss1 \
    libappindicator1 \
    libindicator7 \
    google-chrome-stable \
    firefox \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY behatdrivers/chromedriver /behatdrivers/chromedriver
COPY behatdrivers/phantomjs /behatdrivers/phantomjs

RUN ln -s /behatdrivers/phantomjs /bin/phantomjs
RUN ln -s /behatdrivers/chromedriver /bin/chromedriver


RUN  mkdir -p /opt/selenium \
  && wget --no-verbose https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar -O /opt/selenium/selenium-server-standalone.jar

# Use older version of firefox.
RUN wget --no-verbose https://ftp.mozilla.org/pub/firefox/releases/47.0.1/linux-x86_64/en-US/firefox-47.0.1.tar.bz2 -O /opt/firefox-47.tar.bz2 \
  && cd /opt \
  && tar -xvf /opt/firefox-47.tar.bz2 \
  && rm /usr/bin/firefox \
  && ln -s /opt/firefox/firefox /usr/bin/firefox

RUN apt-get -fy install

RUN mkdir -p /var/www/html
COPY init.sh /init.sh
RUN chmod 777 /init.sh
RUN ln -s /init.sh /init

#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd moodle --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo moodle \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

EXPOSE 4443
EXPOSE 4444

ENTRYPOINT ["/init.sh"]

STOPSIGNAL 9