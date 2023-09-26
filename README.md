# Mailst on Dokku: The Email Server

🌟 Hey there, fellow code wranglers! Ever wanted to roll your own email server but didn't want to get lost in a sea of configs and docs? Look no further! Mailst on Dokku is your one-stop-shop to get an email server up and running faster than you can say "SMTP."

### What's Under the Hood:
- **Postfix**
  The big kahuna of SMTP servers. It's what sends your emails out into the wild, wild web.
- **Dovecot**
  Your IMAP and POP3 buddy. It keeps your emails safe and sound until you're ready to read 'em.
- **OpenDKIM**
  No more spam folder! This bad boy makes sure your emails are legit with proper DKIM signatures.
- **Let's Encrypt**
  Because who has time to pay for SSL certificates? Not us!

### Why You'll Love It:
- It's on Dokku: If you're already using Dokku, setting this up is a breeze. If you're not, well, you should be.
- Security is a No-Brainer: SSL/TLS? Check. OpenDKIM? Double-check.
- DIY DNS: We've got a step-by-step guide to get your DNS records in tip-top shape.
- User Management for the Lazy: Add or remove users and domains with simple database commands. No sweat!

So go ahead, give Mailst on Dokku a spin and show off your shiny new email server at the next dev meetup. Trust us, your friends will be green with envy.

## Table of Contents

- [Server Side Setup](#server-side-setup)
- [SSL TLS Certificates](#ssl-tls-certificates)
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
# Map port 143 of the container to port 143 of the host machine (IMAP)
dokku docker-options:add mailst deploy "-p 143:143"
# Map port 587 of the container to port 587 of the host machine (Submission for email)
dokku docker-options:add mailst deploy "-p 587:587"
# Map port 993 of the container to port 993 of the host machine (IMAPS)
dokku docker-options:add mailst deploy "-p 993:993"
# Map port 465 of the container to port 465 of the host machine (SMTPS)
dokku docker-options:add mailst deploy "-p 465:465"

###### IF YOU WANT POP3 ######
# Map port 995 of the container to port 995 of the host machine (POP3S)
dokku docker-options:add mailst deploy "-p 995:995"
# Map port 110 of the container to port 110 of the host machine (POP3)
dokku docker-options:add mailst deploy "-p 110:110"

# Set the domain for the 'mailst' app to 'example.com' and any other domains
dokku domains:set mailst example.com

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


## SSL TLS Certificates
Add an "A" record in your domain's DNS settings:

"A" record example.com Value: IP address of server

```bash
dokku letsencrypt:set mailst email admin@mail.com
dokku letsencrypt:enable mailst
```

## Adding Variables
APP_HOST, DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME
```bash
dokku config:set mailst APP_HOST=example.com DB_HOST=[Database Host] DB_PORT=[Database Port] DB_USER=[Database Used] DB_PASSWORD=[PASSWORD] DB_NAME=[Database Name]
```

## OpenDKIM Setup
First, install OpenDKIM:
```bash
apt-get install opendkim opendkim-tools
```
Then in dir /var/lib/dokku/data/storage/mailst/opendkim/ create directorys by name of domains in "keys" dir
```bash
mkdir -p /~/keys/example.com
mkdir -p /~/keys/unxample.ua
...
```

Navigate to the directorys and generate keys
```bash
# Domain one
cd /~/keys/example.com
opendkim-genkey -s mail -d example.com
# Domain two
cd /~/keys/unxample.ua
opendkim-genkey -s mail -d unxample.ua
```
Create KeyTable file:
```bash
# KeyTable file
mailst._domainkey.example.com example.com:/etc/opendkim/keys/example.com/mail.private
mailst._domainkey.unxample.ua unxample.ua:/etc/opendkim/keys/unxample.ua/mail.private
```

Create SigningTable file:
```bash
# SigningTable file
*@example.com mailst._domainkey.example.com
*@unxample.ua mailst._domainkey.unxample.ua
```

## DNS Configuration
1. SPF (Sender Policy Framework):
   Add a TXT record:
    name: your.damain.server
    value: v=spf1 ip4:YOUR_SERVER_ADDRESS -all
2. DKIM (DomainKeys Identified Mail):
    Add a TXT record: 
      name: mailst._domainkey.your.damain.server
      valuse: v=DKIM1; h=sha256; k=rsa; p=YOUR_PUBLIC_KEY;
3. DMARC (Domain-based Message Authentication, Reporting & Conformance):
   Add a TXT record:
    name: _dmarc.your.damain.server
    value: v=DMARC1; p=none; pct=100; rua=mailto:you@example.com

***you can verify your DNS records with this tool: https://mxtoolbox.com/SuperTool.aspx***

The YOUR_PUBLIC_KEY you can take from /etc/opendkim/keys/example.com/mail.txt

## Push App and Test

Clone the git repository, create a git remote to your Dokku, and push image to your app.
```bash
git remote add mailst dokku@[your dokku server]:mailst
git push mailst master
```

## User Management
First you need to generate hashed password, connect to the database, and add user, domain, password
```bash
# Generate Hashed password
doveadm pw -s SHA512-CRYPT -p 'PASSWORD'
# Connect to database
dokku postgres:connect mailst_db
# Insert domain and user
INSERT INTO mail_virtual_domains (name) VALUES ('YOU_HOST');
# This is return id of domain
SELECT id FROM mail_virtual_domains WHERE name = 'YOU_HOST';
# insert user
INSERT INTO mail_virtual_users (domain_id, "user", password) VALUES (DOMAIN_ID, 'YOUR_USER', 'HASHED_PASSWORD');
```
YOUR_USER is name of user without domain, for example "admin". Then email adress will be "admin@example.com"

Just in case:
```bash
# Print info about users
SELECT u."user", d.name AS domain_name
FROM mail_virtual_users u
JOIN mail_virtual_domains d ON u.domain_id = d.id;
# Delete from table
DELETE FROM mail_virtual_users WHERE "user" = 'YOUR_USER' AND domain_id = (SELECT id FROM mail_virtual_domains WHERE name = 'example.com');
```






