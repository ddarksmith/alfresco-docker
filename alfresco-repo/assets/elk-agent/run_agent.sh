# Set the following variables before starting the script
export tomcatLogs=/usr/local/tomcat/logs
export logstashAgentDir=/usr/local/alfresco/elk-agent
export logstashAgentLogs=${logstashAgentDir}/logs
export alfrescoELKServer=elk
collectAuditData="yes"

if [ -z "$logstashAgentDir" ]; then
  echo "Please set logstashAgentDir variable to the path of your logstash-agent folder"
  echo "i.e. export logstashAgentDir=<path>/logstash-agent"
  exit
fi

now=`date +"%Y-%m-%d-%T"`

if [ "$1" = "start" ] ; then
  echo "Starting jstatbeat"
  host=`grep "host =>" logstash.conf | grep -v "#" | awk -F "\"" '{print $2}'`
  sed -i -e 's/hosts: \[.*/hosts: \["'${host}':5044"\]/g' jstatbeat.yml
  sed -i -e "s@    path: .*@    path: ${logstashAgentLogs}@g" jstatbeat.yml
  LANG=POSIX nohup ./jstatbeat -c jstatbeat.yml > /dev/null 2>&1 &
  echo "Starting dstat"
  nohup dstat -tam --output ${logstashAgentLogs}/dstat-${now}.log 5 > /dev/null 2>&1 &
  if [ "${collectAuditData}" = "yes" ] ; then
    echo "Starting audit access script"
    sed -i -e "s@auditRoot=.*@auditRoot=${logstashAgentLogs}@g" audit-access.sh
    nohup ${logstashAgentDir}/audit-access.sh &>${logstashAgentLogs}/audit-access.log &
  fi
elif [ "$1" = "stop" ] ; then
  echo "Stopping jstatbeat"
  ps -ef | grep "jstatbeat" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
  echo "Stopping dstat"
  ps -ef | grep "dstat" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
  if [ "${collectAuditData}" = "yes" ] ; then
    echo "Stopping audit access script"
    ps -ef | grep "${logstashAgentDir}/audit-access.sh" | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
  fi
else
  echo "Use run_agent.sh <start|stop>"
fi
