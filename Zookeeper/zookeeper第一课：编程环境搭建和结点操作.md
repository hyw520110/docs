<div class="Section0">
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"><br> &nbsp; &nbsp;Zookeeper<span style="font-family:'宋体';">是很多开源项目的基础架构，比如</span><span style="font-family:'times new roman';">HBase/Hadoop/Solr</span><span style="font-family:'宋体';">……学习</span><span style="font-family:'times new roman';">Zookeeper</span><span style="font-family:'宋体';">能更好地了解这些项目的基本原理。毕竟熟悉程度决定使用高度。</span><span style="font-family:'times new roman';">Zookeeper</span><span style="font-family:'宋体';">的编程环境搭建非常容易。在这里记录一下在</span><span style="font-family:'times new roman';">win7</span><span style="font-family:'宋体';">下搭建</span><span style="font-family:'times new roman';">Zookeeper</span><span style="font-family:'宋体';">编程环境的过程。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h3 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'宋体';">一、下载<span style="font-family:'times new roman';">Zookeeper</span></span><span style="font-weight:bold;font-size:21px;font-family:'宋体';"></span></h3>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">地址</span><a href="http://download.nextag.com/apache/zookeeper/" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://download.nextag.com/apache/zookeeper/</span></a><span style="font-size:14px;font-family:'宋体';"> 。我下载的是<span style="font-family:'times new roman';">zookeeper-3.4.5 </span><span style="font-family:'宋体';">。个人觉得开发的时候不要用最新的，除非对该开源项目已经非常熟悉，不怕踩坑。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h3 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'宋体';">二、服务端环境搭建</span><span style="font-weight:bold;font-size:21px;font-family:'宋体';"></span></h3>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">首先把下载到的<span style="font-family:'times new roman';">zookeeper</span><span style="font-family:'宋体';">解压，我解压到</span><span style="font-family:'times new roman';">D:\source_code\zookeeper-3.4.5 </span><span style="font-family:'宋体';">。解压后，目录如下：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M01/25/D1/wKioL1NnHtnAqyjFAAH9xLwmr-w691.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/25/D1/wKioL1NnHtnAqyjFAAH9xLwmr-w691.jpg" title="2014-5-5_Zookeeper学习第一课：环境搭建和节点操作 2-394.png" alt="wKioL1NnHtnAqyjFAAH9xLwmr-w691.jpg"></a></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">然后把<span style="font-family:'times new roman';">conf\zoo_sample.cfg</span><span style="font-family:'宋体';">修改成</span><span style="font-family:'times new roman';">zoo.cfg</span><span style="font-family:'宋体';">，打开</span><span style="font-family:'times new roman';">zoo.cfig</span><span style="font-family:'宋体';">，内容如下：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M02/25/D1/wKioL1NnHuyTZpS6AAIQyqEpCmE855.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M02/25/D1/wKioL1NnHuyTZpS6AAIQyqEpCmE855.jpg" title="2014-5-5_Zookeeper学习第一课：环境搭建和节点操作 2-446.png" alt="wKioL1NnHuyTZpS6AAIQyqEpCmE855.jpg"></a></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">把<span style="font-family:'times new roman';">dataDir=/tmp/zookeeper</span><span style="font-family:'宋体';">修改成</span><span style="font-family:'times new roman';">dataDir=D:\\zk_tmp (zookeeper</span><span style="font-family:'宋体';">一般跑在</span><span style="font-family:'times new roman';">linux</span><span style="font-family:'宋体';">服务器。</span><span style="font-family:'times new roman';">)</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">至于<span style="font-family:'times new roman';">zoo.cfg</span><span style="font-family:'宋体';">里面的参数及其意义，我们先不作了解。主要是因为我现在也不了解。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:56px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">然后转到<span style="font-family:'times new roman';">bin\</span><span style="font-family:'宋体';">下面，启动</span><span style="font-family:'times new roman';">zookeeper</span><span style="font-family:'宋体';">。启动方法如下：</span><span style="font-family:'times new roman';">shift+</span><span style="font-family:'宋体';">鼠标右键，然后打开命令窗口。然后在命令窗口中输入</span><span style="font-family:'times new roman';">zkServer.cmd</span><span style="font-family:'宋体';">，回车就</span><span style="font-family:'times new roman';">OK</span><span style="font-family:'宋体';">了。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M01/25/D1/wKiom1NnHyOgIiCuAAEM3vyB0U0681.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/25/D1/wKiom1NnHyOgIiCuAAEM3vyB0U0681.jpg" title="2014-5-5_Zookeeper学习第一课：环境搭建和节点操作 2-641.png" alt="wKiom1NnHyOgIiCuAAEM3vyB0U0681.jpg"></a></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">接下来，用同样的方法</span><span style="font-size:14px;font-family:'宋体';">再打开一个命令行窗口，执行命令：</span><span style="color:#333333;font-weight:normal;font-style:normal;font-size:13px;font-family:verdana;background:#ffffff;"> netstat <span style="font-family:'宋体';">&#xfffd; </span><span style="font-family:verdana;">ano </span></span><span style="color:#333333;font-weight:normal;font-style:normal;font-size:13px;font-family:'宋体';background:#ffffff;"></span><span style="font-weight:normal;font-style:normal;font-size:14px;font-family:'宋体';background:#ffffff;">查看监听的端口<span style="font-family:verdana;">(</span><span style="font-family:'宋体';">默认是</span><span style="font-family:verdana;">2181)</span><span style="font-family:'宋体';">及地址</span></span><span style="color:#333333;font-weight:normal;font-style:normal;font-size:14px;font-family:'宋体';background:#ffffff;">，我电脑上的结果如下：可以看到地址是<span style="font-family:verdana;">0.0.0.0:2181,</span><span style="font-family:'宋体';">而不是</span><span style="font-family:verdana;">127.0.0.1:2181</span></span><span style="color:#333333;font-weight:normal;font-style:normal;font-size:14px;font-family:'宋体';background:#ffffff;"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M00/25/D1/wKiom1NnHy2jrb3lAAEgC8jjwBI615.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/25/D1/wKiom1NnHy2jrb3lAAEgC8jjwBI615.jpg" title="2014-5-5_Zookeeper学习第一课：环境搭建和节点操作 2-754.png" alt="wKiom1NnHy2jrb3lAAEgC8jjwBI615.jpg"></a></p>
 <h3 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'宋体';">三、客户端环境搭建</span><span style="font-weight:bold;font-size:21px;font-family:'宋体';"></span></h3>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">在<span style="font-family:'times new roman';">eclipse</span><span style="font-family:'宋体';">中创建新的</span><span style="font-family:'times new roman';">java project,</span><span style="font-family:'宋体';">取名：</span><span style="font-family:'times new roman';">zookeeper_learning</span><span style="font-family:'宋体';">，把项目转换成</span><span style="font-family:'times new roman';">maven</span><span style="font-family:'宋体';">项目，然后在</span><span style="font-family:'times new roman';">pom.xml</span><span style="font-family:'宋体';">中加入如下的</span><span style="font-family:'times new roman';">dependency</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">dependency</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="font-size:14px;font-family:consolas;"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">groupId</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="color:#000000;font-size:14px;font-family:consolas;">org.apache.zookeeper</span><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;/</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">groupId</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="font-size:14px;font-family:consolas;"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">artifactId</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="color:#000000;text-decoration:underline;font-size:14px;font-family:consolas;">zookeeper</span><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;/</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">artifactId</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="font-size:14px;font-family:consolas;"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#000000;font-size:14px;font-family:consolas;"></span><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">version</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="color:#000000;font-size:14px;font-family:consolas;">3.4.5</span><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;/</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">version</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="font-size:14px;font-family:consolas;"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="color:#008080;font-size:14px;font-family:consolas;">&lt;/</span><span style="color:#3f7f7f;font-size:14px;font-family:consolas;">dependency</span><span style="color:#008080;font-size:14px;font-family:consolas;">&gt;</span><span style="color:#008080;font-size:14px;font-family:consolas;"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">然后，创建<span style="font-family:consolas;">Java</span><span style="font-family:'宋体';">类如下：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">(<span style="font-family:'宋体';">代码参看</span></span><a href="http://blog.csdn.net/shenlan211314/article/details/6187037" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://blog.csdn.net/shenlan211314/article/details/6187037</span></a><span style="font-size:14px;font-family:'宋体';">，略有修改<span style="font-family:consolas;">)</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-align:justify;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <pre class="brush:java;toolbar:false;">package zookeeper_learning;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
