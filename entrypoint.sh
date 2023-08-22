#!/bin/bash

# default 
echo "Running Dovecot + Postfix"
echo "Host: $APP_HOST (should be set)"
echo "Database: $DB_NAME (should be set)"
echo "Available environment vars:"
echo "APP_HOST *required*, DB_NAME *required*, DB_USER, DB_PASSWORD"

# adding IP of a host to /etc/hosts
export HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
echo "$HOST_IP dockerhost" >> /etc/hosts

# defining mail name
echo "localhost" > /etc/mailname

# update config templates
# POSTFIX
sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/postfix/main.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-domains.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-domains.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-domains.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-domains.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-mailboxes.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-mailboxes.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-mailboxes.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-mailboxes.cf

# DOVECOT
sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/dovecot.conf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/dovecot/dovecot-sql.conf.ext
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/dovecot/dovecot-sql.conf.ext
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/dovecot/dovecot-sql.conf.ext
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/dovecot/dovecot-sql.conf.ext

sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/conf.d/10-ssl.conf

#sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/conf.d/10-master.conf
#sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/conf.d/10-auth.conf
#sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/conf.d/10-mail.conf
#sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/conf.d/10-logging.conf
#sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/conf.d/10-director.conf

mkdir /run/dovecot
chmod -R +r /run/dovecot
chmod -R +w /run/dovecot
chmod -R 777 /home/vmail
# start logger
rsyslogd 

# Start the server
service postfix start
service dovecot start
touch /var/log/mail.log && tail -F /var/log/mail.log