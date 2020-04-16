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

Now, install the systemd neo4j service

```
sudo ln -s [server-scripts-dir]/systemd/system/neo4j.service /etc/systemd/service/neo4j.service
sudo systemctl daemon-reload
sudo systemctl enable neo4j.service 
```

## install blob store

GloBI uses https://min.io as a blobstore and front for s3 backend. 

### make minio user
sudo useradd -r -s /bin/false minio

### make minio cache dir
sudo mkdir -p /var/cache/minio
sudo chmod minio:minio /var/cache/minio

### install
minio (server) and mc (client)

wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio 
sudo chmod +x /usr/local/bin/minio


#### minio - server

make sure to replace MINIO keys in /etc/globi/globi.conf

sudo ln -s [globi-server-scripts]/systemd/system/globi-blobstore.service /etc/systemd/system/globi-blobstore.service

sudo systemctl daemon-reload
sudo systemctl enable globi-blobstore.service
sudo systemctl start globi-blobstore.service


#### mc - client

wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
sudo chmod +x /usr/local/bin/mc

##### add local minio to client
mc config host add minio http://localhost:9000 [MINIO_ACCESS_KEY] [MINIO_SECRET_KEY]

##### try make a "reviews" bucket
mc mb minio/reviews

## expect:
## Bucket created successfully `minio/reviews`.


## install git 
sudo apt install git


## install rest api
## maven
sudo apt install maven



## 
sudo useradd -r -s /bin/false globi

## install jdk
apt install openjdk-8-jdk-headless

## server scripts and config
git clone http://github.com/jhpoelen/globi-server-scripts

## link configuration file
sudo mkdir -p /etc/globi
sudo ln -s [server-scripts-dir]/globi.conf /etc/globi/globi.conf

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
sudo ln -s [globi-scripts-dir]/systemd/system/globi-build-ramdisk.service /etc/systemd/system/globi-build-ramdisk.service
sudo systemctl enable globi-build-ramdisk.service

sudo ln -s [globi-scripts-dir]/systemd/system/globi-unmount-ramdisk.service /etc/systemd/system/globi-unmount-ramdisk.service
sudo systemctl enable globi-unmount-ramdisk.service

sudo ln -s [globi-scripts-dir]/systemd/system/globi-build-index.service /etc/systemd/system/globi-build-index.service
sudo systemctl enable globi-build-index.service

sudo ln -s [globi-scripts-dir]/systemd/system/globi-update-index.service /etc/systemd/system/globi-update-index.service
sudo systemctl enable globi-update-index.service

## install globi web api service
sudo ln -s [globi-scripts-dir]/systemd/system/globi-api.service /etc/systemd/system/globi-api.service

sudo systemctl enable globi-api.service 

## install globi sparql endpoint
sudo ln -s [globi-scripts-dir]/systemd/system/globi-api.service /etc/systemd/system/globi-sparql.service

sudo systemctl enable globi-sparql.service 
