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

### disable syslog

prevents filling up your system with logs - instead, just stick with using systemd's journal :

```sudo systemctl disable syslog.socket```


To apply ```sudo systemctl reload ssh```

## create globi user

```
sudo useradd -r -s /bin/false globi
```

## globi server scripts and config
```
sudo mkdir -p /var/lib/globi /var/cache/globi /var/lib/globinizer /etc/globi
sudo chown globi:globi /var/lib/globi /var/cache/globi /var/lib/globinizer
sudo -u globi git clone https://github.com/jhpoelen/globi-server-scripts /var/lib/globi
sudo -u globi git clone https://github.com/globalbioticinteractions/globinizer /var/lib/globinizer
sudo -u globi git clone https://github.com/globalbioticinteractions/globalbioticinteractions /var/cache/globi/api
sudo -u globi git clone https://github.com/globalbioticinteractions/globalbioticinteractions /var/cache/globi/index
sudo cp /var/lib/globi/globi.conf.template /etc/globi/globi.conf
sudo chown root:root /etc/globi/globi.conf
sudo chmod 600 /etc/globi/globi.conf

sudo mkdir -p /etc/elton
sudo chown elton:elton /etc/elton
sudo cp /var/lib/globi/elton.conf.template /etc/elton/elton.conf
sudo chown elton:elton /etc/elton/elton.conf
sudo chmod 600 /etc/elton/elton.conf

```


# install certbot

create cloudflare.ini:
```
sudo cp /var/lib/globi/cloudflare.ini.template /etc/globi/cloudflare.ini
sudo chown root:root /etc/globi/cloudflare.ini
sudo chmod 600 /etc/globi/cloudflare.ini
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

```
sudo certbot -a dns-cloudflare -i nginx --server https://acme-staging-v02.api.letsencrypt.org/directory -d depot.globalbioticinteractions.org -d api.globalbioticinteractions.org -d neo4j.globalbioticinteractions.org -d lod.globalbioticinteractions.org -d blog.globalbioticinteractions.org
```

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
wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.com stable 3.5' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt-get update

sudo apt install neo4j=1:3.5.35
# https://linoxide.com/linux-how-to/exclude-specific-package-apt-get-upgrade/ 
# prevent neo4j from being automagically upgraded to latest version
sudo apt-mark hold neo4j 
```

### boostrap neo4j data

Neo4j server runs with a readonly copy of a pre-generated neo4j db. If you have an existing server and want to boostrap the neo4j instance use:

```

sudo rsync -Pavz -e "ssh -i [some path]/.ssh/id_rsa" [some user]@[some server]:/var/cache/neo4j/ /var/cache/
```


### create neo4j cache directories

```
sudo mkdir -p /var/cache/neo4j/data/databases
sudo chown -R neo4j:neo4j /var/cache/neo4j
```


### create neo4j systemd service
Now, enable and stop the systemd neo4j service

```
sudo systemctl enable neo4j.service 
sudo systemctl stop neo4j.service 
```

Now, link the neo4j configuration:

```
sudo mv /etc/neo4j /etc/neo4j.backup
sudo ln -s /var/lib/globi/neo4j /etc/neo4j
```

followed by linking the neo4j graph database locations:

```
sudo mv /var/lib/neo4j/data/databases/graph.db /var/lib/neo4j/data/databases/graph.db.backup
sudo ln -s /var/cache/neo4j/graph.db /var/lib/neo4j/data/databases/graph.db
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


from https://min.io/docs/minio/linux/operations/install-deploy-manage/migrate-fs-gateway.html 2023-06-03
Important

Standalone/file system mode continues to work on any release up to and including MinIO Server RELEASE.2022-10-24T18-35-07Z. To continue using a standalone deployment, install that MinIO Server release with MinIO Client RELEASE.2022-10-29T10-09-23Z or any earlier release with its corresponding MinIO Client. Note that the version of the MinIO Client should be newer and as close as possible to the version of the MinIO server.


```
#sudo wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio 
sudo wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2022-10-24T18-35-07Z -O /usr/local/bin/minio	
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
#sudo wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
sudo wget https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2022-10-29T10-09-23Z -O /usr/local/bin/mc
sudo chmod +x /usr/local/bin/mc
```

#### mc - client globi config

to help run cleanup.sh scripts, please create file at /etc/globi/.mc/config.json with 
```json
{
	"version": "9",
	"hosts": {
		"minio": {
			"url": "http://localhost:9000",
			"accessKey": "[access key]",
			"secretKey": "[secret key]",
			"api": "s3v4",
			"lookup": "auto"
		}
	}
}
```

##### add local minio to client
```
mc config host add globi http://localhost:9000 [MINIO_ACCESS_KEY] [MINIO_SECRET_KEY]

