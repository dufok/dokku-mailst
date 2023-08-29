Mailst App on Dokku
This guide outlines the steps to set up a Mailst app on a Dokku server.

Table of Contents
Server Side Setup
Domain Configuration
Reverse Proxy Setup
OpenDKIM Setup
DNS Configuration
Push App and Test
User Management
Server Side Setup
Run the following commands on your server:

bash
Copy code
# Create the app
dokku apps:create mailst
# Add Docker options
dokku docker-options:add mailst deploy "-p 25:25"
# ... (include all the commands here)
Domain Configuration
Add an A record in your domain's DNS settings:

A record [domain APP HOST] Value: IP address of server
Reverse Proxy Setup
For using more than one mail server on one server, you need to install HAProxy.

bash
Copy code
apt install haproxy
# Edit the config file
nano /etc/haproxy/haproxy.cfg
Include the HAProxy configuration here.

OpenDKIM Setup
First, install OpenDKIM:

bash
Copy code
apt-get install opendkim opendkim-tools
Then, generate keys:

bash
Copy code
# Navigate to the directory for [domain1]
cd /~/keys/[domain1]
opendkim-genkey -t -s mail -d [domain1]
# ... (include all the commands here)
DNS Configuration
SPF (Sender Policy Framework):
Add a TXT record: v=spf1 ip4:YOUR.SERVER.IP.ADDRESS -all
DKIM (DomainKeys Identified Mail):
Add a TXT record: v=DKIM1; k=rsa; p=YOUR_PUBLIC_KEY
DMARC (Domain-based Message Authentication, Reporting & Conformance):
Add a TXT record: v=DMARC1; p=none; pct=100; rua=mailto:you@example.com
Push App and Test
Push your app to Dokku:

bash
Copy code
git remote add dokku.daruma.dev dokku@dokku.daruma.dev:mailst
git push dokku.daruma.dev master
User Management
Generate a password:
bash
Copy code
doveadm pw -s SHA512-CRYPT -p '123test*test'
Connect to Dokku Postgres:
bash
Copy code
dokku postgres:connect maildb
Add the user:
bash
Copy code
INSERT INTO mail_users (email, password) VALUES ('daruma@mail.daruma.dev', '<hashed_password>');
