service iptables stop
service mysqld start
service cbd start
service centengine start
service snmpd start
sed -i "s/^;date.timezone =$/date.timezone = \"Europe\/Zurich\"/" /etc/php.ini |grep "^timezone" /etc/php.ini
service httpd restart

