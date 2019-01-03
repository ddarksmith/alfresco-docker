#!/bin/bash
# Starting ELK agent
cd /usr/local/alfresco/elk-agent
/usr/local/alfresco/elk-agent/run_agent.sh start &

# Starting Alfresco
cd /usr/local/tomcat/bin
/usr/local/tomcat/bin/catalina.sh jpda run

# Tailing logfile
tail -f /usr/local/tomcat/logs/alfresco.log &
