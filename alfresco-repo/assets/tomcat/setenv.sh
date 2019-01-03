#!/bin/bash
#
JAVA_OPTS="-Djava.library.path=/usr/lib/jni" 
JAVA_OPTS="$JAVA_OPTS -Dalfresco.home=/usr/local/alfresco" 
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
JAVA_OPTS="$JAVA_OPTS -XX:ReservedCodeCacheSize=128m"
JAVA_OPTS="$JAVA_OPTS -Xms2048M -Xmx4096M" # java-memory-settings
JAVA_OPTS="$JAVA_OPTS -Djava.security.krb5.conf=/etc/krb5.conf"
export JAVA_OPTS
			    
