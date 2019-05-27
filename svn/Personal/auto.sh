#!/bin/bash

checkoutDate="20181011"
baseFolder="/data/hub/disk1t/svn/project"
sourceFolder="/data/hub/disk4tb/codePro/${checkoutDate}/"
workspaceFolder="/data/hub/disk1t/workspace/project"
settingFolder="."


function InitBaseFolder()
{
	echo '----------------------------------'
	echo 'InitBaseFolder begin'
    mkdir $baseFolder
    svnadmin create $baseFolder
    cp "${settingFolder}/authz" "${baseFolder}/conf/authz"
    cp "${settingFolder}/passwd" "${baseFolder}/conf/passwd"
    cp "${settingFolder}/svnserve.conf" "${baseFolder}/conf/svnserve.conf"

    svnserve -d -r $baseFolder
	echo 'InitBaseFolder end'
	echo '----------------------------------'

}

function InitProjectStructure()
{
    mkdir $workspaceFolder
    mkdir "${workspaceFolder}/javaServer"
    mkdir "${workspaceFolder}/mobile4.0"
    mkdir "${workspaceFolder}/mobile3.0"
    mkdir "${workspaceFolder}/mobile2.0"
    mkdir "${workspaceFolder}/mobile"
    mkdir "${workspaceFolder}/server"

    svn import $workspaceFolder "file://$baseFolder" -m "InitProjectStructure"

    rm -rf $workspaceFolder
}

function ImportRecord()
{
	echo '----------------------------------'
	echo 'ImportRecord begin'
    svnadmin load $baseFolder --parent-dir javaServer < "${sourceFolder}javaServer_${checkoutDate}"
    svnadmin load $baseFolder --parent-dir mobile4.0 < "${sourceFolder}mobile4_${checkoutDate}"
    svnadmin load $baseFolder --parent-dir mobile3.0 < "${sourceFolder}mobile3_${checkoutDate}"
    svnadmin load $baseFolder --parent-dir mobile2.0 < "${sourceFolder}mobile2_${checkoutDate}"
    svnadmin load $baseFolder --parent-dir mobile < "${sourceFolder}mobile_${checkoutDate}"
    svnadmin load $baseFolder --parent-dir server < "${sourceFolder}server_${checkoutDate}"
	echo 'ImportRecord end'
	echo '----------------------------------'


}

function ImportRecord_old()
{
    svnadmin load $baseFolder --parent-dir mobile4.0 < /data/hub/disk4tb/codePro/20181011/mobile4_20181011
    svnadmin load $baseFolder --parent-dir mobile3.0 < /data/hub/disk4tb/codePro/20181011/mobile3_20181011
    svnadmin load $baseFolder --parent-dir mobile2.0 < /data/hub/disk4tb/codePro/20181011/mobile2_20181011
    svnadmin load $baseFolder --parent-dir mobile < /data/hub/disk4tb/codePro/20181011/mobile_20181011
    svnadmin load $baseFolder --parent-dir server < /data/hub/disk4tb/codePro/20181011/server_20181011
    svnadmin load $baseFolder --parent-dir javaServer < /data/hub/disk4tb/codePro/20181011/javaServer_20181011
}

echo '请选择操作:'
echo "1) InitBaseFolder"
echo "2) ImportRecord"
echo "3) All"
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'
case $num in
	1)
        InitBaseFolder
        InitProjectStructure
        exit
    ;;
    2)
        ImportRecord
        exit
    ;;
    3)
        InitBaseFolder
        InitProjectStructure
        ImportRecord
        exit
    ;;
    q)
		exit
	;;
	*)
		echo '错误的参数'
		exit
	;;
esac
