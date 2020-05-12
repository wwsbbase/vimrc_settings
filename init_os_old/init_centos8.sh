#!/bin/bash
#####		一键初始化CentOS8		 #####
#####		Update:2019-12-09		#####


# 文件夹结构
sambaFolder="/data/"

system_hostname="wwsbbase_defaut"
system_username="defaut_user"

setUserColor=""
python_lib_path=""
python3_lib_path=""

function BaseSetting()
{
	echo '----------------------------------'
	echo 'BaseSetting begin'
	############# Add User ############
	#sudo adduser defaut_user
	#sudo passwd defaut_user
	#sudo visudo

	########## Base Setting ###########
	ChangeHostname
	ChangeConsoleColor

	# 安装字符集
	# locale-gen en_US.UTF-8
	echo 'BaseSetting end'
	echo '----------------------------------'
}

function ChangeHostname()
{
	# set host name
	sudo hostnamectl set-hostname $system_hostname
	sudo echo "127.0.1.1   ${system_hostname}" >> /etc/hosts
}

function ChangeConsoleColor()
{
	# set PS1
	echo $setUserColor >> $userFolder/.bashrc
}

function InstallTools()
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

	sudo yum install -y  epel-release
	sudo yum install -y  htop
	sudo yum install -y  subversion
	sudo yum install -y  git
	sudo yum install -y  wget
	sudo yum install -y  unzip
	sudo yum install -y  screen
	sudo yum install -y  dstat
	sudo yum install -y  curl
	sudo yum install -y  ntpdate
	sudo yum install -y  gdisk
	sudo yum install -y	 net-tools
	echo 'InstallBaseTools end'
	echo '----------------------------------'
}

function InstallVimTools()
{
	echo '----------------------------------'
	echo 'InstallVimTools begin'
	# install for building Vim
	sudo yum groupinstall -y "Development Tools"  
	sudo yum install -y  cmake
	sudo yum install -y  ctags

	# install lua
	sudo yum install -y  lua
	sudo yum install -y  lua-devel

	# install python 
	sudo yum install -y  python
	sudo yum install -y  python-devel

	# install perl support
	sudo yum install -y  perl-ExtUtils-ParseXS
	sudo yum install -y  perl-ExtUtils-CBuilder
	sudo yum install -y  perl-ExtUtils-Embed

	# install ncurses
	sudo yum install -y	 ncurses
	sudo yum install -y  ncurses-libs
	sudo yum install -y  ncurses-devel

	# install for build YCM
	sudo yum install -y  clang

	echo 'InstallVimTools end'
	echo '----------------------------------'
}

function InstallAdvanceTools()
{
	echo '----------------------------------'
	echo 'InstallAdvanceTools begin'

	# file system
	sudo yum install -y  xfsprogs


	sudo yum install -y  python3
	sudo yum install -y  python3-dev

	sudo yum install -y  python-pip
	sudo yum install -y  python3-pip


	echo 'InstallAdvanceTools end'
	echo '----------------------------------'
}

function InstallExtraService()
{
	# Services
	sudo yum install -y  samba samba-common-bin
	sudo yum install -y  aria2
	sudo yum install -y  nginx
}

function InstallMariaDB()
{
	# 配置源
	sudo cp "${operatorFolder}wwsbbase_settings/MariaDB.repo" "/etc/yum.repos.d/MariaDB.repo"
	yum install -y MariaDB-server MariaDB-client
}

# 重新获取一份配置，方便其他服务从固定位置获取配置
function FetchConfigs()
{
	echo '----------------------------------'
	echo 'FetchConfigs begin'
	# 下载各种配置文件
	if [ ! -d "$operatorFolder" ]; then
		mkdir -p "$operatorFolder"
	fi

	cd "$operatorFolder"
	#wget https://codeload.github.com/wwsbbase/wwsbbase_settings/zip/master
	#unzip master
	git clone https://github.com/wwsbbase/wwsbbase_settings.git

	echo 'FetchConfigs end'
	echo '----------------------------------'
}

function PythonEnvs()
{
	# pip 换源
	mkdir $userFolder/.pip
	sudo cp "${operatorFolder}wwsbbase_settings/pip.conf" $userFolder/.pip/pip.conf

	sudo pip install virtualenvwrapper
	sudo pip3 install virtualenvwrapper

	mkdir $userFolder/.virtualenvs
	echo "export WORKON_HOME=~/.virtualenvs" >> $userFolder/.bashrc
	echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> $userFolder/.bashrc
	echo "source /usr/local/bin/virtualenvwrapper.sh" >> $userFolder/.bashrc
}

function BuildVim()
{
	InstallVimTools

	echo '----------------------------------'
	echo 'BuildVim begin'

	# get latest vim src code 
	cd "$operatorFolder"
	git clone https://github.com/vim/vim.git

	cd vim
	git pull
	# clean 
	make distclean  # if you build Vim before
	
	# get python path
	# python_lib_path=$(python -c "from distutils.sysconfig import get_python_lib;import sys; sys.exit(get_python_lib())") 
	python_lib_path="/usr/lib64/python2.7/config/"	

	# install
	./configure --with-features=huge \
	--enable-multibyte \
	--enable-rubyinterp=yes \
	--enable-perlinterp=yes \
	--enable-luainterp=yes \
	--enable-gui=gtk2 \
	--enable-cscope \
	--enable-pythoninterp=yes \
	--with-python-config-dir=$python_lib_path \
	--prefix=/usr/local
	
	make
	sudo make install

	# config
	git clone https://github.com/VundleVim/Vundle.vim.git $userFolder/.vim/bundle/Vundle.vim

	# get vimrc
	# cd "${operatorFolder}wwsbbase_settings"
	# cp vimrc $HOME/.vimrc
	sudo cp "${operatorFolder}wwsbbase_settings/vimrc" $userFolder/.vimrc

	sudo ln -s /usr/local/bin/vim /usr/bin/vim
	echo 'BuildVim end'
	echo '----------------------------------'
}

