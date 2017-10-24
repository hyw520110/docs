<p style="text-align:center;">Ubuntu14.04安装分布式存储sheepdog+zookeeper</p>
<p>牧羊犬(Sheepdog) 是由NTT的3名日本研究员开发的开源项目，提供分布式存储管理功能。牧羊犬提供高可用性的KVM提供块级存储卷类似亚马逊电子交易系统（弹性块存储虚拟机）的客户机。目前国内阿里等一些大公司在使用。</p>
<p>一、sheepdog架构图</p>
<p><img onload="if(this.width>650) this.width=650;" alt="" src="http://img.my.csdn.net/uploads/201211/06/1352206398_6072.jpg" style="width:556px;height:233px;" height="296" width="580"></p>
<p>如上图：</p>
<p>采用无中心节点的全对称架构，无单点故障，存储容量和性能可线性扩展；</p>
<p>新增节点通过简单配置可自动加入（IP:PORT），数据自动实现负载均衡；</p>
<p>节点故障时，数据可自动恢复；</p>
<p>直接支持QEMU/KVM应用；</p>
<p>二、数据具体存储方式</p>
<p><img onload="if(this.width>650) this.width=650;" alt="" src="http://img.my.csdn.net/uploads/201211/06/1352206414_1337.jpg" height="267" width="533"></p>
<p>如上图：</p>
<p>以VDI Object存储VM数据，向用户暴露的是一个块设备；</p>
<p>包含4种数据对象：VDI、Data Object、属性对象和用于快照的VM实时状态数据对象；</p>
<p>以4M的小文件方式实现OBS，但很容易基于此扩展，如使用使用库替代4M的小文件；</p>
<p>下面我们来具体搭建下，我们将采用sheepdog+zookeeper方式。</p>
<p>环境介绍：</p>
<p>系统：Ubuntu14.04</p>
<p>软件：sheepdog，zookeeper</p>
<p>我们这次采用的是github上的源码下来直接编译制作成deb包来进行安装的。</p>
<pre class="brush:bash;toolbar:false">1.获取sheepdog源码：
root@node1:~#&nbsp;git&nbsp;clone&nbsp;https://github.com/sheepdog/sheepdog.git&nbsp;sheepdog-github
2.切换到最稳定版本0.7.6：
root@node1:~#&nbsp;cd&nbsp;sheepdog-github/
root@node1:~#&nbsp;git&nbsp;checkout&nbsp;v0.7.6
4.执行autogen.sh生成configure，在此之前，可能需要安装依赖：
root@node1:~#&nbsp;apt-get&nbsp;install&nbsp;autoconf&nbsp;libtool&nbsp;make&nbsp;pkg-config
root@node1:~#&nbsp;./autogen.sh
5.开始编译，sheepdog本身依赖于corosync、zookeeper等集群管理工具，由于我们制作deb包，还依赖于debian的一些工具：
root@node1:~#&nbsp;apt-get&nbsp;install&nbsp;liburcu-dev&nbsp;corosync&nbsp;corosync-dev&nbsp;zookeeper&nbsp;zookeeperd&nbsp;libzookeeper-mt-dev
root@node1:~#&nbsp;./configure&nbsp;--enable-zookeeper
root@node1:~#&nbsp;apt-get&nbsp;install&nbsp;debhelper&nbsp;dh-autoreconf&nbsp;devscripts
root@node1:~#&nbsp;make&nbsp;deb
6.开始安装sheepdog：
root@node1:~#&nbsp;cd&nbsp;..
root@node1:~#&nbsp;dpkg&nbsp;-i&nbsp;sheepdog_0.7.6-1_amd64.deb
7.至此sheepdog已经安装完成，如果你要把这个deb包拷贝到别的机器（node2）进行安装那么就必须在那台机器上安装相应的依赖包：
root@node1:~#&nbsp;apt-get&nbsp;install&nbsp;zookeeperd&nbsp;libcfg4&nbsp;libcfg6&nbsp;libcpg4&nbsp;libzookeeper-mt2&nbsp;libcoroipcc4
特别注意：在ubuntu14.04上找不到libcfg4的包，因为libcfg4是12.04上的包，需要在/etc/apt/sources.list里面添加一条
deb&nbsp;http://cz.archive.ubuntu.com/ubuntu&nbsp;precise&nbsp;main
8.配置zookeeper：
一般正式环境使用zookeeper作为sheepdog集群的管理工具，需要相关配置。如果只是单节点试用，可以不配置zookeeper。
先修改myid文件，你配置第几个节点就写几，内容是1-255；
root@node1:~#&nbsp;vi&nbsp;/etc/zookeeper/conf/myid
9.然后修改zoo.cfg文件，主要填写各个zookeeper节点的信息：
root@node1:~#&nbsp;vi&nbsp;/etc/zookeeper/conf/zoo.cfg
server.1=10.0.0.18:2888:3888
server.2=10.0.0.19:2889:3889
我有两个节点所有就只有两个，这格式就是server.myid=ip+端口号；
其中第一个端口用来集群成员的信息交换，第二个端口是在leader挂掉时专门用来进行选举leader所用。
10.重启下zookeeper；
root@node1:~#&nbsp;service&nbsp;zookeeper&nbsp;restart
11.启动sheepdog并挂载磁盘；
root@node1:~#&nbsp;mkdir&nbsp;/mnt/sheepdog
root@node1:~#&nbsp;mount&nbsp;-t&nbsp;ext4&nbsp;-o&nbsp;noatime,barrier=0,user_xattr,data=writeback&nbsp;/dev/sdb1&nbsp;/mnt/sheepdog
root@node1:~#&nbsp;useradd&nbsp;sheepdog
root@node1:~#&nbsp;chown&nbsp;-R&nbsp;sheepdog:sheepdog&nbsp;/mnt/sheepdog
root@node1:~#&nbsp;sheep&nbsp;/mnt/sheepdog&nbsp;-c&nbsp;zookeeper:10.0.0.18:2181,10.0.0.19:2181</pre>
<p>Sheepdog常用命令</p>
<p>设置副本数：</p>
<p><span class="crayon-h"></span><span class="crayon-e">dog </span><span class="crayon-e">cluster </span><span class="crayon-r">format</span><span class="crayon-h"> </span><span class="crayon-o">--</span><span class="crayon-v">copies</span><span class="crayon-o">=</span><span class="crayon-cn">3</span>&nbsp;&nbsp;&nbsp;&nbsp; //copies副本数</p>
<p>查看sheepdog节点：两种方式都可以<br></p>
<p><img onload="if(this.width>650) this.width=650;" src="/e/u261/themes/default/images/spacer.gif" style="background:url(&quot;/e/u261/lang/zh-cn/images/localimage.png&quot;) no-repeat center;border:1px solid #ddd;" alt="spacer.gif"><a href="http://s3.51cto.com/wyfs02/M01/54/9F/wKioL1SH-03gDmDRAACvCXOKflk085.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/54/9F/wKioL1SH-03gDmDRAACvCXOKflk085.jpg" title="QQ图片20141210154604.jpg" alt="wKioL1SH-03gDmDRAACvCXOKflk085.jpg"></a></p>
<p>本文出自 “<a href="http://sangh.blog.51cto.com">态度决定一切</a>” 博客，请务必保留此出处<a href="http://sangh.blog.51cto.com/6892345/1588341">http://sangh.blog.51cto.com/6892345/1588341</a></p>
