#!/bin/bash

aria2pid=$(pgrep 'aria2c')
aria2Folder="/etc/aria2/"

#aria2c="sudo -u tv /usr/local/bin/aria2c"
aria2c="sudo -u bopy aria2c"


ARIA2C_CONF_FILE="${aria2Folder}aria2.conf" 
options=" --conf-path=$ARIA2C_CONF_FILE -D " 

case $1 in
	'start')
		${aria2c} ${options} 
		exit
	;;
	'stop')
		kill -9 ${aria2pid}
	;;
	'restart')
		kill -9 ${aria2pid}
		${aria2c} ${options}
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