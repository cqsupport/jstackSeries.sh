## Usage : jstackSeries.ps1 <pid> <num_threads> <time_between_threads_seconds>
$AEM_PID = $args[0]
$NUMTHREADS = $args[1]
$SLEEP_TIME_SEC = $args[2]
# $script:jstackbin = "C:\Program Files\Java\jdk1.8.0_111\bin\jstack.exe"

if (Test-Path variable:script:jstackbin -ErrorAction SilentlyContinue) {
    #do nothing accept value of script:jstackbin
} elseif (Get-Command "jstack" -ErrorAction SilentlyContinue) {
    # jstack binary is on the path
    $script:jstackbin = "jstack"
} elseif (Test-Path variable:env:JAVA_HOME -ErrorAction SilentlyContinue) {
    # jstack binary is under $JAVA_HOME/bin folder
    $script:jstackbin = Join-Path -Path $env:JAVA_HOME -ChildPath "bin\jstack"
} else {
    Write-Host "jstack command not available.  Set '`$script:jstackbin' variable to the full path of the jstack binary or add the JDK bin folder to the Windows Path variable."
    Exit
}

Write-Host "jstack: " $script:jstackbin

Write-Host "Java PID:" $AEM_PID;
Write-Host "Number of thread dumps to capture:" $NUMTHREADS;

for ($i = 1; $i -le $NUMTHREADS; $i++) {
	$time = Get-Date (Get-Date).ToUniversalTime() -UFormat %s
	$ProcessThreads = (Get-Process -Id $AEM_PID).Threads
	$ThreadsWithCPUTime = $ProcessThreads | Where-Object { $_.TotalProcessorTime.Ticks -ne 0 }

	Foreach ($ProcessThread in $ThreadsWithCPUTime) {

		# Mapping the possible values of WaitReason to their actual meaning
		# source: https://msdn.microsoft.com/en-us/library/tkhtkxxy(v=vs.110).aspx
		Switch ($ProcessThread.WaitReason) {

			EventPairHigh { $Wait_ReasonPropertyValue =
			'Waiting for event pair high.Event pairs are used to communicate with protected subsystems'; break }
			
			EventPairLow { $Wait_ReasonPropertyValue =
			'Waiting for event pair low. Event pairs are used to communicate with protected subsystems'; break }
			
			ExecutionDelay { $Wait_ReasonPropertyValue =
			'Thread execution is delayed'; break }
			
			Executive { $Wait_ReasonPropertyValue =
			'The thread is waiting for the scheduler'; break }
			
			FreePage { $Wait_ReasonPropertyValue =
			'Waiting for a free virtual memory page'; break }
			
			LpcReceive { $Wait_ReasonPropertyValue =
			'Waiting for a local procedure call to arrive'; break }
			
			LpcReply { $Wait_ReasonPropertyValue =
			'Waiting for reply to a local procedure call to arrive'; break }
			
			PageIn { $Wait_ReasonPropertyValue =
			'Waiting for a virtual memory page to arrive in memory'; break }
			
			PageOut { $Wait_ReasonPropertyValue =
			'Waiting for a virtual memory page to be written to disk'; break }
			
			Suspended { $Wait_ReasonPropertyValue =
			'Thread execution is suspended'; break }
			
			SystemAllocation { $Wait_ReasonPropertyValue =
			'Waiting for a memory allocation for its stack'; break }
			
			Unknown { $Wait_ReasonPropertyValue =
			'Waiting for an unknown reason'; break }
			
			UserRequest { $Wait_ReasonPropertyValue =
			'The thread is waiting for a user request'; break }
			
			VirtualMemory { $Wait_ReasonPropertyValue =
			'Waiting for the system to allocate virtual memory'; break }
			
			Default { $Wait_ReasonPropertyValue = ''; break }
		} 

		# Building custom properties for my threads objects
		$Properties = @{
			ThreadID = $ProcessThread.Id
			'nid in jstack output' = '{0:x}' -f $ProcessThread.Id
			StartTime = $ProcessThread.StartTime
			'CPUTime (Sec)' = [math]::round($ProcessThread.TotalProcessorTime.TotalSeconds,2)
			'User CPUTime (%)' = [math]::round((($ProcessThread.UserProcessorTime.ticks / $ProcessThread.TotalProcessorTime.ticks)*100),1)
			'System CPUTime (%)' = [math]::round((($ProcessThread.privilegedProcessorTime.ticks / $ProcessThread.TotalProcessorTime.ticks)*100),1)
			State = $ProcessThread.ThreadState
			'Wait Reason' = $Wait_ReasonPropertyValue
		} 
		$CustomObj = New-Object -TypeName PSObject -Property $Properties
		$CustomObj | Out-File -append -filepath .\top.$AEM_PID.$i.$time
		#Write-Host $CustomObj
	}	
	
	$jstackcommand = "& `"$script:jstackbin`" -l $AEM_PID | Out-File -append -Encoding ascii -filepath .\jstack.$AEM_PID.$i.$time"
    Invoke-Expression $jstackcommand

	Write-Host "thread dump : " $i " complete, sleep for " $SLEEP_TIME_SEC " seconds...";
	Start-Sleep -s $SLEEP_TIME_SEC

}

Write-Host "done";

# How to diagnose. A systematic approach
#
# CPUTime \(Sec\)        : ([0-9]{2,}\.[0-9]{1,}) 
# CPUTime \(Sec\)        : ([0-9]{3,}\.[0-9]{1,})
#
#
#
#
# $ProcessThread.TotalProcessorTime
# A TimeSpan that indicates the amount of time that the associated process has spent utilizing the CPU. This value is the sum of the UserProcessorTime and the PrivilegedProcessorTime.
#
# $ProcessThread.UserProcessorTime
# A TimeSpan that indicates the amount of time that the associated process has spent running code inside the application portion of the process (not inside the operating system core).
#
# $ProcessThread.privilegedProcessorTime
# A TimeSpan that indicates the amount of time that the process has spent running code inside the operating system core.
