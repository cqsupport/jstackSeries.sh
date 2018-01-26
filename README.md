# jstackSeries.sh
jstack script for capturing a series of thread dumps.

Just run it like this:
sh jstackSeries.sh *pid* *cq5serveruser* *count* *delay*

For example:
`sh jstackSeries.sh 1234 cq5serveruser 10 3`

- 1234 is the pid of the Java process
- cq5serveruser is the Linux or UNIX user that the Java process runs as
- 10 is how many thread dumps to take
- 3 is the delay between each dump

Note: The top output has the native thread id in decimal format while the jstack output has the nid in hexadecimal.  You can match the high cpu thread from the top output to the jstack output by converting the thread id to hexadecimal.
