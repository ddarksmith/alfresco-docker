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
$ useradd -u 999 -g 999 postgres
$ chown postgres:postgres /volumes/data/postgres-data

```

The elasticsearch folder need to be own by elasticsearch user with the uid 991 on your host
```
$ useradd -u 991 elasticsearch
$ chown postgres /volumes/data/postgres-data

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

* Alfresco Repository    - https://alfresco.companyname.com/alfresco
* Alfresco Share Web App - https://alfresco.companyname.com/share
* Alfresco ADF Web App   - https://alfresco.companyname.com/adf
* SOLR Indexer           - https://alfresco.companyname.com/solr
* Swagger REST API Doc   - https://alfresco.companyname.com/api-explorer
* NAGIOS Monitoring      - https://alfresco.companyname.com/nagios
* ELK Monitoring         - http://alfresco.companyname.com:5601
* Postgresql             - Exposed on port 5432
* Bart                   

## Operations

Following operations are available to customize your Docker Composition.

**Deploying modules**

Copy your artifacts (AMP or JAR) to deployment folders:

* Alfresco Repository
  * `alfresco/assets/amps`
  * `alfresco/assets/jars`

* Share Web App
  * `share/assets/amps_share`
  * `share/assets/jars`


**Configuration**

Modify configuration files:

* Alfresco Repository
  * `volumes/config/alfresco-global.properties`

* Share Web App
  * `volumes/config/share-config-custom.xml`


**ADF**

You must add a configuration parameter `--base-href` in your local `package.json` in order to produce an ADF application able to attend `/adf` context path

```
"build": "npm run server-versions && ng build --prod --base-href /adf/",
```

Copy your generated application replacing the content of `adf/assets/app` folder.


## Applying operations

Docker Compose shall be stopped before applying changes.

```bash
$ docker-compose down
```

In order to apply any operation, you need to rebuild Docker image before starting the composition again.

```bash
$ docker-compose build alfresco
$ docker-compose build share
$ docker-compose build adf
```

Once the image has been rebuilt, Docker Compose can be started again.

```
$ docker-compose start
```

You can check the logs with this command

```
$ docker-compose logs -f
```


## Reseting initial data

In order to remove working data, you can empty the 3 data persistent folders.

volumes
└── data
    ├── alf-repo-data
    ├── postgres-data
    └── solr-data

After this operation all the changes in your data will be lost!

Many thanks to
- Angel Borroy      - The bases of this alfresco docker
- Cesar Capillas    - NAGIOS Monitoring
- Miguel Rodriguez  - Alfresco ELK Monitoring
- Toni de la Fuente - Alfresco BART
- All the plugins developers
- The OOTB
- The whole alfresco team for their job
