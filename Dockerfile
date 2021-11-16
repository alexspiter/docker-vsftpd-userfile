FROM centos:7

ARG USER_ID=14
ARG GROUP_ID=50

MAINTAINER Fer Uria <fauria@gmail.com>
LABEL Description="vsftpd Docker image based on Centos 7. Supports passive mode and virtual users." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST PORT NUMBER]:21 -v [HOST FTP HOME]:/home/vsftpd fauria/vsftpd" \
	Version="1.0"

RUN yum -y update && yum clean all
RUN yum install -y \
	openssl \
	vsftpd \
	db4-utils \
	db4 \
	iproute && yum clean all && rm -rf /var/cache/yum/*

RUN usermod -u ${USER_ID} ftp
RUN groupmod -g ${GROUP_ID} ftp

COPY vsftpd.conf /etc/vsftpd/
COPY chroot_list /etc/vsftpd/
COPY virtual_users.txt /etc/vsftpd/
COPY user_config_dir/ /etc/vsftpd/user_config_dir/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh
RUN mkdir -p /var/www/local
RUN chown -R ftp:ftp /var/www/local

VOLUME /var/www
VOLUME /var/log

EXPOSE 20 21 21100-21110

CMD ["/usr/sbin/run-vsftpd.sh"]
