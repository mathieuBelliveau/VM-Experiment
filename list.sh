#!/bin/bash
# ensure script is running as root
[ `whoami` = root ] || exec sudo "$0" "$@"

if [ ! `whoami` = root ]; then
	echo 'what?!'
	exit
fi

for (( i=0 ; i<20 ; i+=1 )); do
	pid=`pgrep windows10vm`
	if [ "x$pid" = x ]; then
		&>2 date
		sleep 1
	else
		break
	fi
done
if [ "x$pid" = x ]; then &>2 echo failed to pin!; exit 1; fi

for i in `ls /proc/$pid/task`; do
	printf '%s,%d\n' "`cat /proc/$i/comm`" "$i"
done|gawk -f list.awk /dev/stdin

