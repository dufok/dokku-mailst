# Use a base image with Ubuntu or Debian
FROM ubuntu:latest

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install necessary packages, postfix and dovecot
RUN apt-get update && \
    apt-get install -y postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql

# Create the pickup directory (resolve issue "postdrop: warning: unable to look up public/pickup: No such file or directory")
RUN mkdir -p /var/spool/postfix/public && \
    mkfifo /var/spool/postfix/public/pickup && \
    chown postfix:postdrop /var/spool/postfix/public/pickup && \
    chmod 0600 /var/spool/postfix/public/pickup

# Copy Postfix configuration files
COPY ./postfix-config/main.cf /etc/postfix/main.cf
RUN chmod go-w /etc/postfix/main.cf
COPY ./postfix-config/master.cf /etc/postfix/master.cf
RUN chmod go-w /etc/postfix/master.cf
COPY ./postfix-config/pgsql-domains.cf /etc/postfix/pgsql-domains.cf
RUN chmod go-w /etc/postfix/pgsql-domains.cf
COPY ./postfix-config/pgsql-mailboxes.cf /etc/postfix/pgsql-mailboxes.cf
RUN chmod go-w /etc/postfix/pgsql-mailboxes.cf

# Copy Dovecot configuration files
COPY ./dovecot-config/dovecot.conf /etc/dovecot/dovecot.conf
COPY ./dovecot-config/conf.d/* /etc/dovecot/conf.d/
COPY ./dovecot-config/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext

# Create mail directories
RUN mkdir -p /var/mail

RUN groupadd vmail
RUN useradd -g vmail vmail

# Set permissions for mail directories
RUN chown -R vmail:vmail /var/mail

# Set permissions for mail directories
RUN chown -R vmail:vmail /var/mail

# Generate the DKIM Key Pair
COPY ./opendkim/opendkim.conf /etc/opendkim.conf

# Expose SMTP and POP3 ports
EXPOSE 25 110

# Copy the entrypoint script
# COPY entrypoint.sh /entrypoint.sh

# Make it executable
# RUN chmod +x /entrypoint.sh

# Set the entry point
# ENTRYPOINT ["/entrypoint.sh"]

# Start Postfix and Dovecot ferst ver
CMD service postfix start && service dovecot start && touch /var/log/mail.log && tail -F /var/log/mail.log