mc admin user add globi [REVIEW_USER_ACCESS_KEY] [REVIEW_USER_SECRET_KEY]

mc admin group add globi review-users [REVIEW_USER_ACCESS_KEY]
mc admin policy add globi write-reviews-only /var/lib/globi/policy/write-reviews-only.json
mc admin policy set globi write-reviews-only group=review-users
mc config host add globi-reviews http://localhost:9000 [REVIEW_USER_ACCESS_KEY] [REVIEW_USER_SECRET_KEY] --api s3v4

mc admin user add globi [RELEASE_USER_ACCESS_KEY] [RELEASE_USER_SECRET_KEY]
mc admin group add globi release-users [RELEASE_USER_ACCESS_KEY]
mc admin policy add globi readwrite-release /var/lib/globi/policy/readwrite-releases.json
mc admin policy set globi readwrite-release group=release-users

```
##### try make a "reviews" bucket
```
mc mb globi/reviews
mc mb globi/snapshot
mc mb globi/release
mc mb globi/datasets
```

expected outcome:

```
Bucket created successfully `globi/reviews`.
```


## install rest api
## maven

### bootstrap maven repository
Have an existing GloBI server and want to migrate existing repository folder:

```
sudo -u globi mkdir -p /var/cache/globi/repository
sudo rsync -Pavz -e "ssh -i [some path]/.ssh/id_rsa" [some user]@[some path]:/var/cache/globi/repository /var/cache/globi
```

### install maven binaries
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

sudo -u [username] /bin/bash
cd /home/[username]/
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

### use rsync to bootstrap from existing elton repository
### this assumes that you have access to remote server
### use [ssh-keygen] to generate keys and add them to remote server authorized_keys file 

```
sudo rsync -Pavz -e "ssh -i [some path]/.ssh/id_rsa" [some user]@[some server]:/var/cache/elton/datasets /var/cache/elton/
```

// install elton commandline using https://github.com/globalbioticinteractions/elton

```

sudo ln -s /var/lib/globi/systemd/system/elton.service /lib/systemd/system/elton.service
sudo ln -s /var/lib/globi/systemd/system/elton.timer /lib/systemd/system/elton.timer
sudo ln -s /var/lib/globi/systemd/system/elton-full.service /lib/systemd/system/elton-full.service
sudo ln -s /var/lib/globi/systemd/system/elton-full.timer /lib/systemd/system/elton-full.timer
sudo ln -s /var/lib/globi/systemd/system/elton-update-ready.service /lib/systemd/system/elton-update-ready.service

sudo systemctl daemon-reload

sudo systemctl enable elton
sudo systemctl enable elton.timer
sudo systemctl start elton.timer

sudo systemctl enable elton-full
sudo systemctl enable elton-full.timer
sudo systemctl start elton-full.timer
```

```
sudo ln -s /var/lib/globi/systemd/system/check-neo4j.service /lib/systemd/system/check-neo4j.service
sudo ln -s /var/lib/globi/systemd/system/check-neo4j.timer /lib/systemd/system/check-neo4j.timer
sudo systemctl daemon-reload
sudo systemctl enable check-neo4j.service
sudo systemctl enable check-neo4j.timer
```


## install globi build/update index services
```
sudo ln -s /var/lib/globi/systemd/system/globi-build-index.service /lib/systemd/system/globi-build-index.service
sudo systemctl enable globi-build-index.service

sudo ln -s /var/lib/globi/systemd/system/globi-update-index.service /lib/systemd/system/globi-update-index.service
sudo systemctl enable globi-update-index.service

sudo ln -s /var/lib/globi/systemd/system/globi-update-index.timer /lib/systemd/system/globi-update-index.timer

sudo systemctl enable globi-update-index.timer
```

## install save Elton repos timers
```
sudo ln -s /var/lib/globi/systemd/system/globi-save-repos.service /lib/systemd/system/globi-save-repos.service
sudo systemctl enable globi-save-repos.service

sudo ln -s /var/lib/globi/systemd/system/globi-save-repos.timer /lib/systemd/system/globi-save-repos.timer
sudo systemctl enable globi-save-repos.timer
sudo systemctl start globi-save-repos.timer
```


## install globi web api service
```
sudo ln -s /var/lib/globi/systemd/system/globi-api.service /lib/systemd/system/globi-api.service

