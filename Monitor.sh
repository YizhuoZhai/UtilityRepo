#!/bin/bash

#time of the process: 30min
TIMEOUT=1800
#maximum memory: 90G
MEMEXC=92160
ABS="dir/for/log"
RUN="R"

while true
    do
        for file in `ls /proc/`
            do
                if [ -f /proc/$file/comm ]
                    then
                        #Check the command is klee/other program name
                        cmd=`awk '{ print $1; }' /proc/${file}/comm`
                        if [ $cmd == "klee" ]
                            then
                                #echo "file : $file, cmd: $cmd" 
                                #get the memory use, if the use > MEMEXC, print the command with arg, get pid and kill it<F3>
                                pid=`awk '$1=="Pid:" { print $2 }' /proc/${file}/status`
                                mem=`awk '$1=="VmRSS:" { print $2 }' /proc/${file}/status`
                                state=`awk '$1=="State:" { print $2 }' /proc/${file}/status`
                                #echo "state: $state"
                                if [ $state = $RUN ]
                                  then

                                    #echo "pid: $file; mem: $mem"
                                    if [ $mem -gt $MEMEXC ]
                                        then
                                        cat /proc/${file}/cmdline >>$ABS/mem.txt
                                        echo -e "\n">>$ABS/mem.txt
                                        #echo "kill $pid"
                                        kill -SIGTERM $pid
                                        sleep 3s
                                        if [ -f /proc/$file/comm ]
                                        then
                                            kill -SIGQUIT $pid
                                            kill -SIGKILL $pid
                                        fi
                                        continue
                                    fi
                                    #getTime()
                                    user_hz=$(getconf CLK_TCK) #mostly it's 100 on x86/x86_64
                                    jiffies=$(cat /proc/$file/stat | cut -d" " -f22)
                                    sys_uptime=$(cat /proc/uptime | cut -d" " -f1)
                                    time=$(( ${sys_uptime%.*} - $jiffies/$user_hz ))

                                    #echo "the process $pid lasts for $time seconds."
                                    #echo "the process $pid lasts for $time seconds."

                                    if [ $time -gt $TIMEOUT ]
                                        then
                                        cat /proc/${file}/cmdline >>$ABS/timeout.txt
                                        echo -e "\n">>$ABS/timeout.txt
                                        #echo "kill $file"
                                        kill -SIGTERM $pid
                                        sleep 3s
                                        if [ -f /proc/$file/comm ]
                                        then
                                            kill -SIGQUIT $pid
                                            kill -SIGKILL $pid
                                        fi

                                    fi
                                fi
                        fi
                fi
        done
    done
