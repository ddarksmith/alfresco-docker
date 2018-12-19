FROM ubuntu:xenial
LABEL maintainer "frederic.zeller@arcentis.ch"
LABEL version "1.0"
LABEL description "This is libreoffice container for alfresco" 

ENV DEBIAN_FRONTEND noninteractive

RUN set -x \
	&& apt-get update \
	&& apt-get -y -q install \
		hyphen-* \
		libreoffice \
		libreoffice-writer \
		libreoffice-java-common \ 
		libreoffice-core \ 
		libreoffice-common \ 
		openjdk-8-jre \
		ure \
		net-tools \
	&& apt-get -q -y remove libreoffice-gnome\
	&& apt-get clean


RUN set -x \
	&& adduser --home=/opt/libreoffice --disabled-password --gecos "" --shell=/bin/bash libreoffice

ADD sofficerc /etc/libreoffice/sofficerc
ADD startoo.sh /opt/libreoffice/startoo.sh
ADD libreoffice.sh /opt/libreoffice/libreoffice.sh
RUN set -x \
	&& chmod +x /opt/libreoffice/startoo.sh \
	&& chmod +x /opt/libreoffice/libreoffice.sh
VOLUME ["/tmp"]
EXPOSE 8100
ENTRYPOINT ["/opt/libreoffice/startoo.sh"]
