# Use a base image with Ubuntu or Debian
FROM ubuntu:latest

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install necessary packages, postfix and dovecot
RUN apt-get update && \
    apt-get install -y postfix postfix-pgsql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-pgsql openssl  postgresql-client rsyslog iproute2

# Create the pickup directory (resolve issue "postdrop: warning: unable to look up public/pickup: No such file or directory")
RUN mkdir -p /var/spool/postfix/public && \
    mkfifo /var/spool/postfix/public/pickup && \
    chown postfix:postdrop /var/spool/postfix/public/pickup && \
    chmod 0600 /var/spool/postfix/public/pickup

# Copy Postfix configuration files
ADD postfix-config /etc/postfix

# Copy Dovecot configuration files
ADD dovecot-config /etc/dovecot

RUN postconf -e virtual_uid_maps=static:5000 && \
    postconf -e virtual_gid_maps=static:5000 && \
    postconf -e virtual_mailbox_domains=pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf && \
    postconf -e virtual_mailbox_maps=pgsql:/etc/postfix/pgsql-virtual-mailbox-maps.cf && \
    postconf -e virtual_alias_maps=pgsql:/etc/postfix/pgsql-virtual-alias-maps.cf,pgsql:/etc/postfix/pgsql-email2email.cf && \
    postconf -e virtual_transport=dovecot && \
    postconf -e dovecot_destination_recipient_limit=1 && \
    postconf -e smtpd_tls_cert_file=/etc/ssl/certs/{{APP_HOST}}.crt && \
    postconf -e smtpd_tls_key_file=/etc/ssl/certs/{{APP_HOST}}.key && \
    postconf -e smtpd_use_tls=yes && \
    postconf -e smtpd_tls_session_cache_database=btree:${data_directory}/smtpd_scache && \
    postconf -e smtp_tls_session_cache_database=btree:${data_directory}/smtp_scache && \
    # specially for docker
    postconf -F '*/*/chroot = n'

RUN echo "dovecot   unix  -       n       n       -       -       pipe"  >> /etc/postfix/master.cf && \
    echo '    flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -d ${recipient}' >> /etc/postfix/master.cf

# Create mail directories
RUN mkdir -p /var/mail

RUN groupadd -g 5000 vmail && \
    useradd -g vmail -u 5000 vmail -d /home/vmail -m && \
    chgrp postfix /etc/postfix/pgsql-*.cf && \
    chgrp vmail /etc/dovecot/dovecot.conf && \
    chmod g+r /etc/dovecot/dovecot.conf

# Set permissions for mail directories
RUN chown -R vmail:vmail /var/mail

# Set permissions for mail directories
RUN chown -R vmail:vmail /var/mail

# Generate the DKIM Key Pair
COPY ./opendkim/opendkim.conf /etc/opendkim.conf

# SMTP ports
EXPOSE 25
EXPOSE 587  
# POP and IMAP ports  
EXPOSE 110
EXPOSE 143
EXPOSE 995
EXPOSE 993

ADD mail_schema.sql /mail_schema.sql

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make it executable
RUN chmod +x /entrypoint.sh

# Set the entry point
ENTRYPOINT ["/entrypoint.sh"]

# Start Postfix and Dovecot ferst ver
#CMD service postfix start && service dovecot start && touch /var/log/mail.log && tail -F /var/log/mail.log