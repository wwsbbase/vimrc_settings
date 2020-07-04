#!/bin/bash
#########################################
#####		一键编译VIM		 		#####
#########################################


#############################################
#	文件结构
#
#	vimPackage.zip
#		vim/ 			vim源码目录
#		vimrc 			vim配置
#		YouCompleteMe/  YouCompleteMe源码目录
#	build_vim_self.sh
#		
#############################################

system_username="bun"
system_isInitRoot="yes"

userFolder="/home/${system_username}"
operatorFolder="/home/${system_username}/download/"

vim_package_name="vimPackage"

build_success=1
build_failed=0

build_step_0_init_info=0
build_step_1_install_tools=0
build_step_2_unpackage=0
build_step_2_update_package=1
build_step_3_install_vim_tools=0
build_step_4_complite_vim=0
build_step_5_install_vim=0
build_step_6_config_plugin=0
build_step_7_set_default_editor=0
build_step_8_build_ycm=0


function InputHostNameAndUserName()
{
	# 如果 build_step_0_init_info 为 build_success 表示跳过
	if [ ${build_step_0_init_info} -eq ${build_success} ]
	then
		echo "InstallBaseTools skip"
		return 0
	fi
	
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
		system_isInitRoot="no"
	else
		userFolder="/home/${system_username}"
		operatorFolder="/home/${system_username}/download/"

		echo '-----------------------------'
		echo '请输入是否初始化Root:(yes/no):'
		echo '-----------------------------'
		read -p ":" system_isInitRoot
		echo '-----------------------------'
		echo '是否初始化Root:'
		echo '-----------------------------'
		echo ${system_isInitRoot}
		
	fi

	echo '-----------------------------'
	echo '当前用户目录为:'
	echo '-----------------------------'
	echo ${userFolder}

	echo '-----------------------------'
	echo '当前操作目录为:'
	echo '-----------------------------'
	echo ${operatorFolder}
		
	build_step_0_init_info=${build_success}
}


function InstallBaseTools()
{
	# 如果 build_step_1_install_tools 为 build_success 表示跳过
	if [ ${build_step_1_install_tools} -eq ${build_success} ]
	then
		echo "InstallBaseTools skip"
		return 0
	fi
	
	echo '-------------InstallBaseTools---------------------'
	sudo yum install -y  git
	sudo yum install -y  wget
	sudo yum install -y  unzip
	
	build_step_1_install_tools=${build_success}
}


function UnPackage()
{
	# 如果 build_step_2_unpackage 为 build_success 表示跳过
	if [ ${build_step_2_unpackage} -eq ${build_success} ]
	then
		echo "UnPackage skip"
		return 0
	fi

	if [ -f "${operatorFolder}/${vim_package_name}.zip" ];then
		echo "${vim_package_name}包文件存在"
		
		if [ ! -d "${operatorFolder}/${vim_package_name}" ];then
			echo "文件不存在"
		else
			rm -rf "${operatorFolder}/${vim_package_name}"
		fi
		
		unzip ${vim_package_name}.zip
		if [ -d "${operatorFolder}/${vim_package_name}" ];then
			build_step_2_unpackage=${build_success}
			echo "解压完成"

			if [ ${build_step_2_update_package} -eq ${build_success} ]
			then
				echo "UpdatePackage skip"
				return 0
			else
				cd "${operatorFolder}/${vim_package_name}/vim/"
				git pull

				cd "${operatorFolder}/${vim_package_name}/YouCompleteMe/"
				git pull

				echo "UpdatePackage success"
			fi

		else
			echo "解压失败"
		fi
	else
		echo "${vim_package_name}.zip包文件不存在"
	fi
}



function InstallVimTools()
{
	# 如果 build_step_3_install_vim_tools 为 build_success 表示跳过
	if [ ${build_step_3_install_vim_tools} -eq ${build_success} ]
	then
		echo "InstallVimTools skip"
		return 0
	fi
	
	echo '-------------InstallVimTools---------------------'
		
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
	
	sudo yum install -y  python3
	sudo yum install -y  python3-devel

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
	
	
	build_step_3_install_vim_tools=${build_success}
}

function compliteVim()
{
	# 如果 build_step_4_complite_vim 为 build_success 表示跳过
	if [ ${build_step_4_complite_vim} -eq ${build_success} ]
	then
		echo "compliteVim skip"
		return 0
	fi
	
	echo '-------------compliteVim---------------------'

	if [ ! -d "${operatorFolder}/${vim_package_name}/vim" ];then
		echo "文件不存在"
		return 0
	fi
	cd "${operatorFolder}/${vim_package_name}/vim"

	make distclean  # if you build Vim before
	
	# get python path
	
	# --with-python-config-dir=PATH  Python's config directory (deprecated)
	# python_lib_path=$(python -c "from distutils.sysconfig import get_python_lib;import sys; sys.exit(get_python_lib())") 
	# python_lib_path="/usr/lib64/python2.7/config/"	
	# --enable-pythoninterp=yes \
	# --with-python-config-dir=$python_lib_path \
	
	# --with-python3-config-dir=PATH  Python's config directory (deprecated)
	# python3_lib_path=$(python -c "from distutils.sysconfig import get_python_lib;import sys; sys.exit(get_python_lib())") 
	# python3_lib_path="/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu"
	# --enable-python3interp=yes \
	# --with-python3-config-dir=$python3_lib_path \
	
	# install
	./configure --with-features=huge \
	--enable-multibyte \
	--enable-rubyinterp=yes \
	--enable-perlinterp=yes \
	--enable-luainterp=yes \
	--enable-gui=gtk2 \
	--enable-cscope \
	--enable-python3interp=yes \
	--prefix=/usr/local
	
	build_step_4_complite_vim=${build_success}
}

