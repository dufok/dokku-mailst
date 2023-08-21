#!/bin/bash

# Add the user
useradd -m -s /bin/bash $MAIL_USER
echo "$MAIL_USER:$MAIL_PASSWORD" | chpasswd

# Start the server
service postfix start
service dovecot start
touch /var/log/mail.log && tail -F /var/log/mail.log