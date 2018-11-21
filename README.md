# Docker Composition for Alfresco CE 201707-GA

Sample Docker Composition for integration testing with Alfresco 5.2

**Docker** & **Docker Compose** software is required to use this project.
You should review volumes, configuration, modules & tuning parameters before using this composition in **Production** environments.

## Starting

Download or clone this repository.

Create the volumes structure

```

```

Give the persistent volumes permissions

```
$ mkdir -p /volumes/config /volumes/data/alf-repo-data /volumes/data/postgres-data /volumes/data/solr-data /volumes/logs/alfresco /volumes/logs/postgres /volumes/logs/share
$ chown 1000:1000 -R /volumes
$ chmod -R 664 /volumes
```

The postgres-data folder need to be own by a postgres user with the uid 999 on your host

```
$ useradd -u 999 -g 999 postgres
$ chown postgres:postgres /volumes/data/postgres-data

```

Copy config to persistent volume

```
$ cp -R ./config/* /volumes/config/
```

If you have ssl certificate for your company put it in /volumes/config/ssl and configure nginx-ssl.conf with it's correct name in those lines

```
 ssl_certificate     /etc/nginx/conf.d/ssl/alfresco.crt;
 ssl_certificate_key /etc/nginx/conf.d/ssl/alfresco.key;
```

If you prefer to generate a self-signed one executer the sslcreate.sh script and follow the instructions



From root directory, start Docker Compose.

```
$ docker-compose up
```

Once all the containers have been started, a message similar to following one will appear.

```
alfresco_1     | May 15, 2018 11:03:22 AM org.apache.catalina.startup.Catalina start
alfresco_1     | INFO: Server startup in 70314 ms
```

## Volumes

A directory named `volumes` is located in the root folder to store configuration, data and log files.

```bash
$ tree volumes
volumes
├── config
│   ├── SSL
│   │   └──createssl.sh 
│   ├── alfresco-global.properties
│   ├── share-config-custom.xml
├── data
│   ├── alf-repo-data
│   ├── postgres-data
│   └── solr-data
└── logs
    ├── alfresco
    ├── postgres
    └── share
```


Persistent data folders path can be changed by modifying local paths set in `volumes` directives at `docker-compose.yml` to global paths


## Available services

Once the composition is up, you can check available services:

* Alfresco Repository - http://localhost/alfresco
* Alfresco Share Web App - http://localhost/share
* Alfresco ADF Web App - http://localhost/adf
* SOLR Indexer - http://localhost/solr
* Swagger REST API Doc - http://localhost/api-explorer
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

