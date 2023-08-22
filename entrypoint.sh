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
sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-email2email.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-email2email.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-email2email.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-email2email.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-users.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-users.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-users.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-users.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-virtual-alias-maps.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-virtual-alias-maps.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-virtual-alias-maps.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-virtual-alias-maps.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-virtual-mailbox-maps.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-virtual-mailbox-maps.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-virtual-mailbox-maps.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-virtual-mailbox-maps.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/postfix/pgsql-virtual-mailbox-domains.cf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/postfix/pgsql-virtual-mailbox-domains.cf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/postfix/pgsql-virtual-mailbox-domains.cf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/postfix/pgsql-virtual-mailbox-domains.cf

sed -i "s/{{DB_USER}}/$DB_USER/g" /etc/dovecot/dovecot-sql.conf
sed -i "s/{{DB_HOST}}/$DB_HOST/g" /etc/dovecot/dovecot-sql.conf
sed -i "s/{{DB_NAME}}/$DB_NAME/g" /etc/dovecot/dovecot-sql.conf
sed -i "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" /etc/dovecot/dovecot-sql.conf

sed -i "s/{{APP_HOST}}/$APP_HOST/g" /etc/dovecot/local.conf

# create database schema
export PGPASSWORD="$DB_PASSWORD"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -a -f mail_schema.sql

mkdir -p /run/dovecot
chmod -R +r /run/dovecot
chmod -R +w /run/dovecot
chmod -R 777 /home/vmail
# start logger
# comment line "module(load="imklog")" in /etc/rsyslog.conf
sed -i 's/^module(load="imklog")/#module(load="imklog")/g' /etc/rsyslog.conf
# start rsyslogd
rsyslogd 

# run Postfix and Dovecot
postfix start
dovecot -F