#!/bin/bash

#########################
####### VARIABLES #######
#########################
ZABBIX_DB='zabbix'
ZABBIX_DB_HOST='localhost'
ZABBIX_DB_ADMIN='zabbix'
ZABBIX_DB_PASS='zabbix'
#########################
#########################

# Set Zabbix Repository
wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1+xenial_all.deb
dpkg -i zabbix-release_3.4-1+xenial_all.deb
apt update

#Install Zabbix Server, Frontend and MySQL data base
apt-get install -y -q \
  zabbix-server-mysql \
  zabbix-frontend-php \
  zabbix-agent

#Create Database and user
mysql -e "CREATE DATABASE ${ZABBIX_DB} CHARACTER SET utf8 COLLATE utf8_bin;"
mysql -e "CREATE USER ${ZABBIX_DB_ADMIN}@localhost IDENTIFIED BY '${ZABBIX_DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${ZABBIX_DB}.* TO '${ZABBIX_DB_ADMIN}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

#Crear esquema en la base de datos
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -u$ZABBIX_DB_ADMIN -p$ZABBIX_DB_PASS $ZABBIX_DB

#Backup del archivo de configuración de Zabbix server
cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bk
sed -i.bak -e "s/# DBHost=.*/DBHost=$ZABBIX_DB_HOST/" /etc/zabbix/zabbix_server.conf
sed -i.bak -e "s/DBName=zabbix/DBName=$ZABBIX_DB/" /etc/zabbix/zabbix_server.conf
sed -i.bak -e "s/DBUser=zabbix/DBUser=$ZABBIX_DB_ADMIN/" /etc/zabbix/zabbix_server.conf
sed -i.bak -e "s/# DBPassword=.*/DBPassword=$ZABBIX_DB_PASS/" /etc/zabbix/zabbix_server.conf

# Iniciar Zabbix server
service zabbix-server start
update-rc.d zabbix-server enable

# Preconfiguracion de Zabbix frontend
cp /etc/zabbix/apache.conf /etc/zabbix/apache.conf.bk
sed -i.bak -e "s@# php_value date.timezone Europe/Riga@php_value date.timezone America/Bogota@" /etc/zabbix/apache.conf

# Reiniciar apache
service apache2 restart

#Start Zabbix Agent
service zabbix-agent start
