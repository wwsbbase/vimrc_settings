#!/bin/bash
#####		一键初始化CentOS7		 #####
#####		Update:2020-6-24		#####

system_hostname="defaut_hostname"
system_ssh_port=177

root_name="root"
common_user_name="defaut_user"
common_user_passwd="defaut_passwd"
common_user_id="20000"
common_group_name="defaut_group"

#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
#法国（蓝白红）
common_user_color="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;30m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""
root_color="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;37m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""

package_folder="/download"
yes_name="yes"

###
# OS_SystemSetting
###
function OS_SystemSetting()
{
	echo '----------------------------------'
	echo 'OS_SystemSetting begin'
	########## Base Setting ###########
	# SetHostname
	########## Advance  Setting ###########

	# ChangeIntelP_state
	SetMaxOpenFiles
	SetHistory

	# 安装字符集
	# locale-gen en_US.UTF-8
	echo 'OS_SystemSetting end'
	echo '----------------------------------'
}

function InputHostName()
{
	echo '-----------------------------'
	echo '请输入HostName:'
	echo '-----------------------------'
	read -p ":" system_hostname
	echo '-----------------------------'
	echo '输入的HostName:'
	echo '-----------------------------'
	echo ${system_hostname}
}

###
# Set host name
###
function SetHostname()
{
	InputHostName

	hostnamectl set-hostname $system_hostname
	echo "127.0.1.1   ${system_hostname}" >> /etc/hosts
}

###
# Change Intel P-state
###
function ChangeIntelP_state()
{
	sed -i '/GRUB_CMDLINE_LINUX/{s/"$//g;s/$/ intel_pstate=disable intel_idle.max_cstate=0 processor.max_cstate=1 idle=poll"/}' /etc/default/grub
}

###
# Max open files
###
function SetMaxOpenFiles()
{
	found=`grep -c "^* soft nproc" /etc/security/limits.conf`
	if ! [ $found -gt "0" ]
	then
cat >> /etc/security/limits.conf << EOF
* soft nproc 2048
* hard nproc 16384
* soft nofile 8192
* hard nofile 65536
EOF
	fi
}

###
# Command History
###
function SetHistory()
{
	found=`grep -c HISTTIMEFORMAT /etc/profile`
	if ! [ $found -gt "0" ]
	then
	echo "export HISTSIZE=2000" >> /etc/profile
	echo "export HISTTIMEFORMAT='%F %T:'" >> /etc/profile
	fi
}



function OS_OptimizePerformance()
{
	CloseSelinxServices
	CloseUnusefulServices
	SysctlConfig
	SetSSHConfig
}

###
# Close selinux services
###
function CloseSelinxServices()
{
	# inittab is no longer used when using systemd.
	#/bin/sed -i 's/mingetty tty/mingetty --noclear tty/' /etc/inittab
	/bin/sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
	/bin/sed -i 's/SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config
}

###
# Close unuseful services
###
function CloseUnusefulServices()
{
	systemctl disable 'postfix'
	systemctl disable 'NetworkManager'
	systemctl disable 'abrt-ccpp'
}


###
# Sysctl config 
###
function SysctlConfig()
{

found=`grep -c net.ipv4.tcp_tw_recycle /etc/sysctl.conf`
if ! [ $found -gt "0" ]
then
cat > /etc/sysctl.conf << EOF
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
fs.file-max = 131072
kernel.panic=1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.core.netdev_max_backlog = 3072
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 720000
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 10
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_syncookies = 1
EOF
fi

sysctl -p
}

###
# ssh config
###
function SetSSHConfig()
{
	/bin/sed -i "s/.*Port[[:space:]].*$/Port ${system_ssh_port}/" /etc/ssh/ssh_config
	/bin/sed -i "s/.*Port[[:space:]].*$/Port ${system_ssh_port}/" /etc/ssh/sshd_config
	/bin/sed -i "s/port=\"22\"/port=\"${system_ssh_port}\"/" /usr/lib/firewalld/services/ssh.xml 
	firewall-cmd --reload
}


function OS_InstallTools()
{
	echo '----------------------------------'
	echo 'InstallTools begin'
	InstallBaseTools
	InstallAdvanceTools
	echo 'InstallTools end'
	echo '----------------------------------'
}

function InstallBaseTools()
{
	echo '----------------------------------'
	echo 'InstallBaseTools begin'
	# install base tools

	yum install -y  epel-release
	yum install -y  htop
	yum install -y  subversion
	yum install -y  git
	yum install -y  wget
	yum install -y  unzip
	yum install -y  screen
	yum install -y  dstat
	yum install -y  curl
	yum install -y  ntpdate
	yum install -y  gdisk
	yum install -y	 net-tools
	echo 'InstallBaseTools end'
	echo '----------------------------------'
}

