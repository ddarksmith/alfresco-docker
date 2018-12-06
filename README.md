<p align="center"> 
  <img title="Alfresco" src="https://raw.githubusercontent.com/Alfresco/alfresco-content-app/master/alfresco.png" alt="Alfresco - make business flow">
</p>


# Docker Composition for Alfresco 5.2 stack

Docker Composition for integration with Alfresco 5.2

**Docker** & **Docker Compose** software is required to use this project.
You should review volumes, configuration, modules & tuning parameters before using this composition in **Production** environments.

## Starting

Download or clone this repository.
```
$ git clone https://github.com/ddarksmith/alfresco-docker.git
```

Persistent data folders path can be changed by modifying local paths set in `volumes` directives at `docker-compose.yml` to global paths

```
volumes
├── backup                           (this is where bart will put the full and incremental backup.)
├── config
│   ├── bart                         (backup software configuration)
│   ├── elk                          (elk monitoring configuration)
│   ├── ext-auth                     (alfresco with kerberos configuration)
│   ├── nagios                       (nagios monitoring configuration)
│   ├── SSL                          (ssl certificate sample cert)
│   │   └──createssl.sh              (ssl certificate generator)
│   ├── alfresco-global.properties   (alfresco repository configuration file)
│   ├── custom.log4j.properties      (alfresco repository logger configuration)
│   ├── share-config-custom.xml      (alfresco share configuration file)
│   └── users.htpasswd               (user/password for protected admin area solr/nagios/kibana)
├── data                             
│   ├── alf-repo-data                (alfresco repository content store. known as alf_data)
│   ├── els-data                     (elasticsearch indexes for elk monitoring. eg. audit, performance...)
│   ├── postgres-data                (postgresql data contain the alfresco repository database)
│   └── solr-data                    (solr indexes. Consider mount it on SSD drive)
└── logs
    ├── alfresco                     (link to the alfresco repository logfile folder)
    ├── bart                         (link to the bart logs)
    ├── elk                          (link to ELK logs)
    ├── postgres                     (link to postgresql logs)
    ├── proxy                        (link to httpd reverse proxy logs)
    └── share                        (link to alfresco share logs)
```

For the example I've put the whole Volumes structure in /volumes
```
$ cp -R ./volumes /
```

Give the persistent volumes permissions
```
$ chown 1000:1000 -R /volumes
$ chmod -R 664 /volumes
```

The postgres-data folder need to be own by postgres user with the uid 999 on your host
```
$ groupadd -g 999 postgres
$ useradd -u 999 postgres
$ chown postgres:postgres /volumes/data/postgres-data

```

The elasticsearch folder need to be own by elasticsearch user with the uid 991 on your host
```
$ useradd -u 991 elasticsearch
$ chown elasticsearch /volumes/data/postgres-data

```

The redis log folder need to be own by redi user with the uid 107 on your host. 
(Beware, on some system user uid 107 is 'messagebus' You can just chown to this user in that specific case)
```
$ useradd -u 107 redis
$ chown redis /volumes/logs/elk/redis

```

If you have ssl certificate for your company put it in /volumes/config/ssl and configure alfresco-vhost.conf with it's correct name in those lines
```
    SSLCertificateFile /etc/pki/tls/certs/alfresco.crt
    SSLCertificateKeyFile /etc/pki/tls/certs/alfresco.key
```

If you prefer to generate a self-signed one execute the sslcreate.sh script and follow the instructions



From the base directory, start Docker Compose.

```
$ docker-compose up
```

Once all the containers have been started, a message similar to following one will appear.

```
alfresco     | Nov 15, 2018 11:03:22 AM org.apache.catalina.startup.Catalina start
alfresco     | INFO: Server startup in 70314 ms
```


## Available services

Once the composition is up, you can check available services:

|   Services            |    Links                                        |  Container Name |
|-----------------------|-------------------------------------------------|-----------------|
| Alfresco Repository   | - https://alfresco.companyname.com/alfresco     |  - alfresco     |
| Alfresco Share Web App| - https://alfresco.companyname.com/share        |  - share        |
| Alfresco ADF Web App  | - https://alfresco.companyname.com/adf          |  - content-app  |
| SOLR Indexer          | - https://alfresco.companyname.com/solr         |  - solr         |
| Swagger REST API Doc  | - https://alfresco.companyname.com/api-explorer |                 |
| NAGIOS Monitoring     | - https://alfresco.companyname.com/nagios       |  - nagios       |
| ELK Monitoring        | - http://alfresco.companyname.com:5601          |  - elk          |
| Postgresql            | - Exposed on port 5432                          |  - db           |
| Bart                  |                                                 |  - bart         |

## Customizations

Following operations are available to customize your Docker Composition.

**Deploying modules**

Copy your artifacts (AMP or JAR) to deployment folders:

* Alfresco Repository
  * `alfresco-repo/assets/amps`
  * `alfresco-repo/assets/jars`

* Share Web App
  * `alfresco-share/assets/amps_share`
  * `alfresco-share/assets/jars`


**Configuration**

Modify configuration files:

* Alfresco Repository
  * `volumes/config/alfresco-global.properties`
  * `volumes/config/custom-log4j.properties`
  
* Share Web App
  * `volumes/config/share-config-custom.xml`


## Applying operations

In order to apply any operation, you need to rebuild Docker image before starting the composition again.

```bash
$ docker-compose up -d --no-deps --build alfresco
```
You can rebuild any of he single container while the stack is running 
(alfresco-repo and db will make alfresco share to give a maintenance mode message while the container are restarting)

You can check the logs with this command

```
$ docker-compose logs -f alfresco
```


## Reseting initial data

In order to remove working data, you can empty the 3 data persistent folders.

├── data                             
    ├── alf-repo-data                
    ├── els-data                    
    ├── postgres-data              
    └── solr-data                   
    
After this operation all your data will be lost !

## TODO
- Make a cleanup script for the data volumes
- Make a cleanup script for the elastic search indexes to keep only for a certain amount of time (curator)
- Make script to cronjob the bart backup
- Test bart script (verify it backup the volumes/config folder)
- Test the cleanup of the audit log in alfresco database
- Postgres folder permissions (perhaps 999:1000 works or put 1000 user in postgres group...)
- Add New bart version supporting for one file restore with postgresql (as soon as it is released) 
- Logrotate and clean logfiles
- Add check on elk startup for the dashboard data being present in els-data
- Make content-app work on /adf with the latest version
- Add "Edit with microsoft Office" button in content-app
- Make a script for configuration and deployment (volume paths, url, monitoring or not, ldap/kerberos configuration,etc...)
- Port the configuration file in helm charts format
- Thanks the author
