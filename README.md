# jstackSeries.sh
jstack script for capturing a series of thread dumps.

Just run it like this:
sudo -u *aem-process-user-id* sh jstackSeries.sh *pid* *count* *delay*

For example:
`sudo -u javauser sh jstackSeries.sh 1234 10 3`
- javauser is the user that owns the java process
- 1234 is the pid of the Java process
- 10 is how many thread dumps to take
- 3 is the delay between each dump

Note: 
* The script must run as the user that owns the java process.
* The top output has the native thread id in decimal format while the jstack output has the "nid" in hexadecimal.  You can match the thread id (PID) from the top output to the jstack output by converting the thread id to hexadecimal.

# jstackSeriesAEM.sh
Make these modifications to the script:
* Update the JAVA_HOME variable to point to the path of where java is installed.
* Update the AEM_HOME variable to point to the path of where AEM is installed.

Just run it like this:
sudo -u *aem-process-user-id* sh jstackSeriesAEM.sh *count* *delay*

For example:
`sudo -u aemuser sh jstackSeriesAEM.sh 10 3`
- aemuser is the user that owns the java process that runs AEM
- 10 is how many thread dumps to take
- 3 is the delay between each dump

Note:
* The script will automatically try to get the AEM process' PID.  It will first look for ${AEM_HOME}/crx-quickstart/conf/cq.pid, if that file is non-existent or empty it would fail over to "ps -aux | grep $AEM_JAR" where variable $AEM_JAR is the name of the jar file.  If it fails with both of those it would report an error.
* Thread dumps and top output would automatically be generated under crx-quickstart/logs/threaddumps in a subfolder with the PID and a timestamp in the name.