sudo systemctl enable globi-api.service 
```

## install globi dataset review services

### review dependencies
```
sudo apt-get install s3cmd miller jq parallel
curl --silent -L https://github.com/mikefarah/yq/releases/download/v4.25.3/yq_linux_386 > yq && sudo chown root:root yq && sudo chmod +x yq && sudo mv yq /usr/local/bin
curl --silent -L https://github.com/jgm/pandoc/releases/download/3.1.6.1/pandoc-3.1.6.1-1-amd64.deb > pandoc.deb && sudo apt install -q ./pandoc.deb &> /dev/null
sudo apt -q install pandoc-citeproc
sudo apt -q install texlive texlive-xetex lmodern
sudo apt -q install graphviz
sudo apt -q install librsvg2-bin
sudo apt -q install libxml2-utils
sudo apt -q install pv
sudo pip install s3cmd
```

### review configuration
```
sudo cp /var/lib/globi/.s3cfg.template /etc/globi/.s3cfg
sudo chown globi:globi /etc/globi/.s3cfg
sudo chmod 600 /etc/globi/.s3cfg
```
after that, replace `REPLACE_ME` values with appropriate entries.

```
sudo ln -s /var/lib/globi/systemd/system/globi-review.service /lib/systemd/system/globi-review.service
sudo systemctl enable globi-review.service

sudo ln -s /var/lib/globi/systemd/system/globi-review.timer /lib/systemd/system/globi-review.timer
sudo systemctl enable globi-review.timer
```

## install globi sparql endpoint
```
sudo ln -s /var/lib/globi/systemd/system/globi-sparql.service /lib/systemd/system/globi-sparql.service

sudo systemctl enable globi-sparql.service 
```

### CIFS

CIFS/Samba is used by GloBI to mount network attached storage onto the GloBI server

from: 
https://docs.hetzner.com/robot/storage-box/access/access-samba-cifs/

also see:
https://askubuntu.com/questions/1210867/remount-cifs-on-network-reconnect

By adding the following line to ```/etc/fstab```, your system will automatically mount the file system at boot. (It is a single line!):

```
//<username>.your-storagebox.de/backup /mnt/backup-server cifs iocharset=utf8,rw,credentials=/etc/backup-credentials.txt,uid=<system account>,gid=<system group>,file_mode=0660,dir_mode=0770,noauto,x-systemd.automount,x-systemd.idle-timeout=30 0 0
```

The file /etc/backup-credentials.txt (mode 0600) should contain two lines as follows:

```
username=<username>
password=<password>
```

so add following to ```/etc/fstab```

```
//uXXXXXX-sub1.your-storagebox.de/uXXXXXX-sub1 /mnt/storagebox-uXXXXXX-sub1 cifs iocharset=utf8,rw,credentials=/etc/globi/storagebox-uXXXXXX-sub1-credentials.txt,uid=elton,gid=elton,file_mode=0755,dir_mode=0755,noauto,x-systemd.automount,x-systemd.idle-timeout=30 0 0
```


now, create elton cache dir (owned by ```elton``` user) using:

```
sudo mkdir -p /mnt/storagebox-uXXXXXX-sub1/
sudo ln -s /mnt/storagebox-uXXXXXX-sub1/ /var/cache/elton
sudo chown -h elton:elton /var/cache/elton
```

for similarly, for minio managed data, add to ```/etc/fstab```

```
//uXXXXXX-sub2.your-storagebox.de/uXXXXXX-sub2 /mnt/storagebox-uXXXXXX-sub2 cifs iocharset=utf8,rw,credentials=/etc/globi/storagebox-uXXXXXX-sub2-credentials.txt,uid=minio,gid=minio,file_mode=0755,dir_mode=0755,noauto,x-systemd.automount,x-systemd.idle-timeout=30 0 0
```

```
sudo mkdir -p /mnt/storagebox-uXXXXXX-sub2/
sudo ln -s /mnt/storagebox-uXXXXXX-sub2/ /var/cache/minio
sudo chown -h minio:minio /var/cache/minio
```

make sure to set the MINIO_DIR in /etc/globi/globi.conf to the absolute mount mount. It appears that minio doesn't like symlinks. Possibly related to https://github.com/minio/minio/issues/4588 .  


# install uncomplicated firewall (ufw)

sudo apt install ufw

## configure certbot to allow http for auto-renew

```
sudo mkdir -p /etc/letsencrypt
sudo cp etc/letsencrypt/cli.ini /etc/letsencrypt/cli.ini
```

where cli.ini contains something like:

```
# Manage Firewall
pre-hook = ufw allow http
post-hook = ufw deny http
```

# install duckdb

duckdb.org is used for data reviews and generating parquet files.




