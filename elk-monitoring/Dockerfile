FROM sebp/elk:530

## Set Timezone
#sudo timedatectl set-timezone Europe/Zurich

# Increase vm
RUN echo "vm.max_map_count=262144" >> /etc/sysctl.conf
RUN sysctl -p

# Update apt
RUN apt-get update
RUN apt-get install wget

# Install elasticsearch curator
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb [arch=amd64] https://packages.elastic.co/curator/5/debian stable main" >> /etc/apt/sources.list.d/curator.list
RUN apt-get update
RUN apt-get install -y elasticsearch-curator

# Clean apt
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* 

# Install activities files
RUN mkdir /opt/activities
RUN mkdir -p /data/logs/activities
ADD assets/SQLTool.jar /opt/activities
ADD assets/activities.properties /opt/activities

# Install activities files
RUN mkdir -p /opt/workflows/logs
RUN mkdir -p /data/logs/workflows
ADD assets/SQLTool.jar /opt/workflows
ADD assets/workflows.properties /opt/workflows

RUN chown -R logstash:logstash /opt/activities
RUN chown -R logstash:logstash /opt/workflows
RUN chown -R logstash /data

RUN sed -i 's/network.host/#network.host/' /etc/elasticsearch/elasticsearch.yml
RUN echo "path.data: /var/lib/alf-elasticsearch" >> /etc/elasticsearch/elasticsearch.yml

ADD assets/nodes.tar.gz /tmp
RUN /etc/init.d/elasticsearch stop
RUN mkdir -p /var/lib/alf-elasticsearch/
RUN chown -R elasticsearch /var/lib/alf-elasticsearch
RUN sed -i 's/DATA_DIR=\/var\/lib\/\$NAME/DATA_DIR=\/var\/lib\/alf-elasticsearch/' /etc/init.d/elasticsearch
RUN /etc/init.d/elasticsearch start
RUN /etc/init.d/elasticsearch stop
RUN rm -rf /var/lib/alf-elasticsearch/*
RUN cp -pr /tmp/nodes /var/lib/alf-elasticsearch
RUN chown -R elasticsearch /var/lib/alf-elasticsearch
RUN /etc/init.d/elasticsearch start
RUN /etc/init.d/elasticsearch stop

ENTRYPOINT /usr/local/bin/start.sh

