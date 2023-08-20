# Use a base image with Ubuntu or Debian
FROM ubuntu:latest

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql opendkim opendkim-tools

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

# Generate the DKIM Key Pair
COPY ./opendkim/opendkim.conf /etc/opendkim.conf
RUN opendkim-genkey -t -s mail -d mail.daruma.com

# Config Postfix:
RUN echo "milter_protocol = 6" >> /etc/postfix/main.cf && \
    echo "milter_default_action = accept" >> /etc/postfix/main.cf && \
    echo "smtpd_milters = inet:localhost:8891" >> /etc/postfix/main.cf && \
    echo "non_smtpd_milters = inet:localhost:8891" >> /etc/postfix/main.cf

# Expose SMTP and POP3 ports
EXPOSE 25 110

# Start Postfix and Dovecot
CMD service postfix start && service dovecot start && tail -F /var/log/mail.log
