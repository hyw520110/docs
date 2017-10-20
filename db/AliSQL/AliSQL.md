# 前言

CentOS/RHEL Linux 发行版以稳定性著称，所有的软件都要尽可能 stable，导致的一个结果就是基础软件的版本非常的低，比如 CentOS 6.7（15年发布） 中 gcc 版本还是 4.4.7（12年的版本）。这对开发来说就不是很友好，比如我们想用 C++ 11 中的某个特性，就必须自己编译一个高版本的 gcc 出来，但是这会有另外一个问题，开发环境不好维护，如果自己有多台电脑或者多个人合作的项目，每台机器上都要自己编一份，维护起来就比较麻烦。
那么有没有法子像正常的安装 rpm 包一样，yum install 一个呢？有：
自己打个 rpm 包，维护个 yum 源，这个代价太大 ==!；
用别人提供的 rpm 包。
本文介绍的就是第二种，推荐 devtoolset + scl，也是绝配。
devtoolset 是由 Linux @ CERN 维护的，scl 是方便 RedHat Software Collections 软件包使用的工具。

RedHat 推出 Software Collections 的目的就是为了解决前面说的问题，想在 RedHat 系统下能使用新版本的工具，让同一个工具（如gcc）的不同版本能在系统中共存，在需要的时候切换到对应的版本中，是不是有点像 rvm(ruby) 或者 nvm(node)呢，不过这个可是系统级别的哦，对所有软件都适用。

## 编译环境准备

关于 devtoolset 的安装，Software Collections 官方有一个[指导](https://www.softwarecollections.org/en/scls/rhscl/devtoolset-3/)，这里介绍的也差不多，只不过会更详细一些。

1. 安装 scl-utils，yum install scl-utils，如果你的 yum 源里找不到这个包的话，可以这样


	rpm -ivh "http://vault.centos.org/6.6/updates/x86_64/Packages/scl-utils-20120927-27.el6_6.x86_64.rpm"
2. 安装 devtoolset-3 yum 源

	rpm -ivh "https://www.softwarecollections.org/repos/rhscl/devtoolset-3/epel-6-x86_64/noarch/rhscl-devtoolset-3-epel-6-x86_64-1-2.noarch.rpm"

	centos7
	rpm -ivh "https://www.softwarecollections.org/repos/rhscl/devtoolset-3/epel-7-x86_64/noarch/rhscl-devtoolset-3-epel-7-x86_64-1-2.noarch.rpm"

3. 安装需要的 rpm 包，官方给的是 yum install devtoolset-3，这样会安装 devtoolset-3 源里的所有 rpm 包，完全没必要，如果我们需要 gcc 的话，只需要这样：

	yum install devtoolset-3-gcc devtoolset-3-gcc-c++ devtoolset-3-gdb
4. 激活 devtoolset-3
 
	scl enable devtoolset-3 bash
然后 gcc --version 就会看到已经变成 4.9 啦，或者可以这样

	 scl enable devtoolset-3 "gcc --version"
关于使用，这里多说一点，scl-utils 只是方便 Software Collections 使用，比如要查看当前安装了哪些 Software Collections，可以 scl --list，我们其实可以安全不用这个工具。devtoolset-3 中的 gcc 安装在 /opt/rh/devtoolset-3/root/usr/bin/gcc，我们可以

	export CC=/opt/rh/devtoolset-3/root/usr/bin/gcc
或者直接 source 环境变量

	source /opt/rh/devtoolset-3/enable
scl enable 命令也是 source 这个 enable 文件，只不是临时的，只对对当前命令有效。
Software Collections 官网除了 devtoolset-3 外，还有大把其它的[collections](https://www.softwarecollections.org/en/scls/)，如 ruby2.2、python3.4 等，有需要的自己安装，方法和 devtoolset-3 差不多。

## 安装

CentOS yum 源里的 gcc 版本是 4.4 的，不满足需求，可以通过devtoolset 来安装高版本 gcc，devtoolset 目前最新套装是 devtoolset-4，包含 gcc 5.2。

	 yum install centos-release-scl -y
	 yum install devtoolset-4-gcc-c++ devtoolset-4-gcc -y
	 yum install cmake git -y
	 yum install ncurses-devel openssl-devel bison -y

GitHub clone 代码
 	
	git clone https://github.com/alibaba/AliSQL.git

cmake 配置,在配置前，要先设置下环境变量，这样才能用到 devtoolset-4 套装里的gcc。

	scl enable devtoolset-4 bash
	cmake . -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX="/opt/alisql" -DWITH_EMBEDDED_SERVER=0  -DWITH_EXTRA_CHARSETS=all -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_CSV_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1  -DWITH_BLACKHOLE_STORAGE_ENGINE=1  -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1     -DWITH_TOKUDB_STORAGE_ENGINE=1 

编译安装
 
	make -j4 && make install

配置
	
	cd /opt/alisql
	./scripts/mysql_install_db  --user=root --basedir=/opt/alisql --datadir=/opt/alisql/data/mysqldb
	chown -R root:root /opt/alisql	

	cp ./support-files/my-default.cnf /etc/my.cnf
	vi /etc/my.cnf
	basedir = /opt/alisql
	datadir = /opt/alisql/data/mysqldb
	port = 3306
	server_id = 95
	user=root
	
	cp ./support-files/mysql.server /etc/init.d/mysqld   
	chmod +x /etc/init.d/mysqld 
	chkconfig --add mysqld
	chkconfig --level 35 mysqld on
	service mysqld start

	echo "export PATH=$PATH:/opt/alisql/bin">>/etc/profile   
	source /etc/profile

	mysql -uroot -p
	use mysql
	select user,password,host from user;    
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'asdf1234' WITH GRANT OPTION;
	-- UPDATE user SET Host='%' WHERE User='root' AND Host='localhost' LIMIT 1;
	update user set password =password('asdf1234') where user='root' and host='%'
	FLUSH PRIVILEGES;
	exit
	mysql -uroot -p123456
