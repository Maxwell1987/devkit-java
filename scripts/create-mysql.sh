#!/usr/bin/env bash

cat > /root/.my.cnf << EOF
[client]
user = devkit
password = secret
host = localhost
EOF

cp /root/.my.cnf /home/ubuntu/.my.cnf

DB=$1;

mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci";
