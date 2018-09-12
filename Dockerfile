FROM openjdk:8-jre

ARG activemq_ver=5.15.5
ARG activemq_mirror=http://ba.mirror.garr.it/mirrors/apache/activemq

ENV DEBIAN_FRONTEND noninteractive

ENV ACTIVEMQ_VERSION=$activemq_ver
ENV ACTIVEMQ_MIRROR=$activemq_mirror

ENV ACTIVEMQ_CONFIG_DIR /opt/activemq/conf.tmp
ENV ACTIVEMQ_DATA_DIR /data/activemq

# Update distro and install some packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y python-testtools python-nose python-pip vim curl supervisor logrotate locales  && \
    update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    rm -rf /var/lib/apt/lists/*

# Install setuptools to solve debian issue
RUN pip install wheel setuptools

# Install stompy
RUN pip install stomp.py

# Lauch app install
COPY assets/setup/ /app/setup/
RUN chmod +x /app/setup/install
RUN /app/setup/install

# Copy the app setting
COPY assets/entrypoint /app/
COPY assets/run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Expose all port
EXPOSE 8161
EXPOSE 61616
EXPOSE 5672
EXPOSE 61613
EXPOSE 1883
EXPOSE 61614

# Expose some folders
VOLUME ["/data/activemq"]
VOLUME ["/var/log/activemq"]
VOLUME ["/opt/activemq/conf"]

WORKDIR /opt/activemq

CMD ["/app/run.sh"]
