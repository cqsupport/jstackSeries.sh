#!/bin/bash
# Adaptation of script from eclipse.org http://wiki.eclipse.org/How_to_report_a_deadlock#jstackSeries_--_jstack_sampling_in_fixed_time_intervals_.28tested_on_Linux.29
export JAVA_HOME=/usr/java/jdk1.8.0_121/bin/
export AEM_HOME=/opt/aem/publish62

pid=${1:-$(cat $AEM_HOME/crx-quickstart/conf/cq.pid)} # required
if [ -z "$pid" ]; then
   echo >&2 "Error: Missing PID"
   echo >&2 "Usage: jstackSeriesAEM.sh <pid> [ <count> [ <delay> ] ]"
   echo >&2 "    Defaults: pid=$(cat $AEM_HOME/crx-quickstart/conf/cq.pid), count = 10, delay = 1 (seconds)"
   exit 1
fi
count=${2:-10}  # defaults to 10 times
delay=${3:-1} # defaults to 1 second
echo "Running with params - PID: $pid, Count: $count, Delay: $delay"
while [ $count -gt 0 ]
do
    ${JAVA_HOME}jstack $pid >jstack.$pid.$(date +%s.%N)
    top -H -b -n1 -p $pid >top.$pid.$(date +%s.%N)
    sleep $delay
    let count--
    echo -n "."
done
