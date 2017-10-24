<p>相关视频可以参考：http://edu.51cto.com/course/course_id-2374.html<br></p>
<p>部署的架构模式<br></p>
<p><img onload="if(this.width>650) this.width=650;" src="http://y.photo.qq.com/img?s=P5J4TjvoW&amp;l=y.jpg" alt=""></p>
<p>安装步骤：</p>
<p><br></p>
<p>/******<br>*zookeeper的集群模式的部署方式<br>*<br>*<br>*************/<br><br>1.上传zookeeper 3.3.6 到 /opt/hadoop/zookeeper 目录下<br><br>2.解压文件 tar xzvf zookeeper-3.3.6.tar.gz<br><br>3.进入 /opt/hadoop/zookeeper/zookeeper-3.3.6/conf目录<br><br>4,cp zoo_sample.cfg zoo.cfg <br><br>5.修改 zoo.cfg文件<br><br>emacs -nw zoo.cfg<br>修改<br>dataDir=/tmp/zookeeper <br>为<br>dataDir=/opt/hadoop/zookeeper/data<br><br>增加<br>server.1=hadoopdn2:2888:3888&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #第一个端口用于leader的链接，第二个端口用于leader的选举<br>server.2=hadoopdn3:2888:3888<br>server.3=JobTracker:2888:3888 <br><br><br>保存<br><br>6.在/opt/hadoop/zookeeper/ 下面创建data目录<br>&nbsp;&nbsp; &nbsp;创建文件<br>&nbsp;&nbsp; &nbsp;touch /opt/hadoop/zookeeper/data/myid</p>
<p>&nbsp;&nbsp;&nbsp; 先在在hadoopdn1上面，对应的serverid为1 将1写进 myid文件<br><br>7.启动 zkServer.sh<br><br>cd /opt/hadoop/zookeeper/zookeeper-3.3.6/bin<br><br>./zkServer.sh&nbsp; start<br>./zkServer.sh&nbsp; status 查看启动状态<br><br>如果有异常，请查看当前目录下的zookeeper.out</p>
<p><br></p>
<p>其他的2台机器安装类似，需要将对应的serverid写进自己的myid文件里面！！</p>
<p><br></p>
