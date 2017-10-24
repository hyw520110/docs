<h2 style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span id="Zookeeper">Zookeeper简介</span></h2>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;">关于zk的介绍, zk的paxos算法, 网上已经有各位大神在写了,</p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;">本文主要写我在搭建过程中的几个极有可能遇到的坑.</p>
<h2 style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span id="Zookeeper-2">Zookeeper部署中的坑</span></h2>
<h3 style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span id="i">坑之一</span></h3>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;">Error contacting service. It is probably not running</p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span style="font-family:SimSun;background:#FFFFFF;">在配置完</span><span style="font-family:Calibri;background:#FFFFFF;">zookeeper</span><span style="font-family:SimSun;background:#FFFFFF;">集群后</span><span style="font-family:Calibri;background:#FFFFFF;">,</span><span style="font-family:SimSun;background:#FFFFFF;">三个节点</span><span style="font-family:Calibri;background:#FFFFFF;">,</span><span style="font-family:SimSun;background:#FFFFFF;">分别启动三个节点如下</span><span style="font-family:Calibri;background:#FFFFFF;">:</span></p>
<p style="margin:0in;line-height:21pt;font-family:Tahoma;font-size:15.75pt;"><span style="color:#000000;background:#FFFFFF;">[root@master bin]#&nbsp;</span><span style="color:#ad0000;background:#FFFFFF;">zkServer.sh start</span></p>
<p style="margin:0in;line-height:21pt;font-family:Tahoma;font-size:15.75pt;color:#000000;"><span style="background:#FFFFFF;">JMX enabled by default</span></p>
<p style="margin:0in;line-height:21pt;font-family:Tahoma;font-size:15.75pt;color:#000000;"><span style="background:#FFFFFF;">Using config: /usr/local/zk/bin/../conf/zoo.cfg</span></p>
<p style="margin:0in;line-height:21pt;font-family:Tahoma;font-size:15.75pt;color:#000000;"><span style="background:#FFFFFF;">Starting zookeeper … STARTED</span></p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span style="font-family:SimSun;background:#FFFFFF;">在查看</span><span style="font-family:Calibri;background:#FFFFFF;">zookeeper</span><span style="font-family:SimSun;background:#FFFFFF;">状态时遇到</span></p>
<p style="margin:0in;line-height:21pt;font-family:Calibri;font-size:10.5pt;color:#555555;"><span style="background:#FFFFFF;">[root@master bin]# zkServer.sh status</span></p>
<p style="margin:0in;line-height:21pt;font-family:Calibri;font-size:10.5pt;color:#555555;"><span style="background:#FFFFFF;">JMX enabled by default</span></p>
<p style="margin:0in;line-height:21pt;font-family:Calibri;font-size:10.5pt;color:#555555;"><span style="background:#FFFFFF;">Using config: /usr/local/zk/bin/../conf/zoo.cfg</span></p>
<p style="margin:0in;line-height:21pt;font-family:Calibri;font-size:10.5pt;color:#555555;"><span style="background:#FFFFFF;">Error contacting service. It is probably not running.</span></p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span style="font-family:SimSun;background:#FFFFFF;">而其他两个节点却是现实正常</span><span style="font-family:Calibri;background:#FFFFFF;">;</span></p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span style="font-family:SimSun;background:#FFFFFF;" lang="zh-cn" xml:lang="zh-cn">分析原因并解决</span><span style="font-family:Calibri;background:#FFFFFF;" lang="en-us" xml:lang="en-us">:</span></p>
<h4 style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span id="i-2"><span style="color:#339966;"><span style="font-family:SimSun;background:#FFFFFF;" lang="zh-cn" xml:lang="zh-cn">原因之一</span></span></span></h4>
<p style="margin:0in;line-height:21pt;font-family:SimSun;font-size:11pt;"><span style="color:#339966;"><span lang="zh-cn" xml:lang="zh-cn">其原因是在编辑</span><span lang="en-us" xml:lang="en-us">zoo.cfg</span><span lang="zh-cn" xml:lang="zh-cn">配置文件时，指定了</span><span lang="en-us" xml:lang="en-us">log</span><span lang="zh-cn" xml:lang="zh-cn">的输出目录，但是却未创建。</span></span></p>
<p style="margin:0in;line-height:21pt;font-family:SimSun;font-size:11pt;">因此需要按照里面指定的目录进行创建。</p>
<table width="283" cellpadding="0" cellspacing="0" style="height:49px;">
 <tbody>
  <tr>
   <td style="vertical-align:top;padding:2pt 3pt;border:1pt solid rgb(163,163,163);" width="1"><p style="margin:0in;font-family:Calibri;font-size:11pt;" lang="zh-cn" xml:lang="zh-cn">mkdir /tmp/zookeeper/log</p></td>
  </tr>
 </tbody>
</table>
<h4 style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span id="i-3"><span style="color:#ff0000;"><span style="font-family:SimSun;background:#FFFFFF;" lang="zh-cn" xml:lang="zh-cn">原因之二</span></span></span></h4>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span style="color:#ff0000;"><span style="font-family:SimSun;background:#FFFFFF;">最后检查配置</span><span style="font-family:Calibri;background:#FFFFFF;">zoo.cfg</span><span style="font-family:SimSun;background:#FFFFFF;">配置发现是该节点的主机名写错了</span><span style="font-family:Calibri;background:#FFFFFF;">;</span><span style="font-family:SimSun;background:#FFFFFF;">先停止三个节点</span><span style="font-family:Calibri;background:#FFFFFF;">zookeeper</span><span style="font-family:SimSun;background:#FFFFFF;">服务</span><span style="font-family:Calibri;background:#FFFFFF;">,</span><span style="font-family:SimSun;background:#FFFFFF;">逐一的修改节点上</span><span style="font-family:Calibri;background:#FFFFFF;">zoo.cfg</span><span style="font-family:SimSun;background:#FFFFFF;">配置文件</span><span style="font-family:Calibri;background:#FFFFFF;">,</span><span style="font-family:SimSun;background:#FFFFFF;">在逐一的启动</span><span style="font-family:Calibri;background:#FFFFFF;"> ,</span><span style="font-family:SimSun;background:#FFFFFF;">结果显示正常</span><span style="font-family:Calibri;background:#FFFFFF;">;</span></span></p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><br></p>
<h4 style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span><span style="color:#ff0000;"><span style="font-family:SimSun;background:#FFFFFF;" lang="zh-cn" xml:lang="zh-cn">原因之三<br></span></span></span></h4>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><span style="color:#ff0000;"><span style="font-family:SimSun;background:#FFFFFF;"></span><span style="font-family:Calibri;background:#FFFFFF;">配置集群时数据目录下的myid文件写错，修改为正确的数值即可<br></span></span></p>
<p style="margin:0in;line-height:21pt;font-size:10.5pt;color:#555555;"><br><span style="color:#ff0000;"><span style="font-family:Calibri;background:#FFFFFF;"></span></span>PS: zk类的安装搭建过程中, 如果报错, 一定要把status中的错误贴出来, 其它的信息不容易找到答案.</p>
<p><br></p>
