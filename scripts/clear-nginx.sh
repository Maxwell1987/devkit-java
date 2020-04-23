#!/usr/bin/env bash

# Clear The Old Nginx Sites

rm -f /opt/proxy/etc/nginx/conf.d/*

docker container exec proxy nginx -s reload
