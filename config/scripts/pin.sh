#!/bin/bash
# ensure script is running as root
[ `whoami` = root ] || exec sudo "$0" "$@"

for (( i=0 ; i<20 ; i+=1 )); do
	pid=`pgrep windows10vm`
	if [ "x$pid" = x ]; then
		>&2 date
		sleep 1
	else
		break
	fi
done
if [ "x$pid" = x ]; then
	>&2 echo failed to pin!
	exit 1
else
	>&2 echo pinning for $pid...
fi

for i in `ls /proc/$pid/task`; do
	if [ -f "/proc/$i/comm" ]; then
		printf '%s,%d\n' "`cat /proc/$i/comm`" "$i"
	fi
done|gawk -f /home/ddgadmin/config/list.awk /dev/stdin|source /dev/stdin

