FROM keensoft/alfresco-docker-template:201707-GA
MAINTAINER keensoft.es

RUN set -x \
	&& yum install -y \
	ImageMagick \
	dstat \
        java-1.8.0-openjdk-devel \
        postgresql \
        krb5-workstation \
	&& yum clean all

ENV ALF_HOME /usr/local/alfresco
ENV CATALINA_HOME /usr/local/alfresco/tomcat
WORKDIR $ALF_HOME

# basic configuration
RUN set -x \
        && ln -s /usr/local/tomcat /usr/local/alfresco/tomcat \
	&& mkdir -p $CATALINA_HOME/conf/Catalina/localhost $CATALINA_HOME/shared/classes/alfresco/extension $CATALINA_HOME/shared/lib $ALF_HOME/modules/platform \
	&& mv $DIST/web-server/conf/Catalina/localhost/alfresco.xml tomcat/conf/Catalina/localhost/ \
        && mv $DIST/web-server/lib/*.jar tomcat/lib/ \
        && mv $DIST/web-server/webapps/alfresco.war tomcat/webapps/ \
        && mv $DIST/alf_data . \
        && mv $DIST/amps . \
        && mv $DIST/bin . \
        && mv $DIST/licenses . \
        && mv $DIST/README.txt . \
        && rm -rf $CATALINA_HOME/webapps/docs \
        && rm -rf $CATALINA_HOME/webapps/examples \
        && rm -rf $DIST 

COPY assets/tomcat/catalina.properties tomcat/conf/catalina.properties
COPY assets/tomcat/setenv.sh tomcat/bin/setenv.sh
COPY assets/alfresco/alfresco-global.properties tomcat/shared/classes/alfresco-global.properties

COPY assets/tomcat/server.xml tomcat/conf/server.xml
COPY assets/tomcat/alfresco.xml tomcat/conf/Catalina/localhost/
COPY assets/tomcat/lib/postgresql-42.2.5.jar tomcat/lib/
COPY assets/tomcat/lib/p6spy-3.6.0.jar tomcat/lib/
COPY assets/tomcat/lib/spy.properties tomcat/lib/
COPY assets/tomcat/endorsed/alf-21970-repo-1.0.0.jar tomcat/endorsed/
COPY assets/tomcat/webapps/_vti_bin.war tomcat/webapps/

# agent for ELK monitoring
COPY assets/elk-agent $ALF_HOME/elk-agent/

# alfresco-pdf-renderer 
RUN set -x \
	&& mkdir /usr/local/alfresco/alfresco-pdf-renderer \
	&& wget https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-pdf-renderer/1.0/alfresco-pdf-renderer-1.0-linux.tgz \
	&& tar xzvf alfresco-pdf-renderer-1.0-linux.tgz -C /usr/local/alfresco/alfresco-pdf-renderer \
	&& rm -f alfresco-pdf-renderer-1.0-linux.tgz 

# Kerberos configuration
ENV JAVA_HOME=/usr/lib/jvm/jre
ARG JRE_HOME=${JAVA_HOME}
COPY assets/kerberos/krb5.conf /etc/krb5.conf
COPY assets/kerberos/java.login.config $JRE_HOME/lib/security/java.login.config
COPY assets/kerberos/java.security $JRE_HOME/lib/security/java.security
COPY assets/kerberos/UnlimitedJCEPolicyJDK8/local_policy.jar $JRE_HOME/lib/security/local_policy.jar
COPY assets/kerberos/UnlimitedJCEPolicyJDK8/US_export_policy.jar $JRE_HOME/lib/security/US_export_policy.jar

# AMPS installation
COPY assets/alfresco/apply_alfresco_amps.sh $ALF_HOME/bin/apply_amps.sh
COPY assets/amps amps
RUN bash ./bin/apply_amps.sh -nobackup

# Add api-explorer WAR file
RUN set -x \
	&& wget https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/api-explorer/5.2.0/api-explorer-5.2.0.war -O tomcat/webapps/api-explorer.war

# JARS installation
COPY assets/jars/ $ALF_HOME/modules/platform

ENV PATH $ALF_HOME/bin:$PATH
ENV LANG fr_CH.utf8

COPY assets/start.sh /
COPY assets/wait-for-postgres.sh wait-for-postgres.sh
RUN set -x && chmod +x wait-for-postgres.sh

RUN useradd -ms /bin/bash alfresco
RUN set -x && chown -RL alfresco:alfresco $ALF_HOME
USER alfresco

RUN set -x \
        && echo "db:5432:alfresco:alfresco:alfresco" > /home/alfresco/.pgpass \
        && chmod 0600 /home/alfresco/.pgpass \
        && chown alfresco:alfresco /home/alfresco/.pgpass

ENV JPDA_ADDRESS="9999"
ENV JPDA_TRANSPORT="dt_socket"

# test if alfresco server alive and responsive
HEALTHCHECK --interval=1m --timeout=5s \
  CMD curl -f http://localhost:8080/alfresco || exit 1

EXPOSE 8080 8009 9999
VOLUME $ALF_HOME/alf_data
#CMD ["./wait-for-postgres.sh", "db", "catalina.sh", "jpda", "run"]

ENTRYPOINT ["/start.sh"]

