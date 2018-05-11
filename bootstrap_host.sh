#!/bin/bash

#########################
####### VARIABLES #######
#########################

#########################
#########################

# Set Zabbix Repository
wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1+xenial_all.deb
dpkg -i zabbix-release_3.4-1+xenial_all.deb
apt update

#Install Zabbix Agent
apt-get install -y -q \
  zabbix-agent

# Reiniciar apache
service apache2 restart

#Start Zabbix Agent
service zabbix-agent start
