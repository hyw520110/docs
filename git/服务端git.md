# windows

安装配置Gitblit：

	http://www.gitblit.com/
创建用于存储资料的目录：

	mkdir E:\repo
配置data目录下的default.properties文件

	git.repositoriesFolder=e:/git/repo
	server.httpPort=10101
	server.httpsPort=8443
	server.httpBindInterface=192.168.1.105
	server.httpsBindInterface=localhost
执行gitblit.cmd开启服务,浏览器方位https://localhost:8443,输入admin/admin登录
## 创建版本库

点击右上角下拉菜单中的创建版本库,输入名称创建空的版本仓库成功，页面会有一些提示信息与命令，供用户用于向仓库中推送内容. 

这里不使用管理员账户admin作推送，我们通过配置新的用户，在用户端（即客户端）推送内容到仓库。这也比较符合实际生产，admin账户只用来管理服务器站点，不参与实际业务。包括创建版本库，以后也可以通过配置权限，向用户授予权限。接下来创建一个用户.

## 创建用户

创建用户时，需注意的是访问权限页面，配置版本库权限:

- 选择版本库，选择test.git. 
- 选择具体权限，选择R(克隆)（即读权限）、RW(推送)权限、RWC(推送，创建ref)权限等
## 客户端操作

### 配置

	git config --global user.name "test" 
	git config --global user.email "test@qq.com" 
	mkdir test && cd test
	echo "1" >test.txt
	git init 
	git add test.txt
	git commit -m "init project"
	git remote add origin ssh://test@192.168.1.105:29418/test.git
	git push -u origin master

推送操作需输入密码,如需ssh无密码克隆推送操作，主要操作就是客户端命令行创建SSH Key，通过以下命令： 

	ssh-keygen -t rsa -C "419140278@qq.com"
然后到用户主目录下找到.ssh文件夹，下面生成了id_rsa和id_rsa.pub这两个文件，将pub文件中的内容复制，上传到Gitblit站点自己账户的->用户中心->ssh，添加成功，则以后操作通过ssh://协议操作，则可以不用密码

### 安装服务

编辑installService.cmd，修改 ARCH

32位系统：SET ARCH=x86

64位系统：SET ARCH=amd64
	
添加 CD 为程序目录

	SET CD=D:\Java\gitblit-1.8.0

修改StartParams里的启动参数值为空

以管理员身份运行执行installService.cmd安装服务

# linux 

## 安装 Git
yum中的git版本

	yum info git
	
通过yum 安装git

	yum -y install git gitweb
如需安装高版本git：

	yum -y remove git
	yum -y install perl cpio autoconf tk zlib-devel libcurl-devel openssl-devel expat-devel gettext-devel perl-ExtUtils-MakeMaker
	cd /usr/local/src; wget https://www.kernel.org/pub/software/scm/git/git-2.10.0.tar.gz
	tar zxf git-2.10.0.tar.gz && cd git-2.10.0
	autoconf && ./configure && make && make install
如报错：

	configure: error: no acceptable C compiler found in $PATH
执行：

	yum -y install gcc

	git --version

## 创建用户
	
先查看是否存在git用户


	id git
服务器端创建git用户,用来管理Git服务

	useradd -r -s /bin/sh -c 'git version control' -d /opt/git git
	passwd git
	
## 创建仓库

在开始架设 Git 服务器前，需要把现有仓库导出为裸仓库——即一个不包含当前工作目录的仓库。 
	
	mkdir -p  /opt/git/test.git
	git init --bare /opt/git/test.git
	cd /opt/git
	chown -R git:git test.git/
现在，你的test.git 目录中应该有 Git 目录的副本了。

### 客户端clone远程仓库

	git config --global color.ui true
	git config --global user.name 'hyw'
	git config --global user.email '419140278@qq.com'
	git clone git@192.168.40.113:/opt/git/test.git
	
	cd test/
	cp /etc/passwd .
	git add passwd 
	git commit -m 'add passwd'
	git push -u origin master
	git status
	
用户目录下.ssh目录下会生成known_hosts文件

客户端创建 SSH 公钥和私钥

	ssh-keygen -t rsa -C "419140278@qq.com"
