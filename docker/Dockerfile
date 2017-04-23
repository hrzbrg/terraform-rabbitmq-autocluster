FROM alpine:3.5

# Version of RabbitMQ to install
ENV RABBITMQ_VERSION=3.6.9
ENV PLUGIN_BASE=v3.6.x
ENV AUTOCLUSTER_VERSION=0.6.1

RUN \
  apk --update add bash coreutils "su-exec>=0.2" curl erlang erlang-asn1 erlang-crypto erlang-eldap erlang-erts erlang-inets erlang-mnesia erlang-os-mon erlang-public-key erlang-sasl erlang-ssl erlang-syntax-tools erlang-xmerl xz && \
  curl -sL -o /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz https://www.rabbitmq.com/releases/rabbitmq-server/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
  cd /usr/lib/ && \
  tar xf /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz && \
  rm /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz && \
  mv /usr/lib/rabbitmq_server-${RABBITMQ_VERSION} /usr/lib/rabbitmq

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN adduser -s /bin/bash -D -h /var/lib/rabbitmq rabbitmq

COPY erlang.cookie /var/lib/rabbitmq/.erlang.cookie
COPY rabbitmq.config /usr/lib/rabbitmq/etc/rabbitmq/rabbitmq.config
COPY launch.sh /launch.sh
COPY plugins/rabbitmq_aws-0.1.3.ez /usr/lib/rabbitmq/plugins/rabbitmq_aws-0.1.3.ez
COPY plugins/autocluster-0.6.1.ez /usr/lib/rabbitmq/plugins/autocluster-0.6.1.ez


# Environment variables required to run
ENV ERL_EPMD_PORT=4369
ENV HOME /var/lib/rabbitmq
ENV PATH /usr/lib/rabbitmq/bin:/usr/lib/rabbitmq/sbin:$PATH

ENV RABBITMQ_LOGS=-
ENV RABBITMQ_SASL_LOGS=-
ENV RABBITMQ_DIST_PORT=25672
ENV RABBITMQ_SERVER_ERL_ARGS="+K true +A128 +P 1048576 -kernel inet_default_connect_options [{nodelay,true}]"
ENV RABBITMQ_MNESIA_DIR=/var/lib/rabbitmq/mnesia
ENV RABBITMQ_PID_FILE=/var/lib/rabbitmq/rabbitmq.pid
ENV RABBITMQ_PLUGINS_DIR=/usr/lib/rabbitmq/plugins
ENV RABBITMQ_PLUGINS_EXPAND_DIR=/var/lib/rabbitmq/plugins

# Fetch the external plugins and setup RabbitMQ
RUN \
  apk --purge del curl tar gzip xz && \
  chown rabbitmq /var/lib/rabbitmq/.erlang.cookie /var/lib/rabbitmq /usr/lib/rabbitmq && \
  chmod 0600 /var/lib/rabbitmq/.erlang.cookie && \
  chmod a+x /launch.sh && \
  rabbitmq-plugins enable --offline \
        autocluster \
        rabbitmq_aws \
        rabbitmq_management \
        rabbitmq_mqtt && \
  rabbitmq-plugins list

EXPOSE 1883 4369 5671 5672 15672 25672

VOLUME $RABBITMQ_MNESIA_DIR
ENTRYPOINT ["/launch.sh"]
CMD ["rabbitmq-server"]
