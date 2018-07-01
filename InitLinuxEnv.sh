#!/bin/bash
#####		一键初始化Linux			 #####
#####		Author:bopy				#####
#####		Update:2018-06-26		#####

function BaseSetting()
{
	############# Add User ############
	#sudo adduser bopy
	#sudo passwd bopy
	#sudo visudo

	########## Base Setting ###########
	# set host name
	sudo hostnamectl set-hostname wwsbbase_Raspberry
	sudo echo "127.0.1.1   wwsbbase_Raspberry" >> /etc/hosts
	# set PS1
	sudo echo "export PS1='\n\e[1;37m[\e[m\e[1;34m\u\e[m\e[1;37m@\e[m\e[1;31m\H\e[m \e[4m`pwd`\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$'" >> $HOME/.bashrc

	# 安装字符集
	locale-gen en_US.UTF-8

	# 下载各种配置文件
	mkdir ~/download/
	cd ~/download/
	wget https://codeload.github.com/wwsbbase/wwsbbase_settings/zip/master
	unzip master
}

function ChangeSourcesList()
{
	# backup 
	sudo cp /etc/apt/sources.list /etc/apt/sources.list_back 
	# replace
	sudo sed -i 's#://raspbian.raspberrypi.org#s://mirrors.ustc.edu.cn/raspbian#g' /etc/apt/sources.list
	sudo sed -i 's#://mirrordirector.raspbian.org#s://mirrors.ustc.edu.cn/raspbian#g' /etc/apt/sources.list

	sudo sed -i 's#://archive.raspberrypi.org/debian#s://mirrors.ustc.edu.cn/archive.raspberrypi.org#g' /etc/apt/sources.list.d/raspi.list

	#sudo sed -i 's#://raspbian.raspberrypi.org#s://mirrors.tuna.tsinghua.edu.cn/raspbian#g' /etc/apt/sources.list
	#sudo sed -i 's#://archive.raspberrypi.org/debian#s://mirrors.tuna.tsinghua.edu.cn/raspberrypi#g' /etc/apt/sources.list.d/raspi.list

	# update 
	sudo apt-get update -y
	sudo apt-get upgrade -y
}

function InstallTools()
{
	# install base tools
	sudo apt-get install -y  git
	sudo apt-get install -y  wget
	sudo apt-get install -y  unzip
	sudo apt-get install -y  screen
	sudo apt-get install -y  dstat
	sudo apt-get install -y  curl

	# file system
	sudo apt-get install -y  xfsprogs

	# install for building Vim
	sudo apt-get install -y  ctags
	sudo apt-get install -y  lua5.1
	sudo apt-get install -y  lua5.1-dev
	sudo apt-get install -y  python-dev
	sudo apt-get install -y  python3-dev
	sudo apt-get install -y  libncurses5-dev

	sudo apt-get install -y  gcc
	sudo apt-get install -y  cmake
	sudo apt-get install -y  build-essential

	# install for build YCM
	sudo apt-get install -y  clang-5.0

	# Services
	sudo apt-get install -y  samba samba-common-bin
	sudo apt-get install -y  aria2
}

function BuildVim()
{
	# get latest vim src code 
	cd ~/download/
	git clone https://github.com/vim/vim.git

	cd vim

	git pull
	# clean 
	make distclean  # if you build Vim before
	
	# get python path
	python_lib_path=$(python -c "from distutils.sysconfig import get_python_lib;import sys; sys.exit(get_python_lib())") 
	#python_lib_path="/usr/lib64/python2.7/config/"
	
	# install
	./configure --with-features=huge --enable-pythoninterp=yes --enable-rubyinterp=yes --enable-luainterp=yes --enable-perlinterp=yes --with-python-config-dir=$python_lib_path --enable-gui=gtk2 --enable-cscope --prefix=/usr/local
	
	make
	sudo make install

	# config
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

	# get vimrc
	cd ~/download/wwsbbase_settings-master
	cp vimrc $HOME/.vimrc
}

function BuildYcm()
{
	git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
	cd ~/.vim/bundle/YouCompleteMe
	git submodule update --init --recursive
	./install.py --clang-completer
}

function InstallSSR()
{
	cd ~/download/
	git clone https://github.com/SAMZONG/gfwlist2privoxy.git
	cd gfwlist2privoxy/
	mv ssr /usr/local/bin
	chmod +x /usr/local/bin/ssr
	ssr install
	cd ~/download/wwsbbase_settings-master

	ssr start
}

function SambaService()
{
	sudo mv /etc/samba/smb.conf /etc/samba/smb_bak.conf

	# 配置/etc/samba/smb.conf文件
	cd ~/download/wwsbbase_settings-master
	sudo cp smb.conf /etc/samba/smb.conf

	sudo mkdir -p /data/download/
	sudo chown -R bopy:bopy /data/download/
	sudo smbpasswd -a bopy

	#设置开机自启动，编辑/etc/rc.local

	#重新启动服务
	sudo /etc/init.d/samba restart
}

function Aria2Service()
{
	

	cd ~/download/
	mkdir -p /data/download

}

function WebService()
{

}

function FtpService()
{
	sudo apt-get install vsftpd
	sudo vim /etc/vsftpd.conf
	sudo service vsftpd restart

}

function SetFirewall()
{

}

function Ubuntu()
{
	########## Setting ###########
	BaseSetting
	InstallTools
	#SSR 
	InstallSSR
	############## Vim ################
	BuildVim
}

function Debian()
{
	########## Setting ###########
	#BaseSetting
	InstallTools
	############## Vim ################
	#BuildVim

}

function Raspberry()
{
	########## Setting ###########
	BaseSetting
	ChangeSourcesList
	InstallTools
	############## Vim ################
	BuildVim
	BuildYcm

	SambaService
}

function CentOS()
{
	yum install -y git
	yum install -y screen
	yum install -y ctags
	yum install -y ncurses
	yum install -y ncurses-libs
	yum install -y ncurses-devel

}

function OneStepFunction()
{
	SambaService

}


echo '#####		欢迎使用一键初始化Linux脚本^_^	#####'
echo '----------------------------------'
echo '请选择系统:'
echo "1) CentOS 7 X64"
echo "2) Ubuntu 14+ X64"
echo "3) Raspberry "
echo "4) OneStepFunction "
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'

case $num in
	1)
		#安装
		CentOS
		#设置
		#setting $osip
		exit
	;;
	2)
		#安装aria2
		Ubuntu
		#setting $osip
		exit
	;;
	3)
		Raspberry
		exit
	;;
	4)
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