.ssh目录下会多出两个文件 id_rsa私钥和 id_rsa.pub公钥

服务器端 Git 打开 RSA 认证

	vi /etc/ssh/sshd_config
	RSAAuthentication yes
	PubkeyAuthentication yes
	AuthorizedKeysFile .ssh/authorized_keys
重启sshd服务：

	 systemctl restart sshd.service
管理Git服务的用户是git，所以实际存放公钥的路径是/home/git/.ssh/authorized_keys,创建所需目录：

	mkdir -p /home/git/.ssh
	chown -R git:git /home/git/.ssh

将客户端公钥导入服务器端/home/git/.ssh/authorized_keys文件，客户端执行：

	ssh git@192.168.40.113 'cat >> /home/git/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
需要输入服务器端git用户的密码.收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub公钥导入到服务端的/home/git/.ssh/authorized_keys文件里，一行一个。

回到服务器端，查看 .ssh 下是否存在 authorized_keys 文件：

	cat /home/git/.ssh/authorized_keys
	chmod 700 /home/git/.ssh
	chmod 600 /home/git/.ssh/authorized_keys

客户端再次 clone 远程仓库
	
	rm -rf test
	git clone git@192.168.40.113:/opt/git/test.git

禁止 git 用户 ssh 登录服务器

	vi /etc/passwd
	git:x:1001:1001::/home/git:/bin/bash
修改为
	
	git:x:1001:1001::/home/git:/usr/bin/git-shell	
	
	
git用户可以正常通过ssh使用git，但无法通过ssh登录系统	

以上实现了SSH本地用户授权访问 git 仓库
如果 SSH 非标准端口时，需要这样访问：

	git clone ssh://root@192.168.1.22:16543/opt/git/test.git
想把git仓库test.git 授权别人访问:

- 首先你得给每个人创建用户，他们才能 clone 代码，但是不能写入。
- 其次你要把这些用户加入到一个组，然后把 sample.git 属组改为这个组，并且给这个组写入权限。
- 或者创建一个公共用户，修改 git 仓库 sample.git 属主为这个公共用户，然后大家都使用这个用户访问代码库。

### Git HTTP 协议

首选创建用户、创建仓库

### 配置仓库：
	
	cd test.git && mv hooks/post-update.sample hooks/post-update
	git update-server-info
### 安装配置Nginx 

安装spawn-fcgi

	cd /usr/local/src
	git clone https://github.com/lighttpd/spawn-fcgi.git
	cd spawn-fcgi && ./autogen.sh
	./configure && make && make install
	yum -y install fcgi-devel

如执行报错：
	
		failed to run aclocal: No such file or directory
执行：
	
	yum install automake

安装fcgiwrap

	cd /usr/local/src
	git clone https://github.com/gnosek/fcgiwrap.git
	cd fcgiwrap && autoreconf -i && ./configure && make && make install

配置自启动：


	vim /etc/init.d/fcgiwrap
	#! /bin/bash
	### BEGIN INIT INFO
	# Provides:          fcgiwrap
	# Required-Start:    $remote_fs
	# Required-Stop:     $remote_fs
	# Should-Start:
	# Should-Stop:
	# Default-Start:     2 3 4 5
	# Default-Stop:      0 1 6
	# Short-Description: FastCGI wrapper
	# Description:       Simple server for running CGI applications over FastCGI
	### END INIT INFO
	
	PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
	SPAWN_FCGI="/usr/local/bin/spawn-fcgi"
	DAEMON="/usr/local/sbin/fcgiwrap"
	NAME="fcgiwrap"
	
	PIDFILE="/var/run/$NAME.pid"
	
	FCGI_SOCKET="/var/run/$NAME.socket"
	FCGI_USER="git"
	FCGI_GROUP="git"
	FORK_NUM=5
	SCRIPTNAME=/etc/init.d/$NAME
	
	case "$1" in
	    start)
	        echo -n "Starting $NAME... "
	
	        PID=`pidof $NAME`
	        if [ ! -z "$PID" ]; then
	            echo " $NAME already running"
	            exit 1
	        fi
	
	        $SPAWN_FCGI -u $FCGI_USER -g $FCGI_GROUP -s $FCGI_SOCKET -P $PIDFILE -F $FORK_NUM -f $DAEMON
	
	        if [ "$?" != 0 ]; then
	            echo " failed"
	            exit 1
	        else
	            echo " done"
	        fi
	    ;;
	
	    stop)
	        echo -n "Stoping $NAME... "
	
	        PID=`pidof $NAME`
	        if [ ! -z "$PID" ]; then
	            kill `pidof $NAME`
	            if [ "$?" != 0 ]; then
	                echo " failed. re-quit"
	                exit 1
	            else
	                rm -f $pid
	                echo " done"
	            fi
	        else
	            echo "$NAME is not running."
	            exit 1
	        fi
	    ;;
	
	    status)
	        PID=`pidof $NAME`
	        if [ ! -z "$PID" ]; then
	            echo "$NAME (pid $PID) is running..."
	        else
	            echo "$NAME is stopped"
	            exit 0
	        fi
	    ;;
	
	    restart)
	        $SCRIPTNAME stop
	        sleep 1
	        $SCRIPTNAME start
	    ;;
	
	    *)
	        echo "Usage: $SCRIPTNAME {start|stop|restart|status}"
	        exit 1
	    ;;
	esac 
