# jstackSeries.sh
jstack script for capturing a series of thread dumps.

Just run it like this:
sh jstackSeries.sh *pid* *count* *delay*

For example:
`sudo -u javauser sh jstackSeries.sh 1234 10 3`

- 1234 is the pid of the Java process
- 10 is how many thread dumps to take
- 3 is the delay between each dump

Note: 
* The script must run as the user that owns the java process.
* The top output has the native thread id in decimal format while the jstack output has the "nid" in hexadecimal.  You can match the thread id (PID) from the top output to the jstack output by converting the thread id to hexadecimal.
