#!/bin/bash
docker-compose exec mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --force < /backups/domjudge.sql'

