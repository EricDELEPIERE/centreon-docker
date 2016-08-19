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
RUN yum -y install centreon centreon-base-config-centreon-engine centreon-installed centreon-clapi

# Stop Mysql
RUN /etc/init.d/mysql stop

# Fix pass in db
ADD scripts/cbmod.sql /tmp/cbmod.sql
RUN /etc/init.d/mysql start && sleep 5 && mysql centreon < /tmp/cbmod.sql && /usr/bin/centreon -u admin -p centreon -a POLLERGENERATE -v 1 && /usr/bin/centreon -u admin -p centreon -a CFGMOVE -v 1 && /etc/init.d/mysql stop

# Set rights for setuid
RUN chown root:centreon-engine /usr/lib/nagios/plugins/check_icmp
RUN chmod -w /usr/lib/nagios/plugins/check_icmp
RUN chmod u+s /usr/lib/nagios/plugins/check_icmp

# Install and configure supervisor
RUN yum -y install python-setuptools

# Expose port SSH and HTTP for the service
# EXPOSE 22 80

# Set rights for setuid
RUN chown root:centreon-engine /usr/lib/nagios/plugins/check_icmp
RUN chmod -w /usr/lib/nagios/plugins/check_icmp
RUN chmod u+s /usr/lib/nagios/plugins/check_icmp

# Start SNMPD and HTTPD on boot
# RUN chkconfig snmpd on
# RUN chkconfig httpd on


# Install and configure supervisor
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum --enablerepo=epel install -y supervisor
RUN mv -f /etc/supervisord.conf /etc/supervisord.conf.org
ADD scripts/supervisord.conf /etc/supervisord.conf


# Expose port SSH and HTTP for the service
# EXPOSE 22 80

# Launch Supervisord
CMD ['/usr/bin/supervisord']
