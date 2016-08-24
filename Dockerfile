FROM centos:centos6
MAINTAINER matthieu-robin

# Update CentOS
RUN yum -y update
RUN yum -y install wget

# Install Centreon Repository
RUN wget http://yum.centreon.com/standard/3.0/stable/ces-standard.repo -O /etc/yum.repos.d/ces-standard.repo

# Install Maria-DB
RUN yum --nogpg -y install MariaDB-server
RUN /etc/init.d/mysql start

# Install ssh
RUN yum -y install openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:centreon' | chpasswd
RUN sed -i 's/^#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
RUN /etc/init.d/sshd start && /etc/init.d/sshd stop

# Install Centreon
RUN yum --nogpg -y install centreon-base-config-centreon-engine centreon

# Install Supervisor
RUN /bin/rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum -y install python-setuptools
RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor
ADD scripts/supervisord.conf /etc/supervisord.conf

EXPOSE 22 80
CMD ['/usr/bin/supervisord', '--configuration=/etc/supervisord.conf']
