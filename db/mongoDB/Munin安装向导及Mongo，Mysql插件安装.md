一、前言：

Munin是通过客户端－服务器架构收集数据并将其图形化的工具。Munin允许你跟踪你的主机的运行记录，就是所谓的‘节点’，然后将它们发送到中央服务器，随后你就能在这里以图像形式展示它们。

二、环境：
   
①、系统：Centos5.6

②、Mysql：5.5.x，自编译

③、Munin：1.4.5

三、准备工作:
 
①、升级yum源：

    wget http://archive.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
    rpm -Uvh epel-release-5-4.noarch.rpm

这样在yum list中包含最新的Munin软件包，使用yum安装：

四、服务端安装配置：

    yum -y install munin munin-common munin-node httpd

安装完毕。

②、配置httpd：

    Munin安装将它的配置文件放在目录/etc/munin下，我们从服务端开始。
    在/etc/httpd/conf/httpd.conf中创建一个虚拟主机可以用来图形化显示我们的节点状态：

    <VirtualHost *:80>
         ServerAdmin webmaster@localhost
         ServerName munin.example.com
         DocumentRoot /var/www/html/munin
         <Directory />
             Options FollowSymLinks
             AllowOverride None
         </Directory>
         LogLevel notice
         CustomLog /var/log/apache2/munin.access.log combined
         ErrorLog /var/log/apache2/munin.error.log
         ServerSignature On
    </VirtualHost>

为httpd设置访问用户：

    $ htpasswd -nbm myName myPassword
    myName:$apr1$r31.....$HqJZimcKQFAMYayBlzkrA/

-nbm是使用md5加密。

  ③、munin配置：

最后，我们也必须在munin.conf文件中定义所有将向服务器发送报告的节点主机，命令是：

    [hostname.example.com]
    address 10.0.0.1
    use_node_name yes

括号中是每个节点的名字，后面是它的IP地址，use_node_name命令控制munin命名节点的方式，如果后面跟的参数为yes就是用括号中的值来命名，如果是no则将执行一个DNS查询。
至此，服务端已经配置好了
启动：

    /etc/init.d/httpd restart

五、客户端节点配置：

①、安装

    yum -y munin-common munin-node

   客户端主要的配置文件是/etc/munin/munin-node.conf文件，大多数配置信息都不需要改变，但是你需要更改allow选项，它控制哪一个主机能访问munin和检索统计。我们用IP地址来配置munin服务器，例如：

    allow ^10\.0\.0\.100$

正如你看到的，IP地址必须用perl常用格式来输入。如果你的munin服务器不只一台，那么你可以用多行允许命令来定义它们。

②、启动：

    /etc/init.d/munin-node restart

过一分钟后就可以访问了。
地址：http://ip/munin