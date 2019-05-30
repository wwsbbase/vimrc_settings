#!/bin/bash
#####		一键初始化Linux			 #####
#####		Author:bopy				#####
#####		Update:2019-5-25		#####


# 文件夹结构
sambaFolder="/data/"

wwsbbase_hostname="wwsbbase_defaut"
wwsbbase_username="bopy"
userFolder="/home/${wwsbbase_username}"
operatorFolder="/home/${wwsbbase_username}/download/"

setRootColor=""
setUserColor=""
python_lib_path=""
python3_lib_path=""

function BaseSetting()
{
	echo '----------------------------------'
	echo 'BaseSetting begin'
	############# Add User ############
	#sudo adduser bopy
	#sudo passwd bopy
	#sudo visudo

	########## Base Setting ###########
	ChangeHostname
	ChangeConsoleColor

	# 安装字符集
	locale-gen en_US.UTF-8
	echo 'BaseSetting end'
	echo '----------------------------------'
}

function ChangeHostname()
{
	# set host name
	sudo hostnamectl set-hostname $wwsbbase_hostname
	sudo echo "127.0.1.1   ${wwsbbase_hostname}" >> /etc/hosts
}

function ChangeConsoleColor()
{
	# set PS1
	echo $setUserColor >> $userFolder/.bashrc
	sudo echo $setRootColor >> /root/.bashrc
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
	sudo apt-get install -y  git
	sudo apt-get install -y  wget
	sudo apt-get install -y  unzip
	sudo apt-get install -y  screen
	sudo apt-get install -y  dstat
	sudo apt-get install -y  curl
	sudo apt-get install -y  ntpdate
	sudo apt-get install -y  gdisk
	echo 'InstallBaseTools end'
	echo '----------------------------------'
}

function InstallVimTools()
{
	echo '----------------------------------'
	echo 'InstallVimTools begin'
	# install for building Vim
	sudo apt-get install -y  gcc
	sudo apt-get install -y  cmake
	sudo apt-get install -y  build-essential

	sudo apt-get install -y  ctags
	sudo apt-get install -y  lua5.1
	sudo apt-get install -y  lua5.1-dev
	sudo apt-get install -y  libncurses5-dev

	# install for build YCM
	sudo apt-get install -y  clang-5.0

	echo 'InstallVimTools end'
	echo '----------------------------------'
}

function InstallAdvanceTools()
{
	echo '----------------------------------'
	echo 'InstallAdvanceTools begin'

	# file system
	sudo apt-get install -y  xfsprogs

	# install python 
	sudo apt-get install -y  python
	sudo apt-get install -y  python3

	sudo apt-get install -y  python-dev
	sudo apt-get install -y  python3-dev

	sudo apt-get install -y  python-pip
	sudo apt-get install -y  python3-pip

	# Services
	sudo apt-get install -y  samba samba-common-bin
	sudo apt-get install -y  aria2
	sudo apt-get install -y  nginx

	echo 'InstallAdvanceTools end'
	echo '----------------------------------'
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
	#python_lib_path="/usr/lib64/python2.7/config/"
	
	# install
	./configure --with-features=huge \
	--enable-pythoninterp=yes --with-python-config-dir=$python_lib_path \
	--enable-python3interp=yes --with-python3-config-dir=$python3_lib_path \
	--enable-rubyinterp=yes \
	--enable-luainterp=yes \
	--enable-perlinterp=yes \
	--enable-gui=gtk2 \
	--enable-cscope \
	--prefix=/usr/local
	
	make
	sudo make install

	# config
	git clone https://github.com/VundleVim/Vundle.vim.git $userFolder/.vim/bundle/Vundle.vim
	git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim

	# get vimrc
	# cd "${operatorFolder}wwsbbase_settings"
	# cp vimrc $HOME/.vimrc
	sudo cp "${operatorFolder}wwsbbase_settings/vimrc" $userFolder/.vimrc
	sudo cp "${operatorFolder}wwsbbase_settings/vimrc" /root/.vimrc

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

	git clone https://github.com/Valloric/YouCompleteMe.git /root/.vim/bundle/YouCompleteMe
	cd /root/.vim/bundle/YouCompleteMe
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
	echo "eval \"\$(lua $operatorFolder/z.lua/z.lua --init bash enhanced once)\"" >> /root/.bashrc

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

	sudo chown -R bopy:bopy "$sambaFolder"
	sudo smbpasswd -a bopy

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

function Ubuntu()
{
	echo '########## Ubuntu ##########'
	########## BaseSetting ###########
	BaseSetting
	InstallTools
	FetchConfigs
	############## Vim ################
	BuildVim
	BuildYcm
	######### UserSetting #############
	UserSetting
	InstallZlua
	############## Service ################
	SambaServic
}

function Ubuntu_Lite()
{
	echo '########## Ubuntu_Lite ##########'
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
	InstallZlua
}


echo '#####		欢迎使用一键初始化Linux脚本^_^	#####'
echo '#####									  #####'
echo '#####		请使用 普通账号的sudo 进行初始化!!!	#####'
echo '#####		请使用 普通账号的sudo 进行初始化!!!	#####'
echo '#####		请使用 普通账号的sudo 进行初始化!!!	#####'
echo '#####									  #####'
echo '---------------------------------------------'
echo '请选择系统:'
echo "1) Ubuntu 18+ X64"
echo "2) Ubuntu_Lite 18+ X64"
echo "3) OneStepFunction"
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'

case $num in
	1)
		wwsbbase_username="bopy"
		wwsbbase_hostname="svn_server"
		userFolder="/home/${wwsbbase_username}"
		operatorFolder="/home/${wwsbbase_username}/download/"

		#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
		#法国（蓝白红）
		setRootColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;37m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""
		setUserColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;30m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""

		# python_lib_path=$(python -c "from distutils.sysconfig import get_python_lib;import sys; sys.exit(get_python_lib())") 
		# python3_lib_path=$(python3 -c "from distutils.sysconfig import get_python_lib;import sys; sys.exit(get_python_lib())") 
		python_lib_path=/usr/lib/python2.7/dist-packages
		python3_lib_path=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu

		Ubuntu
		#setting $osip
		exit
	;;
	2)
		wwsbbase_username="bopy"
		wwsbbase_hostname="ubuntu_Lab"
		userFolder="/home/${wwsbbase_username}"
		operatorFolder="/home/${wwsbbase_username}/download/"
		#法国（蓝白红）
		#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
		setRootColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;37m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""
		setUserColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;30m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""

		Ubuntu_Lite
		exit
	;;
	3)
		wwsbbase_username="ubuntu"
		wwsbbase_hostname="wwsbbase_cd"
		userFolder="/home/${wwsbbase_username}"
		operatorFolder="/home/${wwsbbase_username}/download/"
		#法国（蓝白红）
		#30:黑色; 31:红色; 32:绿色; 33:黄色; 34:蓝色; 35:紫色; 36:青色; 37:白色
		setRootColor="export PS1=\"\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;37m@\e[m\e[1;31m\H\e[m \e[4m\w\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$\""
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