publicclass ZkClient {
publicstaticvoid main(String[] args) {
try {
ZooKeeper zk=new ZooKeeper("0.0.0.0:2181", 3000, new Watcher(){
@Override
publicvoid process(WatchedEvent arg0) {
System.out.println("watch "+arg0);
}
});
System.out.println("/n1. 创建 ZooKeeper 节点 (znode ： zoo2, 数据： myData2 ，权限： OPEN_ACL_UNSAFE ，节点类型： Persistent");
zk.create("/zoo2","myData2".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
System.out.println("/n2. 查看是否创建成功： ");
System.out.println(new String(zk.getData("/zoo2",false,null)));
System.out.println("/n3. 修改节点数据 ");
zk.setData("/zoo2", "shenlan211314".getBytes(), -1);
System.out.println("/n4. 查看是否修改成功： ");
System.out.println(new String(zk.getData("/zoo2", false, null)));
System.out.println("/n5. 删除节点 ");
zk.delete("/zoo2", -1);
System.out.println("/n6. 查看节点是否被删除： ");
System.out.println(" 节点状态： ["+zk.exists("/zoo2", false)+"]");
zk.close();
} catch (Exception e) {
e.printStackTrace();
}
}
}</pre>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">执行结果如下则正常：</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M02/25/D1/wKiom1NnH0rj3uK6AAE-VBdoV1k294.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M02/25/D1/wKiom1NnH0rj3uK6AAE-VBdoV1k294.jpg" title="2014-5-5_Zookeeper学习第一课：环境搭建和节点操作 2-2417.png" alt="wKiom1NnH0rj3uK6AAE-VBdoV1k294.jpg"></a></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">麻雀虽小，还是把<span style="font-family:consolas;">Zookeeper</span><span style="font-family:'宋体';">对结点的简单操作演练了一遍.</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
</div>
<p>本文出自 “<a href="http://sbp810050504.blog.51cto.com">每天进步一点点</a>” 博客，请务必保留此出处<a href="http://sbp810050504.blog.51cto.com/2799422/1406563">http://sbp810050504.blog.51cto.com/2799422/1406563</a></p>