function InstallVim()
{
	# 如果 build_step_5_install_vim 为 build_success 表示跳过
	if [ ${build_step_5_install_vim} -eq ${build_success} ]
	then
		echo "InstallVim skip"
		return 0
	fi
	
	echo '-------------InstallVim---------------------'
	cd "${operatorFolder}/${vim_package_name}/vim"

	make	
	sudo make install
	
	build_step_5_install_vim=${build_success}
}

function ConfigPlugin()
{
	# 如果 build_step_6_config_plugin 为 build_success 表示跳过
	if [ ${build_step_6_config_plugin} -eq ${build_success} ]
	then
		echo "ConfigPlugin skip"
		return 0
	fi
	
	echo '-------------ConfigPlugin---------------------'
	# Vundle
	if [ -d "${userFolder}/.vim/bundle/Vundle.vim" ];then
		echo "Vundle.vim 文件夹已经存在，先删除"
		rm -rf "${userFolder}/.vim/bundle/Vundle.vim"
	fi
	
	if [ ! -d "${userFolder}/.vim/bundle/" ];then
		mkdir -p "${userFolder}/.vim/bundle/"
	fi
	cp -r "${operatorFolder}/${vim_package_name}/Vundle.vim" "$userFolder/.vim/bundle/"

	# get vimrc
	sudo cp "${operatorFolder}/${vim_package_name}/vimrc" $userFolder/.vimrc
	
	build_step_6_config_plugin=${build_success}
}

function SetDefaultEditor()
{
	# 如果 build_step_7_set_default_editor 为 build_success 表示跳过
	if [ ${build_step_7_set_default_editor} -eq ${build_success} ]
	then
		echo "SetDefaultEditor skip"
		return 0
	fi

	echo '-------------SetDefaultEditor---------------------'

	sudo ln -s /usr/local/bin/vim /usr/bin/vim
	
	build_step_7_set_default_editor=${build_success}
}

function BuildYcm()
{
	# 如果 build_step_8_build_ycm 为 build_success 表示跳过
	if [ ${build_step_8_build_ycm} -eq ${build_success} ]
	then
		echo "BuildYcm skip"
		return 0
	fi
	
	echo '-------------BuildYcm---------------------'
	if [ -d "${userFolder}/.vim/bundle/YouCompleteMe" ];then
		echo "YouCompleteMe 文件夹已经存在，先删除"
		rm -rf "${userFolder}/.vim/bundle/YouCompleteMe"
	fi
	
	if [ ! -d "${userFolder}/.vim/bundle/" ];then
		mkdir -p "${userFolder}/.vim/bundle/"
	fi
	
	cp -r "${operatorFolder}/${vim_package_name}/YouCompleteMe" "$userFolder/.vim/bundle/"
	cd "$userFolder/.vim/bundle/YouCompleteMe"
	./install.py --clang-completer
	
	build_step_8_build_ycm=${build_success}
}


function OneStepFunction()
{
	echo '########## OneStepFunction ##########'
	echo ${operatorFolder}
}

function CompleteInstall()
{
	InputHostNameAndUserName
	if [ ${build_step_0_init_info} -eq ${build_failed} ]
	then
		echo "InputHostNameAndUserName failed"
		return 0
	fi

	InstallBaseTools
	if [ ${build_step_1_install_tools} -eq ${build_failed} ]
	then
		echo "InstallBaseTools failed"
		return 0
	fi

	UnPackage
	if [ ${build_step_2_unpackage} -eq ${build_failed} ]
	then
		echo "UnPackage failed"
		return 0
	fi
	
	InstallVimTools
	if [ ${build_step_3_install_vim_tools} -eq ${build_failed} ]
	then
		echo "InstallVimTools failed"
		return 0
	fi

	compliteVim
	if [ ${build_step_4_complite_vim} -eq ${build_failed} ]
	then
		echo "compliteVim failed"
		return 0
	fi
	
	InstallVim
	if [ ${build_step_5_install_vim} -eq ${build_failed} ]
	then
		echo "InstallVim failed"
		return 0
	fi
	
	ConfigPlugin
	if [ ${build_step_6_config_plugin} -eq ${build_failed} ]
	then
		echo "ConfigPlugin failed"
		return 0
	fi
	
	SetDefaultEditor
	if [ ${build_step_7_set_default_editor} -eq ${build_failed} ]
	then
		echo "SetDefaultEditor failed"
		return 0
	fi
	
	BuildYcm
	if [ ${build_step_8_build_ycm} -eq ${build_failed} ]
	then
		echo "BuildYcm failed"
		return 0
	fi
}

function LiteInstall()
{
	InputHostNameAndUserName
	InstallBaseTools
	UnPackage
	InstallVimTools
	compliteVim
	InstallVim
	ConfigPlugin
	SetDefaultEditor
}






echo '#####		欢迎使用一键编译VIM脚本^_^		#####'
echo '#####									  	#####'
echo '#####									    #####'
echo '---------------------------------------------'
echo '请选择系统:'
echo "1) CompleteInstall"
echo "2) LiteInstall"
echo "3) OneStepFunction"
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'

case $num in
	1)
		CompleteInstall
		exit
	;;
	2)
		LiteInstall
		exit
	;;
	3)
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
