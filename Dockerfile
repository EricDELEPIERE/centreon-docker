FROM centos:centos6
MAINTAINER matthieu-robin

# Update CentOS
RUN yum -y update

# Install Centreon Repository
RUN yum -y install http://yum.centreon.com/standard/3.0/stable/noarch/RPMS/ces-release-3.0-1.noarch.rpm

# Install ssh
RUN yum -y install openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:centreon' | chpasswd
RUN sed -i 's/^#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
RUN /etc/init.d/sshd start && /etc/init.d/sshd stop

# Install Mysql
RUN yum -y install MariaDB-server 
RUN /etc/init.d/mysql start

# Install Centreon
RUN yum -y install centreon centreon-base-config-centreon-engine centreon-installed centreon-clapi centreon-widget-*

# Stop Mysql
/etc/init.d/mysql stop

# Fix pass in db
ADD scripts/cbmod.sql /tmp/cbmod.sql
RUN /etc/init.d/mysql start 
RUN sleep 5
RUN mysql centreon < /tmp/cbmod.sql

# Reload configuration
RUN usr/bin/centreon -u admin -p centreon -a POLLERGENERATE -v 1 
RUN /usr/bin/centreon -u admin -p centreon -a CFGMOVE -v 1
RUN /etc/init.d/mysql stop

# Set rights for setuid
RUN chown root:centreon-engine /usr/lib/nagios/plugins/check_icmp
RUN chmod -w /usr/lib/nagios/plugins/check_icmp
RUN chmod u+s /usr/lib/nagios/plugins/check_icmp

# Start SNMPD and HTTPD on boot
RUN chkconfig snmpd on
RUN chkconfig httpd on


# Install and configure supervisor
RUN yum -y install python-setuptools
RUN easy_install supervisor

# Todo better split file
ADD scripts/supervisord.conf /etc/supervisord.conf

# Expose port SSH and HTTP for the service
EXPOSE 22 80

CMD ['/usr/bin/supervisord', '--configuration=/etc/supervisord.conf']