function BuildYcm()
{
	echo '----------------------------------'
	echo 'BuildYcm begin'

	git clone https://github.com/Valloric/YouCompleteMe.git $userFolder/.vim/bundle/YouCompleteMe
	cd $userFolder/.vim/bundle/YouCompleteMe
	git submodule update --init --recursive
	./install.py --clang-completer

	echo 'BuildYcm end'
	echo '----------------------------------'
}

function InstallZlua()
{
	echo '----------------------------------'
	echo 'InstallZlua begin'
	cd "$operatorFolder"
	git clone https://github.com/skywind3000/z.lua.git

	echo "eval \"\$(lua $operatorFolder/z.lua/z.lua --init bash enhanced once)\"" >> $userFolder/.bashrc

	echo 'InstallZlua end'
	echo '----------------------------------'
}


function SambaService()
{
	echo '----------------------------------'
	echo 'SambaService begin'
	sudo mv /etc/samba/smb.conf /etc/samba/smb_bak.conf

	# 配置/etc/samba/smb.conf文件
	# cd "${operatorFolder}wwsbbase_settings"
	# sudo cp smb.conf /etc/samba/smb.conf
	sudo cp "${operatorFolder}wwsbbase_settings/smb.conf" /etc/samba/smb.conf

	if [ ! -d "$sambaFolder" ]; then
		mkdir -p "$sambaFolder"
	fi

	sudo chown -R ${system_username}:${system_username} "$sambaFolder"
	sudo smbpasswd -a ${system_username}

	#设置开机自启动，编辑/etc/rc.local

	#重新启动服务
	sudo /etc/init.d/samba restart

	echo 'SambaService end'
	echo '----------------------------------'
}

function UserSetting()
{
	echo '########## UserSetting ##########'
}

function CentOS()
{
	echo '########## CentOS ##########'
	########## BaseSetting ###########
	BaseSetting
	InstallBaseTools
	FetchConfigs
	############## Vim ################
	BuildVim
	BuildYcm
	######### UserSetting #############
	UserSetting
	InstallZlua
	############## Service ################
	# SambaServic
	InstallMariaDB
}

function CentOS_Lite()
{
	echo '########## CentOS_Lite ##########'
	########## BaseSetting ###########
	BaseSetting
	InstallBaseTools
	FetchConfigs
	############## Vim ################
	# BuildVim
	# BuildYcm
	######### UserSetting #############
	UserSetting
	InstallZlua	
}

function OneStepFunction()
{
	echo '########## OneStepFunction ##########'
	echo ${operatorFolder}
}

function InputHostNameAndUserName()
{
	echo '-----------------------------'
	echo '请输入HostName:'
	echo '-----------------------------'
	read -p ":" system_hostname
	echo '-----------------------------'
	echo '输入的HostName:'
	echo '-----------------------------'
	echo ${system_hostname}


	echo '-----------------------------'
	echo '请输入UserName:'
	echo '-----------------------------'
	read -p ":" system_username
	echo '-----------------------------'
	echo '输入的HostName:'
	echo '-----------------------------'
	echo ${system_username}

	rootName="root"
	if [ ${system_username} == ${rootName} ] 
	then
		userFolder="/root/"
		operatorFolder="/root/download/"
	else
		userFolder="/home/${system_username}"
		operatorFolder="/home/${system_username}/download/"
	fi

	echo '-----------------------------'
	echo '当前用户目录为:'
	echo '-----------------------------'
	echo ${userFolder}

	echo '-----------------------------'
	echo '当前操作目录为:'
	echo '-----------------------------'
	echo ${operatorFolder}
}

echo '#####		欢迎使用一键初始化Linux脚本^_^		#####'
echo '#####									  	  #####'
echo '#####		请使用 普通账号的sudo 进行初始化!!!	#####'
echo '#####		请使用 普通账号的sudo 进行初始化!!!	#####'
echo '#####		请使用 普通账号的sudo 进行初始化!!!	#####'
echo '#####									      #####'
echo '---------------------------------------------'
echo '请选择系统:'
echo "1) CentOS 8 X64"
echo "2) CentOS 8 Lite X64"
echo "3) OneStepFunction"
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'

case $num in
	1)
		InputHostNameAndUserName

		#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
		#法国（蓝白红）
		setUserColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;30m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""

		CentOS
		#setting $osip
		exit
	;;
	2)
		InputHostNameAndUserName
		#法国（蓝白红）
		#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
		setUserColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;30m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""

		CentOS_Lite
		exit
	;;
	3)
		InputHostNameAndUserName
		#法国（蓝白红）
		#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
		setUserColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;30m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""

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