function InstallAdvanceTools()
{
	echo '----------------------------------'
	echo 'InstallAdvanceTools begin'

	# file system
	yum install -y  xfsprogs

	# python3 
	# yum install -y  python3
	# yum install -y  python3-dev
	# yum install -y  python-pip
	# yum install -y  python3-pip

	echo 'InstallAdvanceTools end'
	echo '----------------------------------'
}

###
# User Settings
###
function OS_UserSettings()
{
	CheckPackageFoder
	InitRoot

	echo '-----------------------------'
	echo '是否添加普通用户:(yes/no)'
	echo '-----------------------------'
	read -p ":" isAddNormalUser

	if [ $isAddNormalUser = $yes_name ]
	then
		AddNormalUser
	fi
}

function CheckPackageFoder()
{
	if [ ! -e "${package_folder}" ]
	then
		mkdir ${package_folder}
	fi
}

###
# Init Root
###
function InitRoot()
{
	SetConsoleColor root
	InstallZlua	root
	SetPublicKey root
}

function InputUserInfo()
{
	### 请输入GroupName
	echo '-----------------------------'
	echo '请输入GroupName:'
	echo '-----------------------------'
	read -p ":" common_group_name
	echo '-----------------------------'
	echo '输入的GroupName:'
	echo '-----------------------------'
	echo ${common_group_name}

	### 请输入UserName
	echo '-----------------------------'
	echo '请输入UserName:'
	echo '-----------------------------'
	read -p ":" common_user_name
	echo '-----------------------------'
	echo '输入的UserName:'
	echo '-----------------------------'
	echo ${common_user_name}

	### 请输入UserPasswd
	echo '-----------------------------'
	echo '请输入UserPasswd:'
	echo '-----------------------------'
	read -p ":" common_user_passwd
	echo '-----------------------------'
	echo '输入的UserPasswd:'
	echo '-----------------------------'
	echo ${common_user_passwd}
}

###
# Add Normal User
###
function AddNormalUser()
{
	## add normal user
	InputUserInfo

	groupadd -g ${common_user_id} ${common_group_name}
	useradd  -g ${common_group_name} -u ${common_user_id} -s /bin/bash -c "Common User" -m -d /home/${common_user_name} ${common_user_name}
	echo ${common_user_passwd} | passwd --stdin ${common_user_name}

	## init normal user
	SetConsoleColor ${common_user_name}
	InstallZlua	${common_user_name}

	SetPublicKey ${common_user_name} ${common_group_name}
}

###
# Set Console Color
###
function SetConsoleColor()
{
	# set PS1
	echo $1
	if [ $1 = $root_name ]
	then
		echo $root_color >> /root/.bashrc
	else
		echo $common_user_color >> /home/$1/.bashrc
	fi
}


###
# InstallZlua
###
function InstallZlua()
{
	echo '----------------------------------'
	echo 'InstallZlua begin'

	cd "$package_folder"
	if [ ! -e "${package_folder}/z.lua/" ]
	then
		git clone https://github.com/skywind3000/z.lua.git
	fi
	
	echo $1
	local bashrc_path=""
	if [ $1 = $root_name ]
	then
		bashrc_path="/root/.bashrc"
		# echo "eval \"\$(lua $package_folder/z.lua/z.lua --init bash enhanced once)\"" >> /root/.bashrc
	else
		echo $common_user_color >> /home/$1/.bashrc
		bashrc_path="/home/$1/.bashrc"
		# echo "eval \"\$(lua $package_folder/z.lua/z.lua --init bash enhanced once)\"" >> /home/$1/.bashrc
	fi

	echo "eval \"\$(lua $package_folder/z.lua/z.lua --init bash enhanced once)\"" >> $bashrc_path

	echo 'InstallZlua end'
	echo '----------------------------------'
}

