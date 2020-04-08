# install instructions

(incomplete install instructions used as personal notes)

## install nginx

apt install nginx

## certbot

```
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx python3-certbot-dns-cloudflare
sudo apt-get install build-essential
```


# disable remote logins with passwords

Edit ```/etc/ssh/sshd_config```:

```
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
PermitRootLogin no
```

To apply ```sudo systemctl reload ssh```

# install certbot

create cloudflare.ini:
$ cat /home/jhpoelen/.secret/cloudflare.ini 
dns_cloudflare_email = "XXX"
dns_cloudflare_api_key = "XXXX"

then run the certbot:

sudo certbot -a dns-cloudflare -i nginx --server https://acme-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org -d api.globalbioticinteractions.org -d neo4j.globalbioticinteractions.org -d lod.globalbioticinteractions.org -d blog.globalbioticinteractions.org

# staging certbot (not production)

sudo certbot -a dns-cloudflare -i nginx --server https://acme-staging-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org -d api.globalbioticinteractions.org -d neo4j.globalbioticinteractions.org -d lod.globalbioticinteractions.org -d blog.globalbioticinteractions.org


## install neo4j

```
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt-get update

apt install neo4j=2.3.12
```
### create neo4j systemd service

Make sure to stop and disable the default ```/etc/init.d/neo4j-service``` that comes with the debian package - 

```
sudo service neo4j-service stop
sudo service neo4j-service disable
sudo rm /etc/init.d/neo4j-service
```

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

```
sudo systemctl daemon-reload
sudo systemctl enable neo4j.service 
```


## install git 
sudo apt install git


## install rest api
## maven
sudo apt install maven



## 
sudo useradd -r -s /bin/false globi

## instead do,
apt install openjdk-8-jdk-headless

## server scripts

git clone http://github.com/jhpoelen/globi-server-scripts

## install elton / create elton user without homedir and shell
sudo useradd -r -s /bin/false elton
sudo mkdir -p /var/cache/elton
sudo chown elton:elton /var/cache/elton
sudo ln -s [server-scripts-dir]/systemd/system/elton.service /etc/systemd/service/elton.service
sudo ln -s [server-scripts-dir]/systemd/system/elton.timer /etc/systemd/service/elton.timer
sudo systemctl daemon-reload
sudo systemctl enable preston.timer
sudo systemctl start preston.timer

## install globi build/update index services
sudo ln -s /home/jhpoelen/globi-server-scripts/systemd/system/globi-build-index.service /etc/systemd/system/globi-build-index.service
sudo systemctl enable globi-build-index.service

sudo ln -s /home/jhpoelen/globi-server-scripts/systemd/system/globi-update-index.service /etc/systemd/system/globi-update-index.service
sudo systemctl enable globi-update-index.service

## install globi web api service
sudo ln -s /home/jhpoelen/globi-server-scripts/systemd/system/globi-api.service /etc/systemd/system/globi-api.service

sudo systemctl enable globi-api.service 
