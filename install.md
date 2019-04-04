# install instructions

(incomplete install instructions used as personal notes)

## install nginx

apt install nginx

## certbot

sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx python3-certbot-dns-cloudflare


sudo certbot -a dns-cloudflare -i nginx --server https://acme-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org

# staging certbot

sudo certbot -a dns-cloudflare -i nginx --server https://acme-staging-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org -d api.globalbioticinteractions.org -d neo4j.globalbioticinteractions.org -d lod.globalbioticinteractions.org -d blog.globalbioticinteractions.org


## install neo4j 
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt-get update

apt install neo4j=2.3.12

### create neo4j systemd service

/etc/systemd/system/neo4j.service -

```
[Unit]
Description=Neo4j Graph Database
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/var/lib/neo4j/bin/neo4j console
Restart=on-failure
User=neo4j
Environment="NEO4J_CONF=/etc/neo4j" "NEO4J_HOME=/var/lib/neo4j"
LimitNOFILE=60000
TimeoutSec=120
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target

```

sudo systemctl daemon-reload
sudo systemctl enable neo4j.service 


## install git 
sudo apt install git


## install rest api
## maven
sudo apt install maven
 
## oracle's java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer


