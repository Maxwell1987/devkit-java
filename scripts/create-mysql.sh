#!/usr/bin/env bash

docker container exec $2 \
  mysql --user="root" --password="secret" -e "GRANT ALL ON \`$1\`.* TO 'devkit'@'%';"

docker container exec $2 \
  mysql --user="devkit" --password="secret" -e "CREATE DATABASE IF NOT EXISTS \`$1\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;"
