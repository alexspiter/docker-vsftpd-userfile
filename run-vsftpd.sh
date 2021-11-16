#!/bin/bash

# по списку пользователей: создание каталогов виртуальных пользователей
n=0
bool=true
while read user
do
  if [[ "$bool" == true && -n $user ]]; then
    # объявление переменной среды
    ((n++))
    export FTP_USER$n=$user
    # создание каталога пользователя
    mkdir -p "/var/www/test_ftp.ru/local/$user"
    bool=false
  else
    bool=true
  fi
done < "/etc/vsftpd/virtual_users.txt"

# присвоение владельца ftp:ftp всем файлам каталога пользователя
chown -R ftp:ftp /var/www/test_ftp.ru/local

# по списку пользователей: запись виртуальных пользователей в БД db4
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# Get log file path
#export LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# stdout логгирование в файл $LOG_FILE
#/usr/bin/ln -sf /dev/stdout $LOG_FILE

# Если сертификат отсутствует,то он генерируется
if [ ! -e /etc/vsftpd/private/vsftpd.pem ]
then
    echo "Generating self-signed certificate"
    mkdir -p /etc/vsftpd/private

    openssl req -x509 -nodes -days 7300 \
        -newkey rsa:2048 -keyout /etc/vsftpd/private/vsftpd.pem -out /etc/vsftpd/private/vsftpd.pem \
        -subj "/C=RU/O=Test_ftp.ru/CN=test_ftp.ru"
    openssl pkcs12 -export -out /etc/vsftpd/private/vsftpd.pkcs12 -in /etc/vsftpd/private/vsftpd.pem -passout pass:

    chmod 755 /etc/vsftpd/private/vsftpd.pem
    chmod 755 /etc/vsftpd/private/vsftpd.pkcs12
fi

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
