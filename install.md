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
sudo mkdir -p /var/lib/globi /var/cache/globi
sudo chown globi:globi /var/lib/globi /var/cache/globi
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
sudo cp /etc/globi/cloudflare.ini.template /etc/globi/cloudflare.ini
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
echo 'deb https://debian.neo4j.com stable 3.5' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt-get update

sudo apt install neo4j=1:3.5.29
# https://linoxide.com/linux-how-to/exclude-specific-package-apt-get-upgrade/ 
# prevent neo4j from being automagically upgraded to latest version
sudo apt-mark hold neo4j 
```

### boostrap neo4j data

Neo4j server runs with a readonly copy of a pre-generated neo4j db. If you have an existing server and want to boostrap the neo4j instance use:

```

sudo rsync -Pavz -e "ssh -i [some path]/.ssh/id_rsa" [some user]@[some server]:/var/cache/neo4j/ /var/cache/
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
mc admin policy add globi write-reviews-only policy/write-reviews-only.json
mc admin policy set globi write-reviews-only group=review-users
mc config host add globi-reviews http://localhost:9000 [REVIEW_USER_ACCESS_KEY] [REVIEW_USER_SECRET_KEY] --api s3v4

mc admin user add globi [RELEASE_USER_ACCESS_KEY] [RELEASE_USER_SECRET_KEY]
mc admin group add globi release-users [RELEASE_USER_ACCESS_KEY]
mc admin policy add globi readwrite-release policy/readwrite-releases.json
mc admin policy set globi readwrite-release group=release-users

```
##### try make a "reviews" bucket
```
mc mb globi/reviews
mc mb globi/snapshot
mc mb globi/release
mc mb globi/datasets
```
## expect:
## Bucket created successfully `minio/reviews`.

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
sudo systemctl daemon-reload
sudo systemctl enable elton
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
sudo ln -s /var/lib/globi/systemd/system/globi-build-ramdisk.service /lib/systemd/system/globi-build-ramdisk.service
sudo systemctl enable globi-build-ramdisk.service

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

sudo ln -s /var/lib/globi/systemd/system/globi-review.service /lib/systemd/system/globi-review.service
sudo systemctl enable globi-review.service

sudo ln -s /var/lib/globi/systemd/system/globi-review.timer /lib/systemd/system/globi-review.timer
sudo systemctl enable globi-review.timer


## install globi sparql endpoint
```
sudo ln -s /var/lib/globi/systemd/system/globi-sparql.service /lib/systemd/system/globi-sparql.service

sudo systemctl enable globi-sparql.service 
```

## Amazon S3

Even though GloBI is in the process of deprecating use of S3 for ethical and economic reasons, the following bucket policy is used to restrict public access to buckets to known server addresses. This is to avoid potentially limitless bills for data transfer out of S3

```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::globi/release/*",
                "arn:aws:s3:::globi/datasets/*",
                "arn:aws:s3:::globi/reviews/*",
                "arn:aws:s3:::globi/snapshot/*"
            ],
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "IPV6 ADDRESS HERE",
                        "IPV4 ADDRESS HERE"
                    ]
                }
            }
        }
    ]
}
```

### sshfs

SSHFS is used by GloBI to mount network attached storage onto the GloBI server

ssh keys are used to access the system:

see https://docs.hetzner.com/robot/storage-box/backup-space-ssh-keys . 

```
$ sudo mkdir -p /etc/elton
$ sudo chown elton:elton /etc/elton
$ sudo -u elton mkdir -p  /etc/elton/.ssh/
$ sudo -u elton ssh-keygen -e -f /etc/elton/.ssh/id_rsa.pub | grep -v "Comment:" > /etc/elton/.ssh/id_rsa_rfc.pub
$ cat /etc/elton/.ssh/id_rsa.pub > /tmp/storagebox_authorized_keys
$ cat /etc/elton/.ssh/id_rsa_rfc.pub >> /tmp/storagebox_authorized_keys
...
echo -e "mkdir .ssh \n chmod 700 .ssh \n put /tmp/storagebox_authorized_keys .ssh/authorized_keys \n chmod 600 .ssh/authorized_keys" | sftp <username>@<username>.example.org
<username>@<username>.example.org's password:
```

Test connection using:
sudo sftp -oUserKnownHostsFile=/etc/elton/.ssh/known_hosts -i /etc/elton/.ssh/id_rsa <username>@<username>.example.org

#### enable mounting via sshfs

```
$ sudo install sshfs 
...
$ sudo ln -s /var/lib/globi/systemd/system/globi-mount-storagebox.service /lib/systemd/system/globi-mount-storagebox.service
$ sudo systemctl enable globi-mount-storagebox.service
$ sudo systemctl start globi-mount-storage.service