注意:

- 用户和用户组FCGI_USER FCGI_GROUP 为前面创建的
- spawn-fcgi 跟 fcgiwrap 脚本路径及 FCGI_GROUP 跟 FCGI_GROUP

脚本启动了 5 个 cgi 进程，按需调整


	chmod a+x /etc/init.d/fcgiwrap
	chkconfig --level 35 fcgiwrap on
	/etc/init.d/fcgiwrap start

	vi auto.sh
	#!/bin/bash
	USER=git
	
	install_nginx(){
	  yum -y install gcc gcc-c++ wget make pcre-devel zlib-devel openssl-devel
	
	  id $USER > /dev/null 2>&1 || useradd -r -s /sbin/nologin $USER
	
	  cd /usr/local/src; wget -qc http://nginx.org/download/nginx-1.10.2.tar.gz || exit 9
	
	  tar zxf nginx-1.10.2.tar.gz; cd nginx-1.10.2
	  ./configure --prefix=/usr/local/nginx-1.10.2 --with-http_dav_module --with-http_ssl_module --with-http_realip_module --with-http_gzip_static_module --with-http_stub_status_module  --with-http_degradation_module && make && make install
	  mkdir /usr/local/nginx-1.10.2/conf/vhost; mkdir -p /data/logs/nginx
	  echo "/usr/local/nginx-1.10.2/sbin/nginx" >> /etc/rc.local
	}
	
	[ $# -lt 2 ] && exit 9
	
	if [ $1 == 'install' ];then
	  case $2 in
	    nginx)
	      install_nginx ;;
	    *)
	      echo 'NULL' ;;
	  esac
	fi
	
	sh auto.sh install nginx 
	
	or
	yum install nginx gitweb
	
	
不添加with-http_dav_module该模块无法git push，请查找 Nginx WebDAV 模块	


	vim /usr/local/nginx-1.10.2/conf/vhost/git.server.conf
	
	server {
	    listen      80;
	    server_name git.server.com;
	
	    client_max_body_size 100m;
	
	    auth_basic "Git User Authentication";
	    auth_basic_user_file /usr/local/nginx-1.10.2/conf/pass.db;
	
	    location ~ ^.*\.git/objects/([0-9a-f]+/[0-9a-f]+|pack/pack-[0-9a-f]+.(pack|idx))$ {
	        root /opt/git;
	    }    
	    
	    location ~ /.*\.git/(HEAD|info/refs|objects/info/.*|git-(upload|receive)-pack)$ {
	        root          /opt/git;
	        fastcgi_pass  unix:/var/run/fcgiwrap.socket;
	        fastcgi_connect_timeout 24h;
	        fastcgi_read_timeout 24h;
	        fastcgi_send_timeout 24h;
	        fastcgi_param SCRIPT_FILENAME   /usr/local/libexec/git-core/git-http-backend;
	        fastcgi_param PATH_INFO         $uri;
	        fastcgi_param GIT_HTTP_EXPORT_ALL "";
	        fastcgi_param GIT_PROJECT_ROOT  /opt/git;
	        fastcgi_param REMOTE_USER $remote_user;
	        include fastcgi_params;
	    }
	}
