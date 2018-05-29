#!/bin/bash
set -e
#--------------------------------------------
# 
# author：烁儿
# slogan：学的不仅是技术，更是梦想！
#--------------------------------------------
##### 描述 开始 #####
#
#
#   该脚本默认你已经安装了NodeJs环境如果没有请自行安装
#   该脚本可以安装Java、Cordova、Android、gradle、node、npm、docker
#   脚本名称 zs-tools:
#       -v | -version : 打印当前的版本信息
#       -i | install       : 安装软件（Java、Cordova、Android、gradle、node、npm、docker）
#       -c | chrck         : 用于检测当前的环境是否安装可用（Java、Cordova、Android、gradle、node、npm、docker）
#       ...           : 暂时只想到了这么多！想要什么功能以后再说
#   该脚本的安装方式可用于 npm install -g zs-tools
# 
#
##### 描述 结束  #####
#定义命令的执行方式
sh_c='bash -c'
#定义软件安装的包管理器，根据当前系统自动抓取
pkg_manager='apt'
#定义支持安装的软件
support_map="
java
cordova
android
node
gradle
"
#检测当前用户
check_user(){
    local user
    user="$(id -un 2>/dev/null || true)"
    if [ "$user" != 'root' ]; then
        if command_exists sudo 2>/dev/null; then
            sh_c='sudo -E bash -c'
        elif command_exists su 2>/dev/null; then
            sh_c='su -c'
        else
            echo "##################################################"
            echo "#                                                #"
            echo "#      Error: 该脚本需要root超级用户的权限执行！      #"
            echo "#      Error: 请使用 sudo zs-tools 来执行该脚本     #"
            echo "#                                                #"
            echo "##################################################"
            exit 1
        fi
    fi
}

