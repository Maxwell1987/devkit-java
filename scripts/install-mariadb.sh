#!/usr/bin/env bash

set -e

if [ -f /home/vagrant/.devkit_java_mariadb ]
then
    echo "Mariadb already installed."
    exit 0
fi

if [ ! -f /home/vagrant/.devkit_java_docker ]; then
    /vagrant/scripts/install-docker.sh
fi

if [ ! -f /home/vagrant/.devkit_java_docker ]; then
    echo "Mariadb: docker installed failed, must install docker first."
    exit 0
fi

mkdir -p /opt/mariadb/run/secrets
echo "secret" | tee /opt/mariadb/run/secrets/mysql-root-password
mkdir -p /opt/mariadb/etc/mysql/conf.d
echo -e "[mysqld]\ndefault-time-zone='+08:00'" | tee /opt/mariadb/etc/mysql/conf.d/timezone.cnf

docker image pull mariadb:latest
docker container stop mysql 2> /dev/null || true

docker container run \
  -d \
  --name mariadb \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql-root-password \
  -p 3306:3306 \
  -v /opt/mariadb/etc/mysql/conf.d:/etc/mysql/conf.d \
  -v /opt/mariadb/run/secrets:/run/secrets \
  -v /opt/mariadb/var/lib/mysql:/var/lib/mysql \
  mariadb:latest

set +e

echo -n "Waiting for mariadb startup"

for i in {1..10}; do
    docker container logs mariadb 2>&1 | grep -q 'MySQL init process done. Ready for start up.'

    if [ $? -ne 0 ]; then
        sleep 1
        echo -n "."
    else
        break
    fi
done

while ! nc -w 1 localhost 3306 | grep -qP ".{10}"; do
    sleep 1
    echo -n "+"
done

echo

set -e

docker container exec mariadb \
  mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'devkit'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"

touch /home/vagrant/.devkit_java_mariadb