注意 

- 按需修改nginx.conf，user git git; 在http中加入 include vhost/*.conf;
- 认证文件 pass.db 路径
- 注意 git-http-backend 路径
- 第一个 location 用于静态文件直接读取
- 第二个 location 用于将指定动作转给 cgi 执行
- 根目录指向 git 仓库目录

启动nginx

	/usr/local/nginx-1.10.2/sbin/nginx
安装htpasswd命令

	yum -y install httpd-tools
添加用户

	cd /usr/local/nginx-1.10.2/conf
	htpasswd -c pass.db hyw
客户端clone

	git config --global color.ui true
	git config --global user.name 'hyw'
	git config --global user.email '419140278@qq.com'
	git clone http://dev.git.com/test.git 
查看gitweb

	ll /usr/local/share/gitweb 
通过源码方式安装git（gitweb位于git源码中），gitweb已经安装好了


配置gitweb

	vim /etc/gitweb.conf

	# path to git projects (<project>.git)
	$projectroot = "/opt/git";
	# directory to use for temp files
	$git_temp = "/tmp";
	# target of the home link on top of all pages
	$home_link = $my_uri || "/";
	# html text to include at home page
	$home_text = "indextext.html";
	# file with project list; by default, simply scan the projectroot dir.
	$projects_list = $projectroot;
	# javascript code for gitweb
	$javascript = "static/gitweb.js";
	# stylesheet to use
	$stylesheet = "static/gitweb.css";
	# logo to use
	$logo = "static/git-logo.png";
	# the 'favicon'
	$favicon = "static/git-favicon.png";


	$feature {'blame'}{'default'} = [1];
	$feature {'blame'}{'override'} = 1;
	$feature {'snapshot'}{'default'} = ['zip', 'tgz'];
	$feature {'snapshot'}{'override'} = 1;
	$feature{'highlight'}{'default'} = [1];

开启服务

	 /usr/local/share/gitweb/gitweb.cgi

如报错：

	Can't locate CGI.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /usr/local/share/gitweb/gitweb.cgi line 13.
执行：

	 yum -y install perl-CPAN
如报错：

	Can't locate CGI.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /usr/local/share/gitweb/gitweb.cgi line 13.

执行：

	yum -y install perl-CGI

如报错：

	Can't locate Time/HiRes.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /usr/local/share/gitweb/gitweb.cgi line 20.

执行：
	
	yum -y install perl-Time-HiRes

nginx添加gitweb配置(git.server.conf)

    try_files $uri @gitweb;
    location @gitweb {
        fastcgi_pass  unix:/var/run/fcgiwrap.socket;
        fastcgi_param GITWEB_CONFIG    /etc/gitweb.conf;
        fastcgi_param SCRIPT_FILENAME  /usr/local/share/gitweb/gitweb.cgi;
        fastcgi_param PATH_INFO        $uri;
        include fastcgi_params;
    }   

	../sbin/nginx -s reload

Gitweb-theme 样式

如果觉得 gitweb 默认样式不好看，可以拿该样式替换


	cd /usr/local/src
	git clone https://github.com/kogakure/gitweb-theme.git
	cd gitweb-theme
	./setup -vi -t /usr/local/share/gitweb --install
git push 报错：

	error: RPC failed; HTTP 413 curl 22 The requested URL returned error: 413 Request Entity Too Large
	fatal: The remote end hung up unexpectedly
	fatal: The remote end hung up unexpectedly
解决方法：

	vim /usr/local/nginx-1.10.2/conf/vhost/git.server.conf  
	client_max_body_size 100m;

# Gitosis

把所有用户的公钥保存在 authorized_keys 文件的做法，只适合中小型团队，当用户数量达到几百人的规模时，管理起来就会十分痛苦。

Gitosis 就是一套用来管理 authorized_keys 文件和实现简单连接限制的脚本。有趣的是，用来添加用户和设定权限的并非通过网页程序，而只是管理一个特殊的 Git 仓库。你只需要在这个特殊仓库内做好相应的设定，然后推送到服务器上，Gitosis 就会随之改变运行策略

Gitosis 的工作依赖于某些 Python 工具，所以首先要安装 Python 的 setuptools 包

	yum install python-setuptools
安装：

	git clone https://github.com/tv42/gitosis.git
	cd gitosis
	sudo python setup.py install
默认 Gitosis 会把 /home/git 作为存储所有 Git 仓库的根目录，如仓库都已经存在/opt/git里面，则需做一个符号链接

	ln -s /opt/git /home/git/repositories
	
备份文件：


	mv /home/git/.ssh/authorized_keys /home/git/.ssh/ak.bak
如果之前把 git 用户的登录 shell 改为 git-shell 命令的话，先恢复 'git' 用户的登录 shell。改过之后，大家仍然无法通过该帐号登录（译注：因为 authorized_keys 文件已经没有了。），改回:

	vi /etc/passwd 
	git:x:1000:1000::/home/git:/bin/sh
查看文件是否存在

	ll /root/.ssh/id_rsa.pub	
如不存在执行：

	ssh-keygen -t rsa -C "419140278@qq.com"
初始化 Gitosis

	cp ~/.ssh/id_rsa.pub /tmp
	sudo -H -u git gitosis-init < /tmp/id_rsa.pub

#协议
架设一台 Git 服务器并不难。 首先，选择你希望服务器使用的通讯协议，如果不介意托管你的代码在其他人的服务器，且不想经历设置与维护自己服务器的麻烦，可以试试仓库托管服务。

一个远程仓库通常只是一个裸仓库（bare repository）— 即一个没有当前工作目录的仓库。 因为该仓库仅仅作为合作媒介，不需要从磁碟检查快照；存放的只有 Git 的资料。 简单的说，裸仓库就是你工程目录内的 .git 子目录内容，不包含其他资料。

Git 可以使用四种主要的协议来传输资料：本地协议（Local），HTTP 协议，SSH（Secure Shell）协议及 Git 协议

##本地协议
最基本的就是 本地协议（Local protocol） ，其中的远程版本库就是硬盘内的另一个目录。 这常见于团队每一个成员都对一个共享的文件系统（例如一个挂载的 NFS）拥有访问权，或者比较少见的多人共用同一台电脑的情况。 后者并不理想，因为你的所有代码版本库如果长存于同一台电脑，更可能发生灾难性的损失。

如果你使用共享文件系统，就可以从本地版本库克隆（clone）、推送（push）以及拉取（pull）。 像这样去克隆一个版本库或者增加一个远程到现有的项目中，使用版本库路径作为 URL。 例如，克隆一个本地版本库，可以执行如下的命令：

	git clone /opt/git/project.git
或你可以执行这个命令：

	git clone file:///opt/git/project.git
如果在 URL 开头明确的指定 file://，那么 Git 的行为会略有不同。 如果仅是指定路径，Git 会尝试使用硬链接（hard link）或直接复制所需要的文件。 如果指定 file://，Git 会触发平时用于网路传输资料的进程，那通常是传输效率较低的方法。 指定 file:// 的主要目的是取得一个没有外部参考（extraneous references）或对象（object）的干净版本库副本– 通常是在从其他版本控制系统导入后或一些类似情况需要这么做。 在此我们将使用普通路径，因为这样通常更快。

要增加一个本地版本库到现有的 Git 项目，可以执行如下的命令：

	git remote add local_proj /opt/git/project.git
然后，就可以像在网络上一样从远端版本库推送和拉取更新了。

###优点
基于文件系统的版本库的优点是简单，并且直接使用了现有的文件权限和网络访问权限。 如果你的团队已经有共享文件系统，建立版本库会十分容易。 只需要像设置其他共享目录一样，把一个裸版本库的副本放到大家都可以访问的路径，并设置好读/写的权限，就可以了， 我们会在 在服务器上搭建 Git 讨论如何导出一个裸版本库。

这也是快速从别人的工作目录中拉取更新的方法。 如果你和别人一起合作一个项目，他想让你从版本库中拉取更新时，运行类似 git pull /home/john/project 的命令比推送到服务再取回简单多了。

###缺点
这种方法的缺点是，通常共享文件系统比较难配置，并且比起基本的网络连接访问，这不方便从多个位置访问。 如果你想从家里推送内容，必须先挂载一个远程磁盘，相比网络连接的访问方式，配置不方便，速度也慢。

值得一提的是，如果你使用的是类似于共享挂载的文件系统时，这个方法不一定是最快的。 访问本地版本库的速度与你访问数据的速度是一样的。 在同一个服务器上，如果允许 Git 访问本地硬盘，一般的通过 NFS 访问版本库要比通过 SSH 访问慢。

最终，这个协议并不保护仓库避免意外的损坏。 每一个用户都有“远程”目录的完整 shell 权限，没有方法可以阻止他们修改或删除 Git 内部文件和损坏仓库。

##HTTP 协议
Git 通过 HTTP 通信有两种模式。 在 Git 1.6.6 版本之前只有一个方式可用，十分简单并且通常是只读模式的。 Git 1.6.6 版本引入了一种新的、更智能的协议，让 Git 可以像通过 SSH 那样智能的协商和传输数据。 之后几年，这个新的 HTTP 协议因为其简单、智能变的十分流行。 新版本的 HTTP 协议一般被称为“智能” HTTP 协议，旧版本的一般被称为“哑” HTTP 协议。 我们先了解一下新的“智能” HTTP 协议。

###智能（Smart） HTTP 协议
“智能” HTTP 协议的运行方式和 SSH 及 Git 协议类似，只是运行在标准的 HTTP/S 端口上并且可以使用各种 HTTP 验证机制，这意味着使用起来会比 SSH 协议简单的多，比如可以使用 HTTP 协议的用户名／密码的基础授权，免去设置 SSH 公钥。

智能 HTTP 协议或许已经是最流行的使用 Git 的方式了，它即支持像 git:// 协议一样设置匿名服务，也可以像 SSH 协议一样提供传输时的授权和加密。 而且只用一个 URL 就可以都做到，省去了为不同的需求设置不同的 URL。 如果你要推送到一个需要授权的服务器上（一般来讲都需要），服务器会提示你输入用户名和密码。 从服务器获取数据时也一样。

事实上，类似 GitHub 的服务，你在网页上看到的 URL （比如， https://github.com/schacon/simplegit[])，和你在克隆、推送（如果你有权限）时使用的是一样的。

###哑（Dumb） HTTP 协议
如果服务器没有提供智能 HTTP 协议的服务，Git 客户端会尝试使用更简单的“哑” HTTP 协议。 哑 HTTP 协议里 web 服务器仅把裸版本库当作普通文件来对待，提供文件服务。 哑 HTTP 协议的优美之处在于设置起来简单。 基本上，只需要把一个裸版本库放在 HTTP 根目录，设置一个叫做 post-update 的挂钩就可以了。 此时，只要能访问 web 服务器上你的版本库，就可以克隆你的版本库。 下面是设置从 HTTP 访问版本库的方法：

	$ cd /var/www/htdocs/
	$ git clone --bare /path/to/git_project gitproject.git
	$ cd gitproject.git
	$ mv hooks/post-update.sample hooks/post-update
	$ chmod a+x hooks/post-update
这样就可以了。 Git 自带的 post-update 挂钩会默认执行合适的命令（git update-server-info），来确保通过 HTTP 的获取和克隆操作正常工作。 这条命令会在你通过 SSH 向版本库推送之后被执行；然后别人就可以通过类似下面的命令来克隆：

	$ git clone https://example.com/gitproject.git
这里我们用了 Apache 里设置了常用的路径 /var/www/htdocs，不过你可以使用任何静态 web 服务器 —— 只需要把裸版本库放到正确的目录下就可以。 Git 的数据是以基本的静态文件形式提供的

通常的，会在可以提供读／写的智能 HTTP 服务和简单的只读的哑 HTTP 服务之间选一个。 极少会将二者混合提供服务。

###优点
我们将只关注智能 HTTP 协议的优点。

不同的访问方式只需要一个 URL 以及服务器只在需要授权时提示输入授权信息，这两个简便性让终端用户使用 Git 变得非常简单。 相比 SSH 协议，可以使用用户名／密码授权是一个很大的优势，这样用户就不必须在使用 Git 之前先在本地生成 SSH 密钥对再把公钥上传到服务器。 对非资深的使用者，或者系统上缺少 SSH 相关程序的使用者，HTTP 协议的可用性是主要的优势。 与 SSH 协议类似，HTTP 协议也非常快和高效。

你也可以在 HTTPS 协议上提供只读版本库的服务，如此你在传输数据的时候就可以加密数据；或者，你甚至可以让客户端使用指定的 SSL 证书。

另一个好处是 HTTP/S 协议被广泛使用，一般的企业防火墙都会允许这些端口的数据通过。

###缺点
在一些服务器上，架设 HTTP/S 协议的服务端会比 SSH 协议的棘手一些。 除了这一点，用其他协议提供 Git 服务与 “智能” HTTP 协议相比就几乎没有优势了。

如果你在 HTTP 上使用需授权的推送，管理凭证会比使用 SSH 密钥认证麻烦一些。 然而，你可以选择使用凭证存储工具，比如 OSX 的 Keychain 或者 Windows 的凭证管理器。 参考 凭证存储 如何安全地保存 HTTP 密码。

##SSH 协议
架设 Git 服务器时常用 SSH 协议作为传输协议。 因为大多数环境下已经支持通过 SSH 访问 —— 即时没有也比较很容易架设。 SSH 协议也是一个验证授权的网络协议；并且，因为其普遍性，架设和使用都很容易。

通过 SSH 协议克隆版本库，你可以指定一个 ssh:// 的 URL：

	git clone ssh://user@server/project.git
或者使用一个简短的 scp 式的写法：

	git clone user@server:project.git
你也可以不指定用户，Git 会使用当前登录的用户名。

###优势
用 SSH 协议的优势有很多。 首先，SSH 架设相对简单 —— SSH 守护进程很常见，多数管理员都有使用经验，并且多数操作系统都包含了它及相关的管理工具。 其次，通过 SSH 访问是安全的 —— 所有传输数据都要经过授权和加密。 最后，与 HTTP/S 协议、Git 协议及本地协议一样，SSH 协议很高效，在传输前也会尽量压缩数据。

###缺点
SSH 协议的缺点在于你不能通过他实现匿名访问。 即便只要读取数据，使用者也要有通过 SSH 访问你的主机的权限，这使得 SSH 协议不利于开源的项目。 如果你只在公司网络使用，SSH 协议可能是你唯一要用到的协议。 如果你要同时提供匿名只读访问和 SSH 协议，那么你除了为自己推送架设 SSH 服务以外，还得架设一个可以让其他人访问的服务。

##Git 协议
接下来是 Git 协议。 这是包含在 Git 里的一个特殊的守护进程；它监听在一个特定的端口（9418），类似于 SSH 服务，但是访问无需任何授权。 要让版本库支持 Git 协议，需要先创建一个 git-daemon-export-ok 文件 —— 它是 Git 协议守护进程为这个版本库提供服务的必要条件 —— 但是除此之外没有任何安全措施。 要么谁都可以克隆这个版本库，要么谁也不能。 这意味着，通常不能通过 Git 协议推送。 由于没有授权机制，一旦你开放推送操作，意味着网络上知道这个项目 URL 的人都可以向项目推送数据。 不用说，极少会有人这么做。

###优点
目前，Git 协议是 Git 使用的网络传输协议里最快的。 如果你的项目有很大的访问量，或者你的项目很庞大并且不需要为写进行用户授权，架设 Git 守护进程来提供服务是不错的选择。 它使用与 SSH 相同的数据传输机制，但是省去了加密和授权的开销。

###缺点
Git 协议缺点是缺乏授权机制。 把 Git 协议作为访问项目版本库的唯一手段是不可取的。 一般的做法里，会同时提供 SSH 或者 HTTPS 协议的访问服务，只让少数几个开发者有推送（写）权限，其他人通过 git:// 访问只有读权限。 Git 协议也许也是最难架设的。 它要求有自己的守护进程，这就要配置 xinetd 或者其他的程序，这些工作并不简单。 它还要求防火墙开放 9418 端口，但是企业防火墙一般不会开放这个非标准端口。 而大型的企业防火墙通常会封锁这个端口。
