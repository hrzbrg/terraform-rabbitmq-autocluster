#!/usr/bin/env bash

yum install -y docker
service docker restart
docker run -d \
    --name rabbitmq \
    --net=host \
    --dns-search=eu-west-1.compute.internal \
    --ulimit nofile=65536:65536 \
    --restart on-failure:5 \
    -p 1883:1883 \
    -p 4369:4369 \
    -p 5672:5672 \
    -p 15672:15672 \
    -p 25672:25672 \
    -e AUTOCLUSTER_TYPE=aws \
    -e AWS_AUTOSCALING=true \
    -e AUTOCLUSTER_CLEANUP=true \
    -e CLEANUP_WARN_ONLY=false \
    -e AWS_DEFAULT_REGION=eu-west-1 \
    -v /mnt/storage:/var/lib/rabbitmq/mnesia \
    hrzbrg/rabbitmq-autocluster
