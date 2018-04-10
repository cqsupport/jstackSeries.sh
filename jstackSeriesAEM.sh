#!/bin/bash
# Adaptation of script from eclipse.org http://wiki.eclipse.org/How_to_report_a_deadlock#jstackSeries_--_jstack_sampling_in_fixed_time_intervals_.28tested_on_Linux.29
# Define these two variables
JAVA_HOME=/usr/java/jdk1.8.0_102
AEM_HOME=/mnt/crx/author

JAVA_HOME=${JAVA_HOME:+${JAVA_HOME%/}/}
JAVA_BIN=${JAVA_HOME}bin/
AEM_HOME=${AEM_HOME:+${AEM_HOME%/}/}
AEM_JAR=$(ls -1 $AEM_HOME | grep -E "(author|publish|cq|aem).*\.jar$" | grep -v -E "oak|crx" | head -1)

# Retrieve pid from the cq.pid file
if [ -e "${AEM_HOME}crx-quickstart/conf/cq.pid" ]; then
  pid=$(cat ${AEM_HOME}crx-quickstart/conf/cq.pid)
else
  # If cq.pid file doesn't exist then fail over to grepping for process that has jar file name
  pid=$(ps aux | grep $AEM_JAR | grep -v grep | awk '{print $2}' | head -1)
fi


if [ -z "$pid" ]; then
   echo >&2 "Error: Missing PID"
   echo >&2 "Usage: jstackSeriesAEM.sh [ <count> [ <delay> ] ]"
   echo >&2 "    Defaults: count = 10, delay = 1 (seconds)"
   exit 1
fi


count=${2:-10}  # defaults to 10 times
delay=${3:-1} # defaults to 1 second
echo "Running with params - PID: $pid, Count: $count, Delay: $delay"
DUMP_DIR=${AEM_HOME}crx-quickstart/logs/threaddumps/$pid.$(date +%s.%N)
mkdir -p $DUMP_DIR
echo "Generating files under ${DUMP_DIR}"
DUMP_DIR=${DUMP_DIR:+${DUMP_DIR%/}/}
while [ $count -gt 0 ]
do
    ${JAVA_BIN}jstack $pid > ${DUMP_DIR}jstack.$pid.$(date +%s.%N)
    top -H -b -n1 -p $pid > ${DUMP_DIR}top.$pid.$(date +%s.%N)
    sleep $delay
    let count--
    echo -n "."
done
echo "."
