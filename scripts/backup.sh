#!/bin/bash
docker-compose exec mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD" > /backups/domjudge.sql' 