###
# Public key
###
function SetPublicKey()
{
	local ssh_dir=""
	if [ $1 = $root_name ]
	then
		echo $root_color >> /root/.bashrc
		ssh_dir="/root/.ssh"
	else
		ssh_dir="/home/$1/.ssh"
	fi

	if [ ! -e "${ssh_dir}" ]
	then
		mkdir ${ssh_dir}
	fi

	pub_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC5aglM/I6PjJd6pZBz/h5bUXaiP74CwuqFjVwx+VdEs1DYg6WcvtgNyOMUVuw4Vv9CaCZy/EccRAdBsE9EsdDMmwp9ljK9CcsYGwMM9tVgqG0v0DtqF/4yiSDKFIHHDZLs9PFgPvTX17MxJRFWXZD0lOCYHvepDTOPeUT2VRrWjfMvch97VcGSTeBxgd9gtcul9JQnwhWJjQyVtGdu0s21hn259xykbWfQCa2snW9svaPA0ZvnxODak67PSBb55kz5MI6TUggg58mt+EIAhRYbgun+tP/JWIF0QJ5HKFhh27+Ow8CQoyOBfEGrqSXyLqepgMBIT6qrrdSaiMARdqll5OYCaQ/ZnqbCE17G4OzmMziSceV1WidyyipHT6UqBq2Ug2eh/77dIYeRO/9YzR0KtrQcAAUe0YsZHkB93ivsvSGJNECdJyRDsHpQBQJzXKb19dmmPpleY5iOt8W1MX/Q+F51k6Tk7DOZLa7L+z27QP+ooSyZle8JcWY2MUmAqXTunabT7M5K5GwH35OX/eClKJUzQFfdawx15wj/CdHuj9YRgDycDrE/8SWIYEXdS5EdrAy+UeQ+k24auj/XoWaHAXSoubOghFY9DZ5/u1ZKW2aJx/ZZMcYFTK2Isz1CpRsm+Fc0jvQtN82Q1o6nL54RC+iom+TxeBsvnHZibnJe6Ij71KvmrmpbbJ8L8XJjrPWF0/FtnM3oxWES2U4Dh/Pt6o7cloDw5Ve+LfTvszd2hoPKGsm6qnXjysHMvweqZNJIWn8Rlgy2HITu0iF/PP9DeB6yfsQ/paHCR+i6rLfvs/hJwxJCtRaiije2uUL/i90YwKKzn/GmlJ9IoqUlF33Zt2apdJI2RTu5tNuNhCu1kezVgc3EK2LjmRN4SAKkxcjWRS0PGRX/d6BWb7eROb8qz4S+w62QbK0nCRK5OQeCrhyioc1mVdSWdlpbci0yTS3whB1LFQve3my1cdOVHZCHj1WaqxKX1qimOkgr8DXnhne2AgpmuNYT7TXekdWv27ZwoM4mx7uwhGuGXlEEPJD8bf3oqS7EKhTEAuwXd+jctapPpbIRQrd8v/MaekZas8BVfVnqiO6G3yiEEW0uHXWznMglC8IPGpiUtke4RD/sKseej7D/FDfVY80hzdPDqpVyhJG308RoT10jNLcJn3MtVWGXXF2UeO2/2ZGrOYtQhQzDdjnCB9i5NqZSvKCWOPZQFAYcJBP037hB+20KF7o4GNo0qcmRT0JRMUab5v3erOnEsccsS0DlD5PQ2kFnKNAB/02Q+5csNrVZL4zcwwl8j7w7wq0q6qiP9SdXbeFDAKwiY0D18yQjA5mxS76WnbZsQAtIJR4hdLCDvdr3e6NJ common_key'
	echo $pub_key >> ${ssh_dir}/authorized_keys
	chmod 700 ${ssh_dir}
	chmod 600 ${ssh_dir}/authorized_keys

	if [ $1 = $root_name ]
	then
		chown -R root:root ${ssh_dir}
	else
		chown -R $1:$2 ${ssh_dir}
	fi
}

function ALL_In_One()
{
	OS_InstallTools

	OS_UserSettings
	OS_SystemSetting

	OS_OptimizePerformance
}

function OneStepFunction()
{
	echo '########## OneStepFunction ##########'
	# OS_InstallTools

	#OS_UserSettings
	#OS_SystemSetting

	#OS_OptimizePerformance
}

function CheckRoot()
{
	#Only root
	[[ $EUID -ne 0 ]] && echo 'Error: This script must be run as root!' && exit 1
}

echo '#####		欢迎使用一键初始化Linux脚本^_^		#####'
echo '#####									  	  #####'
echo '#####		请使用 Root 的进行初始化!!!			#####'
echo '#####		请使用 Root 的进行初始化!!!			#####'
echo '#####		请使用 Root 的进行初始化!!!			#####'
echo '#####									      #####'
CheckRoot
echo '---------------------------------------------'
echo '请选择系统:'
echo "1) CentOS 7 X64 ALL_In_One"
echo "2) OneStepFunction"
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'

case $num in
	1)
		ALL_In_One
		#setting $osip
		exit
	;;
	2)
		OneStepFunction
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
