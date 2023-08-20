# Use a base image with Ubuntu or Debian
FROM ubuntu:latest

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql

# Copy Postfix configuration files
COPY ./postfix-config/main.cf /etc/postfix/main.cf
COPY ./postfix-config/master.cf /etc/postfix/master.cf

# Copy Dovecot configuration files
COPY ./dovecot-config/dovecot.conf /etc/dovecot/dovecot.conf
COPY ./dovecot-config/conf.d/* /etc/dovecot/conf.d/

# Create mail directories
RUN mkdir -p /var/mail

# Set permissions for mail directories
RUN chown -R vmail:vmail /var/mail

# Expose SMTP and POP3 ports
EXPOSE 25 110

# Start Postfix and Dovecot
CMD service postfix start && service dovecot start && tail -F /var/log/mail.log