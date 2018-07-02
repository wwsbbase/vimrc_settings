#!/bin/bash

aria2pid=$(pgrep 'aria2c')

case $1 in
	'start')
		nohup aria2c --conf-path=/data/aria2/aria2.conf > /data/aria2/aria2.log 2>&1 &
		exit
	;;
	'stop')
		kill -9 ${aria2pid}
	;;
	'restart')
		kill -9 ${aria2pid}
		nohup aria2c --conf-path=/data/aria2/aria2.conf > /data/aria2/aria2.log 2>&1 &
		exit;
	;;
	'status')
		if [ "$aria2pid" == "" ]
			then
				echo "Not running!"
			else
				echo "Is running,pid is ${aria2pid}"
		fi
	;;
	*)
		echo '参数错误！'
		exit
	;;
esac