#获取当前系统默认的程序安装器
get_pkg_manager() {
    local lsb_dist=""
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
    case "$lsb_dist" in
        ubuntu|debian|raspbian)
            pkg_manager='apt-get'
            echo ${pkg_manager}
            exit 0
        ;;
        centos|fedora)
            pkg_manager='yum'
            echo ${pkg_manager}
            exit 0
        ;;
        rhel|ol|sles)
            pkg_manager='yum'
            echo ${pkg_manager}
            exit 0
            ;;
        *)
            echo "不支持当前系统环境的安装"
            exit 1
        ;;
    esac
}
#检测当前的shell环境
detect_profile() {
    local DETECTED_PROFILE
    case "$SHELL" in
        /bin/bash|/bin/sh)
            if [ -f "$HOME/.bashrc" ]; then
                DETECTED_PROFILE="$HOME/.bashrc"
            elif [ -f "$HOME/.profile" ]; then
                DETECTED_PROFILE="$HOME/.profile"
            elif [ -f "$HOME/.bash_profile" ]; then
                DETECTED_PROFILE="$HOME/.bash_profile"
            fi
        ;;
        /bin/zsh)
            DETECTED_PROFILE="$HOME/.zshrc"
        ;;
        *)
            echo "不支持当前系统环境的安装"
            echo $SHELL
            exit 1
        ;;
    esac

    if [ ! -z "$DETECTED_PROFILE" ]; then
        echo "$DETECTED_PROFILE"
    fi
}
#检测软件是否已经安装
check(){
    if hash $1 2>/dev/null; then
        echo "true"
        exit 0
    else
        echo ""
        exit 0
    fi
}
#安装Java环境
install_java(){
    local check_java=`check java`
    if [ ! -z ${check_java} ]; then
        echo "\033[32m # Success: java 已经安装👏 🍺 \033[0m"
        echo "\033[33m # WARNING: 如果 java 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m" 
        exit 0
    fi
    echo '受您当前网速的影响，下载过程较慢，请耐心等待！正在安装 Java ⏳ ⏳ ⏳ '
    if [ -d ${HOME}/.zs-tools ]; then
        if [ ! -d ${HOME}/.zs-tools/jdk1.8.0_171 ]; then
            $sh_c "rm -rf ${HOME}/.zs-tools/jdk1.8.0_171"
        fi
        if [ ! -f $HOME/.zs-tools/jdk-8u171-linux-x64.tar.gz ]; then
            $sh_c "rm -rf $HOME/.zs-tools/jdk-8u171-linux-x64.tar.gz"
        fi
    else 
        $sh_c "mkdir -p ${HOME}/.zs-tools"
    fi
    $sh_c "wget -P ${HOME}/.zs-tools/ https://code.aliyun.com/shuoer/soft/raw/master/jdk-8u171-linux-x64.tar.gz && \
            tar zxvf ${HOME}/.zs-tools/jdk-8u171-linux-x64.tar.gz -C ${HOME}/.zs-tools/"
    echo "export JAVA_HOME=${HOME}/.zs-tools/jdk1.8.0_171" >> "${HOME}/.bashrc"
    echo 'export PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:${PATH}' >> "${HOME}/.bashrc"
    bash -ic "source ${HOME}/.bashrc"
    $sh_c "rm -rf ${HOME}/.zs-tools/jdk-8u171-linux-x64.tar.gz"
    echo "\033[32m # Success: java 已经安装👏 🍺 \033[0m"
    echo "\033[33m # WARNING: 如果 java 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m"
}
#安装Cordova环境
install_cordova(){
    local cheak_cordova=`check cordova`
    local cheak_npm=`check npm`
    local check_gradle=`check gradle`
    if [ ! -z ${cheak_cordova} ]; then
        echo "\033[32m # Success: cordova 已经安装👏 🍺 \033[0m"
        echo "\033[33m # WARNING: 如果 cordova 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m" 
        exit 0
    fi
    if [ -z ${cheak_npm} ]; then
        install_node
    fi
    if [ -z ${check_gradle} ]; then
        install_gradle
    fi
    echo '受您当前网速的影响，下载过程较慢，请耐心等待！正在安装 cordova ⏳ ⏳ ⏳ '
    $sh_c "npm install -g cordova"
    echo "\033[32m # Success: cordova 已经安装👏 🍺 \033[0m"
    echo "\033[33m # WARNING: 如果 cordova 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m"
}
install_node(){
    local cheak_node=`check node`
    if [ ! -z ${cheak_node} ]; then
        echo "\033[32m # Success: node 已经安装👏 🍺 \033[0m"
        echo "\033[33m # WARNING: 如果 node 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m" 
        exit 0
    fi
    echo '受您当前网速的影响，下载过程较慢，请耐心等待！正在安装 node ⏳ ⏳ ⏳ '
    $sh_c "wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash"
    bash -ic "source ${HOME}/.bashrc && \
            nvm install stable && \
            npm install -g yarn"
    echo "\033[32m # Success: node 已经安装👏 🍺 \033[0m"
    echo "\033[33m # WARNING: 如果 node 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m"
}
#安装gradle环境
install_gradle(){
    local check_gradle=`check gradle`
    local check_unzip=`check unzip`
    if [ ! -z ${check_gradle} ]; then
        echo "\033[32m # Success: gradle 已经安装👏 🍺 \033[0m"
        echo "\033[33m # WARNING: 如果 gradle 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m" 
        exit 0
    fi
    if [ -z ${check_unzip} ];then
        echo "该软件依赖与unzip软件，该软件将要被安装"
        check_user
        do_install unzip
    fi
    echo '受您当前网速的影响，下载过程较慢，请耐心等待！正在安装 gradle ⏳ ⏳ ⏳ '
    if [ -d ${HOME}/.zs-tools ]; then
        if [ ! -d ${HOME}/.zs-tools/gradle-4.1 ]; then
            $sh_c "rm -rf ${HOME}/.zs-tools/gradle-4.1"
        fi
        if [ ! -f ${HOME}/.zs-tools/gradle-4.1-bin.zip ]; then
            $sh_c "rm -rf ${HOME}/.zs-tools/gradle-4.1-bin.zip"
        fi
    else 
        $sh_c "mkdir -p ${HOME}/.zs-tools"
    fi
    $sh_c "wget -P ${HOME}/.zs-tools/ https://code.aliyun.com/shuoer/soft/raw/master/gradle-4.1-bin.zip && \
            unzip ${HOME}/.zs-tools/gradle-4.1-bin.zip -d ${HOME}/.zs-tools/"
    echo 'export PATH=${HOME}/.zs-tools/gradle-4.1/bin:${PATH}' >> "${HOME}/.bashrc"
    bash -ic "source ${HOME}/.bashrc"
    $sh_c "rm -rf ${HOME}/.zs-tools/gradle-4.1-bin.zip"
    echo "\033[32m # Success: gradle 已经安装👏 🍺 \033[0m"
    echo "\033[33m # WARNING: 如果 gradle 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m"
}
#安装android环境
install_android(){
    local check_android=`check android`
    local check_java=`check java`
    if [ ! -z ${check_android} ]; then
        echo "\033[32m # Success: android 已经安装👏 🍺 \033[0m"
        echo "\033[33m # WARNING: 如果 android 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m" 
        exit 0
    fi
    if [ -z ${check_java} ]; then
        install_java
    fi
    echo '受您当前网速的影响，下载过程较慢，请耐心等待！正在安装 android ⏳ ⏳ ⏳ '
    if [ -d ${HOME}/.zs-tools ]; then
        if [ ! -d ${HOME}/.zs-tools/android-sdk-linux ]; then
            $sh_c "rm -rf ${HOME}/.zs-tools/android-sdk-linux"
        fi
        if [ ! -f ${HOME}/.zs-tools/android-sdk_r24.4.1-linux.tgz ]; then
            $sh_c "rm -rf ${HOME}/.zs-tools/android-sdk_r24.4.1-linux.tgz"
        fi
    else 
        $sh_c "mkdir -p ${HOME}/.zs-tools"
    fi
    if [ ! -d ${HOME}/.android ]; then
        $sh_c "mkdir ${HOME}/.android"
    fi
    if [ ! -f ${HOME}/.android/repositories.cfg ]; then
        $sh_c "touch ${HOME}/.android/repositories.cfg"
    fi
    $sh_c "wget -P ${HOME}/.zs-tools/ https://code.aliyun.com/shuoer/soft/raw/master/android-sdk_r24.4.1-linux.tgz && 
            tar zxvf ${HOME}/.zs-tools/android-sdk_r24.4.1-linux.tgz -C ${HOME}/.zs-tools/"
    echo "export ANDROID_HOME=${HOME}/.zs-tools/android-sdk-linux" >> "${HOME}/.bashrc"
    echo 'export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}' >> "${HOME}/.bashrc"
    bash -ic "source ${HOME}/.bashrc && \
            echo y | android update sdk -a --no-ui --filter tools,platform-tools,android-26,build-tools-26.0.2"
    $sh_c "rm -rf ${HOME}/.zs-tools/android-sdk_r24.4.1-linux.tgz"
    echo "\033[32m # Success: android 已经安装👏 🍺 \033[0m"
    echo "\033[33m # WARNING: 如果 android 还未生效，请关闭终端重新打开终端或者注销当前用户后重新尝试 \033[0m"
}
#安装程序的主入口
do_install(){
    if [ -z $1 ]; then
        echo -e "\033[31m 未找到 $1 的安装程序，请检查 $1 名称是否正确！ \033[0m" 
        exit 1
    fi
    
    if ! echo "$support_map" | grep "$1" >/dev/null; then
        check_user
        $sh_c "$( get_pkg_manager ) update "
        $sh_c "$( get_pkg_manager ) install $1 -y"
        exit 0
    else
        eval "install_$1"
    fi
}

#获取安装参数，程序的主入口
while [ $# -gt 0 ]; do
    case "$1" in
        install|-i)
            do_install $2
            shift
            ;;
        -h|help)
            echo "这里是帮助选项"
            shift
            ;;
        -c|check)
            check $2
            shift
            ;;
        -v|version)
            echo "0.0.1"
            shift
            ;;
        *)
            echo "参数不合法，请使用-h或者help查看可用参数"
            exit 1
        ;;
    esac
    shift $(( $# > 0 ? 1 : 0 ))
done
