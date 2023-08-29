# Mailst App on Dokku

This guide outlines the steps to set up a Mailst app on a Dokku server.

## Table of Contents

- [Server Side Setup](#server-side-setup)
- [Domain Configuration](#domain-configuration)
- [OpenDKIM Setup](#opendkim-setup)
- [DNS Configuration](#dns-configuration)
- [Push App and Test](#push-app-and-test)
- [User Management](#user-management)

## Server Side Setup

Run the following commands on your server:

```bash
# Create a new Dokku app named 'mailst'
dokku apps:create mailst

# Add Docker options to map port 25 of the container to port 25 of the host machine (SMTP)
dokku docker-options:add mailst deploy "-p 25:25"
# Map port 110 of the container to port 110 of the host machine (POP3)
dokku docker-options:add mailst deploy "-p 110:110"
# Map port 143 of the container to port 143 of the host machine (IMAP)
dokku docker-options:add mailst deploy "-p 143:143"
# Map port 995 of the container to port 995 of the host machine (POP3S)
dokku docker-options:add mailst deploy "-p 995:995"
# Map port 587 of the container to port 587 of the host machine (Submission for email)
dokku docker-options:add mailst deploy "-p 587:587"
# Map port 993 of the container to port 993 of the host machine (IMAPS)
dokku docker-options:add mailst deploy "-p 993:993"

# Set the domain for the 'mailst' app to 'example.com' and any other domains
dokku domains:set mailst example.com [all domains...]

# Ensure that the directory '/var/lib/dokku/data/storage/mailst' exists on the host machine
dokku storage:ensure-directory mailst /var/lib/dokku/data/storage/mailst

# Create a new Postgres database named 'mailst_db'
dokku postgres:create mailst_db
# Link the 'mailst_db' database to the 'mailst' app
dokku postgres:link mailst_db mailst

# Create a directory for OpenDKIM keys on the host machine
mkdir /var/lib/dokku/data/storage/mailst/opendkim
# Create a directory for mail storage on the host machine
mkdir /var/lib/dokku/data/storage/mailst/mail

# Mount the host directory to the '/var/mail/' directory inside the 'mailst' container
dokku storage:mount mailst /var/lib/dokku/data/storage/mailst/mail/:/var/mail/
# Mount the Let's Encrypt certificates from the host to the '/etc/ssl/certs/' directory inside the 'mailst' container
dokku storage:mount mailst /home/dokku/mailst/letsencrypt/certs/current/certificates/:/etc/ssl/certs/
# Mount the OpenDKIM keys directory from the host to the '/etc/opendkim/' directory inside the 'mailst' container
dokku storage:mount mailst /var/lib/dokku/data/storage/mailst/opendkim/:/etc/opendkim/
```


## Domain Configuration
Add an "A" record in your domain's DNS settings:

"A" record example.com Value: IP address of server



