#!/usr/bin/env bash

set -e

if [ -f /home/vagrant/.devkit_java_mysql ]
then
    echo "MySQL already installed."
    exit 0
fi

if [ ! -f /home/vagrant/.devkit_java_docker ]; then
    /vagrant/scripts/install-docker.sh
fi

if [ ! -f /home/vagrant/.devkit_java_docker ]; then
    echo "MySQL: docker installed failed, must install docker first."
    exit 0
fi

mkdir -p /opt/mysql/run/secrets
echo "secret" | tee /opt/mysql/run/secrets/mysql-root-password
mkdir -p /opt/mysql/etc/mysql/conf.d
echo -e "[mysqld]\ndefault-time-zone='+08:00'" | tee /opt/mysql/etc/mysql/conf.d/timezone.cnf

docker image pull mysql:latest
docker container stop mariadb 2> /dev/null || true

docker container run \
  -d \
  --name mysql \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql-root-password \
  -p 3306:3306 \
  -v /opt/mysql/etc/mysql/conf.d:/etc/mysql/conf.d \
  -v /opt/mysql/run/secrets:/run/secrets \
  -v /opt/mysql/var/lib/mysql:/var/lib/mysql \
  mysql:latest

set +e

echo -n "Waiting for mysql startup"

for i in {1..20}; do
    docker container logs mysql 2>&1 | grep -q 'MySQL init process done. Ready for start up.'

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

docker container exec mysql \
  mysql --user="root" --password="secret" -e "CREATE USER 'devkit'@'%' IDENTIFIED BY 'secret';"
docker container exec mysql \
  mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'devkit'@'%';"

touch /home/vagrant/.devkit_java_mysql
