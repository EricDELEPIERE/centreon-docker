service httpd start
service iptables stop
service mysql start
service cbd start
service centengine start
sed -i "s/^;date.timezone =$/date.timezone = \"Europe\/Zurich\"/" /etc/php.ini |grep "^timezone" /etc/php.ini
