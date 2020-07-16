# install instructions

(incomplete install instructions used as personal notes)

## certbot

```
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx python3-certbot-dns-cloudflare
sudo apt-get install build-essential git zip
```


# disable remote logins with passwords

Edit ```/etc/ssh/sshd_config```:

```
ChallengeResponseAuthentication no
PasswordAuthentication no
PermitRootLogin no
```

To apply ```sudo systemctl reload ssh```

## create globi user

```
sudo useradd -r -s /bin/false globi
```

## globi server scripts and config
```
sudo mkdir -p /var/lib/globi /var/cache/globi
sudo chown globi:globi /var/lib/globi /var/cache/globi
sudo -u globi git clone http://github.com/jhpoelen/globi-server-scripts /var/lib/globi
sudo -u globi git clone http://github.com/globalbioticinteractions/globalbioticinteractions /var/cache/globi/api
sudo -u globi git clone http://github.com/globalbioticinteractions/globalbioticinteractions /var/cache/globi/index
sudo cp /var/lib/globi/globi.conf.template /etc/globi/globi.conf
sudo chown root:root /etc/globi/globi.conf
sudo chmod 600 /etc/globi/globi.conf
```


# install certbot

create cloudflare.ini:
```
sudo cp /etc/globi/cloudflare.ini.template cloudflare.ini
```

Then, edit and replace with your cloudflare api credentials:
```
sudo nano /etc/globi/cloudflare.ini
```

then run the certbot:

```
sudo certbot -a dns-cloudflare -i nginx --server https://acme-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org -d blob.globalbioticinteractions.org -d api.globalbioticinteractions.org -d neo4j.globalbioticinteractions.org -d lod.globalbioticinteractions.org -d blog.globalbioticinteractions.org
```

# staging certbot (not production)

sudo certbot -a dns-cloudflare -i nginx --server https://acme-staging-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org -d api.globalbioticinteractions.org -d neo4j.globalbioticinteractions.org -d lod.globalbioticinteractions.org -d blog.globalbioticinteractions.org

## install nginx

```
apt install nginx
```

## re-use nginx configuration
## remove default

```
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /var/lib/globi/nginx/sites-available/globi.conf /etc/nginx/sites-enabled/globi.conf
```


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
sudo ln -s /var/lib/globi/systemd/system/neo4j.service /lib/systemd/system/neo4j.service
sudo systemctl daemon-reload
sudo systemctl enable neo4j.service 
```

Now, link the neo4j configuration:

```
sudo mv /etc/neo4j /etc/neo4j.backup
sudo ln -s /var/lib/globi/neo4j /etc/neo4j
```

start neo4j
```
sudo systemctl start neo4j
```


## install blob store

GloBI uses https://min.io as a blobstore and front for s3 backend. 

### make minio user
```
sudo useradd -r -s /bin/false minio
```
### make minio cache dir
```
sudo mkdir -p /var/cache/minio
sudo chown minio:minio /var/cache/minio
```
### install
minio (server) and mc (client)

```
sudo wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio 
sudo chmod +x /usr/local/bin/minio
```

#### minio - server

make sure to replace MINIO keys in /etc/globi/globi.conf

```
sudo ln -s /var/lib/globi/systemd/system/globi-blobstore.service /lib/systemd/system/globi-blobstore.service

sudo systemctl daemon-reload
sudo systemctl enable globi-blobstore.service
sudo systemctl start globi-blobstore.service
```

#### mc - client

```
sudo wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
sudo chmod +x /usr/local/bin/mc
```

##### add local minio to client
```
mc config host add minio http://localhost:9000 [MINIO_ACCESS_KEY] [MINIO_SECRET_KEY]
```
##### try make a "reviews" bucket
```
mc mb minio/reviews
```
## expect:
## Bucket created successfully `minio/reviews`.

## install rest api
## maven
```
sudo apt install maven
```
### configure maven settings.xml using a /var/lib/globi/.m2/settings.xml template

```
sudo mkdir -p /etc/globi/.m2/
sudo cp /var/lib/globi/.m2/settings.xml.template /etc/globi/.m2/settings.xml
sudo chown globi:globi /etc/globi/.m2/settings.xml
sudo chmod 600 /etc/globi/.m2/settings.xml
sudo mkdir -p /var/cache/globi/repository
sudo chown -R globi:globi /var/cache/globi
```


## add some users
```
sudo adduser [username]

sudo usermod -aG sudo [username]

cd /home/username/
mkdir .ssh
curl https://github.com/[username].keys > .ssh/authorized_keys
vi .ssh/authorized_keys
chmod  700 .ssh/
cd .ssh/
chmod 600 authorized_keys 
chown [username]:[username] -R /home/[username]/.ssh
```



## 
## install jdk
```
sudo apt install openjdk-8-jdk-headless
```

## install elton / create elton user without homedir and shell
```
sudo useradd -r -s /bin/false elton
sudo mkdir -p /var/cache/elton
sudo chown elton:elton /var/cache/elton
```

### bootstrapping from existing elton repository
### this assumes that you have access to remote server
### use [ssh-keygen] to generate keys and add them to remote server authorized_keys file 
```
rsync -Pavz [some user]@[some globi server]:/var/cache/elton/datasets ./datasets
```

// install elton commandline using https://github.com/globalbioticinteractions/elton

```
sudo ln -s /var/lib/globi/systemd/system/elton.service /lib/systemd/system/elton.service
sudo systemctl daemon-reload
sudo systemctl enable elton
```

## install globi build/update index services
```
sudo ln -s /var/lib/globi/systemd/system/globi-build-ramdisk.service /lib/systemd/system/globi-build-ramdisk.service
sudo systemctl enable globi-build-ramdisk.service

sudo ln -s /var/lib/globi/systemd/system/globi-unmount-ramdisk.service /lib/systemd/system/globi-unmount-ramdisk.service
sudo systemctl enable globi-unmount-ramdisk.service

sudo ln -s /var/lib/globi/systemd/system/globi-build-index.service /lib/systemd/system/globi-build-index.service
sudo systemctl enable globi-build-index.service

sudo ln -s /var/lib/globi/systemd/system/globi-update-index.service /lib/systemd/system/globi-update-index.service
sudo systemctl enable globi-update-index.service

sudo ln -s /var/lib/globi/systemd/system/globi-update-index.timer /lib/systemd/system/globi-update-index.timer

sudo systemctl enable globi-update-index.timer
```

## install globi web api service
```
sudo ln -s /var/lib/globi/systemd/system/globi-api.service /lib/systemd/system/globi-api.service

sudo systemctl enable globi-api.service 
```

## install globi sparql endpoint
```
sudo ln -s /var/lib/globi/systemd/system/globi-sparql.service /lib/systemd/system/globi-sparql.service

sudo systemctl enable globi-sparql.service 
```
