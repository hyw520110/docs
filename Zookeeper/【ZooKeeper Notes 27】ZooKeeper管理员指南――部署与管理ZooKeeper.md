<p><a href="http://cloud.github.com/downloads/nileader/ZooKeeper-Notes/%E3%80%90ZooKeeper%20Notes%2027%E3%80%91ZooKeeper%E7%AE%A1%E7%90%86%E5%91%98%E6%8C%87%E5%8D%97%E2%80%94%E2%80%94%E9%83%A8%E7%BD%B2%E4%B8%8E%E7%AE%A1%E7%90%86ZooKeeper.pdf" target="_blank">查看PDF版本</a></p> 
<p><span style="font-family: 'Comic Sans MS'; ">转载请注明：</span><a href="http://weibo.com/nileader" target="_blank"><span style="font-family: 'Comic Sans MS'; ">@ni掌柜</span></a><span style="font-family: 'Comic Sans MS'; "> nileader@gmail.com</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">本文以ZooKeeper3.4.3版本的官方指南为基础：</span><a href="http://zookeeper.apache.org/doc/r3.4.3/zookeeperAdmin.html"><span style="font-family: 'Comic Sans MS'; ">http://zookeeper.apache.org/doc/r3.4.3/zookeeperAdmin.html</span></a><span style="font-family: 'Comic Sans MS'; ">，补充一些作者运维实践中的要点，围绕ZK的部署和运维两个方面讲一些管理员需要知道的东西。本文并非一个ZK搭建的快速入门，关于这方面，可以查看</span><a href="http://nileader.blog.51cto.com/1381108/795230"><span style="font-family: 'Comic Sans MS'; ">《ZooKeeper快速搭建》</span></a>。</p> 
<p><strong><span style="font-size: 36px; ">1.部署</span></strong></p> 
<p><span style="font-family: 'Comic Sans MS'; ">本章节主要讲述如何部署ZooKeeper，包括以下三部分的内容：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">1. 系统环境</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">2. 集群模式的配置</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">3. 单机模式的配置</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">系统环境和集群模式配置这两节内容大体讲述了如何部署一个能够用于生产环境的ZK集群。如果仅仅是想在单机上将ZK运行起来，进行一些开发与测试，那么第三部分或许是你的菜。</span></p> 
<p><span style="font-size: 28px; "><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 26px; "><strong>1.1系统环境</strong></span></span></span></p> 
<p><span style="font-size: 22px; "><strong><span style="font-family: 'Comic Sans MS'; ">1.1.1平台支持</span></strong></span></p> 
<table width="600" border="1" cellspacing="0" cellpadding="0"> 
 <tbody> 
  <tr> 
   <td valign="top" width="43"> <p align="center"><span style="font-family: 'Comic Sans MS'; "><strong>平 台</strong></span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">运行client</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">运行server</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">开发环境</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">生产环境</span></p> </td> 
  </tr> 
  <tr> 
   <td valign="top" width="43"> <p align="center"><span style="font-family: 'Comic Sans MS'; "><strong>GNU/Linux</strong></span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
  </tr> 
  <tr> 
   <td valign="top" width="43"> <p align="center"><span style="font-family: 'Comic Sans MS'; "><strong>Sun Solaris</strong></span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
  </tr> 
  <tr> 
   <td valign="top" width="43"> <p align="center"><span style="font-family: 'Comic Sans MS'; "><strong>FreeBSD</strong></span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="110"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">&#xfffd;，对nio的支持不好</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
  </tr> 
  <tr> 
   <td valign="top" width="43"> <p align="center"><span style="font-family: 'Comic Sans MS'; "><strong>Win32</strong></span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">&#xfffd;</span></p> </td> 
  </tr> 
  <tr> 
   <td valign="top" width="43"> <p align="center"><span style="font-family: 'Comic Sans MS'; "><strong>MacOSX</strong></span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">√</span></p> </td> 
   <td valign="top" width="98"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">&#xfffd;</span></p> </td> 
  </tr> 
 </tbody> 
</table> 
<p><span style="font-family: 'Comic Sans MS'; "><strong>注</strong>：运行client是指作为客户端，与server进行数据通信，而运行server是指将ZK作为服务器部署运行。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">1.1.2软件环境</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">ZooKeeper Server是一个Java语言实现的分布式协调服务框架，因此需要6或更高版本的JDK支持。集群的机器数量方面，宽泛的讲，其实是任意台机器都可以部署运行的，注意，这里并没有说一定要奇数台机器哦！通常情况下，建议使用3台独立的Linux服务器构成的一个ZK集群。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">1.2集群模式的配置</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">为了确保ZooKeeper服务的稳定与可靠性，通常是搭建成一个ZK集群来对外提供服务。关于ZooKeeper，需要明确一个很重要的特性：集群中只要有过半的机器是正常工作的，那么整个集群对外就是可用的（本文下面就用“过半存活即可用”来代替这个特性吧^-^）。正是基于这个特性，建议是将ZK集群的机器数量控制为奇数较为合适。为什么选择奇数台机器，我们可以来看一下，假如是4台机器构成的ZK集群，那么只能够允许集群中有一个机器down掉，因为如果down掉2台，那么只剩下2台机器，显然没有过半。而如果是5台机器的集群，那么就能够对2台机器down掉的情况进行容灾了。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">你可以按照以下步骤来配置一个ZK机器，更多详细步骤请查看《</span><a href="http://nileader.blog.51cto.com/1381108/795230"><span style="font-family: 'Comic Sans MS'; ">ZooKeeper快速搭建</span></a><span style="font-family: 'Comic Sans MS'; ">》：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "> <strong>1</strong>. 安装JDK。相关链接：</span><a href="http://java.sun.com/javase/downloads/index.jsp"><span style="font-family: 'Comic Sans MS'; ">http://java.sun.com/javase/downloads/index.jsp</span></a><span style="font-family: 'Comic Sans MS'; "> </span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">2</span></strong><span style="font-family: 'Comic Sans MS'; ">. 设置Java heap 大小。避免内存与磁盘空间的交换，能够大大提升ZK的性能，设置合理的heap大小则能有效避免此类空间交换的触发。在正式发布上线之前，建议是针对使用场景进行一些压力测试，确保正常运行后内存的使用不会触发此类交换。通常在一个物理内存为4G的机器上，最多设置-Xmx为3G。 </span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">3</span></strong><span style="font-family: 'Comic Sans MS'; ">. 下载安装ZooKeeper，相关链接：</span><a href="http://zookeeper.apache.org/releases.html"><span style="font-family: 'Comic Sans MS'; ">http://zookeeper.apache.org/releases.html</span></a><span style="font-family: 'Comic Sans MS'; "> </span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">4</span></strong><span style="font-family: 'Comic Sans MS'; ">. 配置文件zoo.cfg。初次使用zookeeper，按照如下这个简单配置即可：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span class="attribute">tickTime</span><span>=</span><span class="attribute-value">2000</span><span>&nbsp;</span></span></li>
  <li><span><span class="attribute">dataDir</span><span>=/var/lib/zookeeper/&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">clientPort</span><span>=</span><span class="attribute-value">2181</span><span>&nbsp;</span></span></li>
  <li><span><span class="attribute">initLimit</span><span>=</span><span class="attribute-value">5</span><span>&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">syncLimit</span><span>=</span><span class="attribute-value">2</span><span>&nbsp;</span><span class="attribute">server.1</span><span>=</span><span class="attribute-value">zoo1</span><span>:2888:3888&nbsp;</span></span></li>
  <li><span><span class="attribute">server.2</span><span>=</span><span class="attribute-value">zoo2</span><span>:2888:3888&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">server.3</span><span>=</span><span class="attribute-value">zoo3</span><span>:2888:3888&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; ">本文后续章节会对这些参数进行详细的介绍，这里只是简单说几点：</span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;A</span></strong><span style="font-family: 'Comic Sans MS'; ">. 集群中的每台机器都需要感知整个集群是由哪几台机器组成的，在配置文件中，可以按照这样的格式，每行写一个机器配置：server.id=host:port:port. 关于这个id，我们称之为Server ID，标识host机器在集群中的机器序号，在每个ZK机器上，我们需要在数据目录（数据目录就是dataDir参数指定的那个目录）下创建一个myid文件，myid中就是这个Server ID数字。 </span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;B</span></strong><span style="font-family: 'Comic Sans MS'; ">. 在ZooKeeper的设计中，集群中任意一台机器上的zoo.cfg文件的内容都是一致的。因此最好是用SVN把这个文件管理起来，保证每个机器都能共享到一份相同的配置。 </span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">5</span></strong><span style="font-family: 'Comic Sans MS'; ">. 关于myid文件。myid文件中只有一个数字，即一个Server ID。例如，server.1 的myid文件内容就是“1”。注意，请确保每个server的myid文件中id数字不同，并且和server.id=host:port:port中的id一致。另外，id的范围是1~255。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "> <strong>6</strong>. 至此，配置文件基本ok，可以尝试使用如下命令来启动zookeeper了：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>$&nbsp;java&nbsp;-cp&nbsp;zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf&nbsp;\&nbsp;org.apache.zookeeper.server.quorum.QuorumPeerMainzoo.cfg&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; "><strong>注意</strong>，不同的ZK版本，依赖的log4j和slf4j版本也是不一样的，请看清楚自己的版本后，再执行上面这个命令。QuorumPeerMain类会启动ZooKeeper Server，同时，JMX MB也会被启动，方便管理员在JMX管理控制台上进行ZK的控制。这里有对ZK JMX的详细介绍：</span><a href="http://zookeeper.apache.org/doc/r3.4.3/zookeeperJMX.html"><span style="font-family: 'Comic Sans MS'; ">http://zookeeper.apache.org/doc/r3.4.3/zookeeperJMX.html</span></a><span style="font-family: 'Comic Sans MS'; ">. &nbsp;另外，完全可以有更简便的方式，直接使用%ZK_HOME%/bin 中的脚本启动即可。</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>./zkServer.sh&nbsp;start&nbsp;</span></span></li>
 </ol></pre> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">7</span></strong><span style="font-family: 'Comic Sans MS'; ">. 连接ZK host来检验部署是否成功。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>A</strong>. Java语言的话，可以通过运行这个命令来检测：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>$&nbsp;java&nbsp;-cp&nbsp;zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf:src/java/lib/jline-0.9.94.jar&nbsp;\&nbsp;org.apache.zookeeper.ZooKeeperMain&nbsp;-server&nbsp;127.0.0.1:2181&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>B</strong>. 如果是C语言的话，方法如下：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>$&nbsp;make&nbsp;cli_st&nbsp;</span></span></li>
  <li><span>$&nbsp;make&nbsp;cli_mt&nbsp;</span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; ">然后按照的这样的方式连接ZK：$ cli_mt 127.0.0.1:2181。无论运行哪种客户端，最终都是一个类似于文件系统的命令行操作。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; "> <strong>注意</strong>：除了上面这种检测方法，其实%ZK_HOME%/bin也有其它脚本，下面这个命令执行后，就进入了zookeeper树状结构的文件系统中。</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>./zkCli.sh&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; ">另外，还有一种方式，能够查看ZK服务器当前状态，如下，这个能够很好的看出目前这个机器的运行情况了：</span></p> 
<pre>
 <ol class="dp-py">
  <li class="alt"><span><span>$&nbsp;echo&nbsp;stat|nc&nbsp;localhost&nbsp;</span><span class="number">2181</span><span>&nbsp;</span></span></li>
  <li><span>Zookeeper&nbsp;version:&nbsp;<span class="number">3.4</span><span>.</span><span class="number">3</span><span>-</span><span class="number">1240972</span><span>,&nbsp;built&nbsp;on&nbsp;</span><span class="number">02</span><span>/</span><span class="number">06</span><span>/</span><span class="number">2012</span><span>&nbsp;</span><span class="number">10</span><span>:</span><span class="number">48</span><span>&nbsp;GMT&nbsp;</span></span></li>
  <li class="alt"><span>Clients:&nbsp;</span></li>
  <li><span>/<span class="number">127.0</span><span>.</span><span class="number">0.1</span><span>:</span><span class="number">40293</span><span>[</span><span class="number">0</span><span>](queued=</span><span class="number">0</span><span>,recved=</span><span class="number">1</span><span>,sent=</span><span class="number">0</span><span>)&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>Latency&nbsp;min/avg/max:&nbsp;<span class="number">1</span><span>/</span><span class="number">2</span><span>/</span><span class="number">3</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>Received:&nbsp;<span class="number">4</span><span>&nbsp;</span></span></li>
  <li><span>Sent:&nbsp;<span class="number">3</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>Outstanding:&nbsp;<span class="number">0</span><span>&nbsp;</span></span></li>
  <li><span>Zxid:&nbsp;<span class="number">0</span><span>×</span><span class="number">200000006</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>Mode:&nbsp;leader&nbsp;</span></li>
  <li><span>Node&nbsp;count:&nbsp;<span class="number">4</span><span>&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">1.3单机模式的配置</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">如果你想安装一个ZooKeeper来进行开发测试，通常可以使用单机模式来启动ZK。大体的步骤和上面说的是一样了，除了配置文件会更加简单一些。详细的配置方法可以查看这里：<a href="http://zookeeper.apache.org/doc/r3.4.3/zookeeperStarted.html#sc_InstallingSingleMode" target="_blank">http://zookeeper.apache.org/doc/r3.4.3/zookeeperStarted.html#sc_InstallingSingleMode</a></span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 36px; ">2.运 维</span></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">本章节主要要讲述如何更好地运维ZooKeepr，大致包含以下几部分内容：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.1</strong>. 部署方案的设计</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.2</strong>.&nbsp;日常运维</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.3</strong>. Server的自检恢复</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.4</strong>. 监控</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.5</strong>. 日志管理</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.6</strong>. 数据加载出错</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.7</strong>. 配置参数详解</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.8</strong>. 常用的四字命令</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.9</strong>. 数据文件管理</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2.10</strong>. 注意事项</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 26px; ">2.1 部署方案的设计</span></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">我们常说的ZooKeeper能够提供高可用分布式协调服务，是要基于以下两个条件：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>1</strong>. 集群中只有少部分的机器不可用。这里说的不可用是指这些机器或者是本身down掉了，或者是因为网络原因，有一部分机器无法和集群中其它绝大部分的机器通信。例如，如果ZK集群是跨机房部署的，那么有可能一些机器所在的机房被隔离了。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>2</strong>. 正确部署ZK server，有足够的磁盘存储空间以及良好的网络通信环境。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">下面将会从集群和单机两个维度来说明，帮助zookeeper管理员尽可能地提高ZK集群的可用性。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.1.1集群维度</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">在上面提到的“过半存活即可用”特性中已经讲到过，整个集群如果对外要可用的话，那么集群中必须要有过半的机器是正常工作并且彼此之间能够正常通信。基于这个特性，那么如果想搭建一个能够允许F台机器down掉的集群，那么就要部署一个由2xF+1 台机器构成的ZK集群。因此，一个由3台机器构成的ZK集群，能够在down掉一台机器后依然正常工作，而5台机器的集群，能够对两台机器down掉的情况容灾。<strong>注意</strong>，如果是一个6台机器构成的ZK集群，同样只能够down掉两台机器，因为如果down掉3台，剩下的机器就没有过半了。基于这个原因，ZK集群通常设计部署成奇数台机器。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">所以，为了尽可能地提高ZK集群的可用性，应该尽量避免一大批机器同时down掉的风险，换句话说，最好能够为每台机器配置互相独立的硬件环境。举个例子，如果大部分的机器都挂在同一个交换机上，那么这个交换机一旦出现问题，将会对整个集群的服务造成严重的影响。其它类似的还有诸如：供电线路，散热系统等。其实在真正的实践过程中，如果条件允许，通常都建议尝试跨机房部署。毕竟多个机房同时发生故障的机率还是挺小的。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 22px; "><strong>2.1.2 单机维度</strong></span></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">对于ZK来说，如果在运行过程中，需要和其它应用程序来竞争磁盘，CPU，网络或是内存资源的话，那么整体性能将会大打折扣。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">首先来看看磁盘对于ZK性能的影响。客户端对ZK的更新操作都是永久的，不可回退的，也就是说，一旦客户端收到一个来自server操作成功的响应，那么这个变更就永久生效了。为做到这点，ZK会将每次更新操作以事务日志的形式写入磁盘，写入成功后才会给予客户端响应。明白这点之后，你就会明白磁盘的吞吐性能对于ZK的影响了，磁盘写入速度制约着ZK每个更新操作的响应。为了尽量减少ZK在读写磁盘上的性能损失，不仿试试下面说的几点：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>A</strong>、使用单独的磁盘作为事务日志的输出（比如我们这里的ZK集群，使用单独的挂载点用于事务日志的输出）。事务日志的写性能确实对ZK性能，尤其是更新操作的性能影响很大，所以想办法搞到一个单独的磁盘吧！ZK的事务日志输出是一个顺序写文件的过程，本身性能是很高的，所以尽量保证不要和其它随机写的应用程序共享一块磁盘，尽量避免对磁盘的竞争。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp;<strong>B、</strong>尽量避免内存与磁盘空间的交换。如果希望ZK能够提供完全实时的服务的话，那么基本是不允许操作系统触发此类swap的。因此在分配JVM堆大小的时候一定要非常小心，具体在本文最后的“注意事项”章节中有讲到。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.2 日常运维</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">对zookeeper运维是一个长期积累经验的过程，希望以下几点对广大ZK运维人员有一定的帮助：</span></p> 
<p><strong><span style="font-size: 22px; "><span style="font-family: 'Comic Sans MS'; ">2.2.1 清理数据目录</span></span></strong></p> 
<p><span style="font-family: 'Comic Sans MS'; ">上文中提到dataDir目录指定了ZK的数据目录，用于存储ZK的快照文件（snapshot）。另外，默认情况下，ZK的事务日志也会存储在这个目录中。在完成若干次事务日志之后（在ZK中，凡是对数据有更新的操作，比如创建节点，删除节点或是对节点数据内容进行更新等，都会记录事务日志），ZK会触发一次快照（snapshot），将当前server上所有节点的状态以快照文件的形式dump到磁盘上去，即snapshot文件。这里的若干次事务日志是可以配置的，默认是100000，具体参看下文中关于配置参数“snapCount”的介绍。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">考虑到ZK运行环境的差异性，以及对于这些历史文件，不同的管理员可能有自己的用途（例如作为数据备份），因此默认ZK是不会自动清理快照和事务日志，需要交给管理员自己来处理。这里是我们用的清理方法，保留最新的66个文件，将它写到crontab中，每天凌晨2点触发一次：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>#!/bin/bash&nbsp;</span></span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>#snapshot&nbsp;file&nbsp;dir&nbsp;</span></li>
  <li><span><span class="attribute">dataDir</span><span>=/home/yinshi.nc/test/zk_data/version-2&nbsp;</span></span></li>
  <li class="alt"><span>#tran&nbsp;log&nbsp;dir&nbsp;</span></li>
  <li><span><span class="attribute">dataLogDir</span><span>=/home/yinshi.nc/test/zk_log/version-2&nbsp;</span></span></li>
  <li class="alt"><span>#zk&nbsp;log&nbsp;dir&nbsp;</span></li>
  <li><span><span class="attribute">logDir</span><span>=/home/yinshi.nc/test/logs&nbsp;</span></span></li>
  <li class="alt"><span>#Leave&nbsp;66&nbsp;files&nbsp;</span></li>
  <li><span><span class="attribute">count</span><span>=</span><span class="attribute-value">66</span><span>&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">count</span><span>=$[$count+1]&nbsp;</span></span></li>
  <li><span>ls&nbsp;-t&nbsp;$dataLogDir/log.*&nbsp;|&nbsp;tail&nbsp;-n&nbsp;+$count&nbsp;|&nbsp;xargs&nbsp;rm&nbsp;-f&nbsp;</span></li>
  <li class="alt"><span>ls&nbsp;-t&nbsp;$dataDir/snapshot.*&nbsp;|&nbsp;tail&nbsp;-n&nbsp;+$count&nbsp;|&nbsp;xargs&nbsp;rm&nbsp;-f&nbsp;</span></li>
  <li><span>ls&nbsp;-t&nbsp;$logDir/zookeeper.log.*&nbsp;|&nbsp;tail&nbsp;-n&nbsp;+$count&nbsp;|&nbsp;xargs&nbsp;rm&nbsp;-f&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>#find&nbsp;/home/yinshi.nc/taokeeper/zk_data/version-2&nbsp;-name&nbsp;“snap*”&nbsp;-mtime&nbsp;+1&nbsp;|&nbsp;xargs&nbsp;rm&nbsp;-f&nbsp;</span></li>
  <li class="alt"><span>#find&nbsp;/home/yinshi.nc/taokeeper/zk_logs/version-2&nbsp;-name&nbsp;“log*”&nbsp;-mtime&nbsp;+1&nbsp;|&nbsp;xargs&nbsp;rm&nbsp;-f&nbsp;</span></li>
  <li><span>#find&nbsp;/home/yinshi.nc/taokeeper/logs/&nbsp;-name&nbsp;“zookeeper.log.*”&nbsp;-mtime&nbsp;+1&nbsp;|&nbsp;xargs&nbsp;rm&nbsp;&#x2013;f&nbsp;</span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; ">其实，仅管ZK没有自动帮我们清理历史文件，但是它的还是提供了一个叫PurgeTxnLog的 工具类，实现了一种简单的历史文件清理策略，可以在这里看一下他的使用方法：</span><a href="http://zookeeper.apache.org/doc/r3.4.3/api/index.html"><span style="font-family: 'Comic Sans MS'; ">http://zookeeper.apache.org/doc/r3.4.3/api/index.html</span></a><span style="font-family: 'Comic Sans MS'; "> 简单使用如下：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>java&nbsp;-cp&nbsp;zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf&nbsp;org.apache.zookeeper.server.PurgeTxnLog</span><span class="tag">&lt;</span><span class="tag-name">dataDir</span><span class="tag">&gt;</span><span class="tag">&lt;</span><span class="tag-name">snapDir</span><span class="tag">&gt;</span><span>&nbsp;-n&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">count</span><span class="tag">&gt;</span><span>&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-family: 'Comic Sans MS'; ">最后一个参数表示希望保留的历史文件个数，注意，count必须是大于3的整数。可以把这句命令写成一个定时任务，以便每天定时执行清理。 </span></p> 
<p><strong><span style="font-family: 'Comic Sans MS'; ">注意</span></strong><span style="font-family: 'Comic Sans MS'; ">： 从3.4.0版本开始， zookeeper提供了自己清理历史文件的功能了，相关的配置参数是autopurge.snapRetainCount和autopurge.purgeInterval，在本文后面会具体说明。更多关于zookeeper的日志清理，可以阅读这个文章</span><a href="http://nileader.blog.51cto.com/1381108/932156"><span style="font-family: 'Comic Sans MS'; ">《ZooKeeper日志清理》</span></a><span style="font-family: 'Comic Sans MS'; ">。</span></p> 
<p><strong><span style="font-size: 22px; "><span style="font-family: 'Comic Sans MS'; ">2.2.2 ZK程序日志</span></span></strong></p> 
<p><span style="font-family: 'Comic Sans MS'; ">这里说两点，ZK默认是没有向ROLLINGFILE文件输出程序运行时日志的，需要我们自己在conf/log4j.properties中配置日志路径。另外，没有特殊要求的话，日志级别设置为INFO或以上，我曾经测试过，日志级别设置为DEBUG的话，性能影响很大！</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">2.3 Server的自检恢复</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">ZK运行过程中，如果出现一些无法处理的异常，会直接退出进程，也就是所谓的快速失败（fail fast）模式。在上文中有提到，“过半存活即可用”的特性使得集群中少数机器down掉后，整个集群还是可以对外正常提供服务的。另外，这些down掉的机器重启之后，能够自动加入到集群中，并且自动和集群中其它机器进行状态同步（主要就是从Leader那里同步最新的数据），从而达到自我恢复的目的。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">因此，我们很容易就可以想到，是否可以借助一些工具来自动完成机器的状态检测与重启工作。回答是肯定的，这里推荐两个工具： Daemontools(</span><a href="http://cr.yp.to/daemontools.html"><span style="font-family: 'Comic Sans MS'; ">http://cr.yp.to/daemontools.html</span></a><span style="font-family: 'Comic Sans MS'; ">) 和 SMF（</span><a href="http://en.wikipedia.org/wiki/Service_Management_Facility"><span style="font-family: 'Comic Sans MS'; ">http://en.wikipedia.org/wiki/Service_Management_Facility</span></a><span style="font-family: 'Comic Sans MS'; ">），能够帮助你监控ZK进程，一旦进程退出后，能够自动重启进程，从而使down掉的机器能够重新加入到集群中去~</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 26px; ">2.4 监控</span></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">有几种方法：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>1、</strong>&nbsp;ZK提供一些简单但是功能强大的4字命令，通过对这些4字命令的返回内容进行解析，可以获取不少关于ZK运行时的信息。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>2</strong>、用jmx也能够获取一些运行时信息，详细可以查看这里：</span><a href="http://zookeeper.apache.org/doc/r3.4.3/zookeeperJMX.html"><span style="font-family: 'Comic Sans MS'; ">http://zookeeper.apache.org/doc/r3.4.3/zookeeperJMX.html</span></a></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>3</strong>、淘宝网已经实现的一个ZooKeeper监控&#x2014;&#x2014;TaoKeeper，已开源，在这里： </span><a href="http://rdc.taobao.com/team/jm/archives/1450"><span style="font-family: 'Comic Sans MS'; ">http://rdc.taobao.com/team/jm/archives/1450</span></a><span style="font-family: 'Comic Sans MS'; ">，主要功能如下:</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;<strong>A</strong>、机器CPU/MEM/LOAD的监控</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;</span><strong><span style="font-family: 'Comic Sans MS'; ">B</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">ZK日志目录所在磁盘空间监控</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;</span><strong><span style="font-family: 'Comic Sans MS'; ">C</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">单机连接数的峰值报警</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;</span><strong><span style="font-family: 'Comic Sans MS'; ">D</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">单机Watcher数的峰值报警</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;</span><strong><span style="font-family: 'Comic Sans MS'; ">E</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">节点自检</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;</span><strong><span style="font-family: 'Comic Sans MS'; ">F</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">ZK运行时信息展示</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">2.5 日志管理</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">ZK使用log4j作为日志系统，conf目录中有一份默认的log4j配置文件，注意，这个配置文件中还没有开启ROLLINGFILE文件输出，配置下即可。其它关于log4j的详细介绍，可以移步到log4j的官网：</span><a href="http://logging.apache.org/log4j/1.2/manual.html#defaultInit"><span style="font-family: 'Comic Sans MS'; ">http://logging.apache.org/log4j/1.2/manual.html#defaultInit</span></a></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">2.6加载数据出错</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">ZK在启动的过程中，首先会根据事务日志中的事务日志记录，从本地磁盘加载最后一次提交时候的快照数据，如果读取事务日志出错或是其它问题（通常在日志中可以看到一些IO异常），将导致server将无法启动。碰到类似于这种数据文件出错导致无法启动服务器的情况，一般按照如下顺序来恢复：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; </span><strong><span style="font-family: 'Comic Sans MS'; ">1</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">确认集群中其它机器是否正常工作，方法是使用“stat”这个命令来检查：echo stat|nc ip 2181</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; </span><strong><span style="font-family: 'Comic Sans MS'; ">2</span></strong><span style="font-family: 'Comic Sans MS'; ">、</span><span style="font-family: 'Comic Sans MS'; ">如果确认其它机器是正常工作的（这里要说明下，所谓正常工作还是指集群中有过半机器可用），那么可以开始删除本机的一些数据了，删除$dataDir/version-2和$dataLogDir/version-2 两个目录下的所有文件。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">重启server。重启之后，这个机器就会从Leader那里同步到最新数据，然后重新加入到集群中提供服务。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">2.7 配置参数详解(主要是%ZOOKEEPER_HOME%/conf/zoo.cfg文件)</span></strong></span></p> 
<table width="620" border="1" cellspacing="0" cellpadding="0"> 
 <tbody> 
  <tr> 
   <td width="60"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">参数名</span></p> </td> 
   <td width="560"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">说明</span></p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">clientPort</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">客户端连接server的端口，即对外服务端口，一般设置为2181吧。</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">dataDir</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">存储快照文件snapshot的目录。默认情况下，事务日志也会存储在这里。建议同时配置参数dataLogDir, 事务日志的写性能直接影响zk性能。</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">tickTime</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">ZK中的一个时间单元。ZK中所有时间都是以这个时间单元为基础，进行整数倍配置的。例如，session的最小超时时间是2*tickTime。</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">dataLogDir</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">事务日志输出目录。尽量给事务日志的输出配置单独的磁盘或是挂载点，这将极大的提升ZK性能。 （No Java system property）</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">globalOutstandingLimit</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">最大请求堆积数。默认是1000。ZK运行的时候， 尽管server已经没有空闲来处理更多的客户端请求了，但是还是允许客户端将请求提交到服务器上来，以提高吞吐性能。当然，为了防止Server内存溢出，这个请求堆积数还是需要限制下的。 (Java system property:?<strong>zookeeper.globalOutstandingLimit.</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">preAllocSize</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">预先开辟磁盘空间，用于后续写入事务日志。默认是64M，每个事务日志大小就是64M。如果ZK的快照频率较大的话，建议适当减小这个参数。(Java system property:<strong>zookeeper.preAllocSize</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">snapCount</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">每进行snapCount次事务日志输出后，触发一次快照(snapshot), 此时，ZK会生成一个snapshot.*文件，同时创建一个新的事务日志文件log.*。默认是100000.（真正的代码实现中，会进行一定的随机数处理，以避免所有服务器在同一时间进行快照而影响性能）(Java system property:<strong>zookeeper.snapCount</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">traceFile</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">用于记录所有请求的log，一般调试过程中可以使用，但是生产环境不建议使用，会严重影响性能。(Java system property:<strong>requestTraceFile</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">maxClientCnxns</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">单个客户端与单台服务器之间的连接数的限制，是ip级别的，默认是60，如果设置为0，那么表明不作任何限制。请注意这个限制的使用范围，仅仅是单台客户端机器与单台ZK服务器之间的连接数限制，不是针对指定客户端IP，也不是ZK集群的连接数限制，也不是单台ZK对所有客户端的连接数限制。指定客户端IP的限制策略，这里有一个patch，可以尝试一下：</span><a href="http://rdc.taobao.com/team/jm/archives/1334"><span style="font-family: 'Comic Sans MS'; ">http://rdc.taobao.com/team/jm/archives/1334</span></a><span style="font-family: 'Comic Sans MS'; ">（No Java system property）</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">clientPortAddress</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">对于多网卡的机器，可以为每个IP指定不同的监听端口。默认情况是所有IP都监听<strong>clientPort</strong>指定的端口。<strong>New in 3.3.0</strong></span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">minSessionTimeoutmaxSessionTimeout</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">Session超时时间限制，如果客户端设置的超时时间不在这个范围，那么会被强制设置为最大或最小时间。默认的Session超时时间是在2 * <strong>tickTime ~ 20 * tickTime</strong><strong>这个范围</strong> <strong>New in 3.3.0</strong></span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">fsync.warningthresholdms</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">事务日志输出时，如果调用fsync方法超过指定的超时时间，那么会在日志中输出警告信息。默认是1000ms。(Java system property:<strong>fsync.warningthresholdms</strong>) <strong>New in 3.3.4</strong></span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">autopurge.purgeInterval</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">在上文中已经提到，3.4.0及之后版本，ZK提供了自动清理事务日志和快照文件的功能，这个参数指定了清理频率，单位是小时，需要配置一个1或更大的整数，默认是0，表示不开启自动清理功能。(No Java system property) <strong>New in 3.4.0</strong></span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">autopurge.snapRetainCount</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。(No Java system property) <strong>New in 3.4.0</strong></span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">electionAlg</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">在之前的版本中， 这个参数配置是允许我们选择leader选举算法，但是由于在以后的版本中，只会留下一种“TCP-based version of fast leader election”算法，所以这个参数目前看来没有用了，这里也不详细展开说了。(No Java system property)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">initLimit</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">Follower在启动过程中，会从Leader同步所有最新数据，然后确定自己能够对外服务的起始状态。Leader允许F在<strong>initLimit</strong>时间内完成这个工作。通常情况下，我们不用太在意这个参数的设置。如果ZK集群的数据量确实很大了，F在启动的时候，从Leader上同步数据的时间也会相应变长，因此在这种情况下，有必要适当调大这个参数了。(No Java system property)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">syncLimit</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">在运行过程中，Leader负责与ZK集群中所有机器进行通信，例如通过一些心跳检测机制，来检测机器的存活状态。如果L发出心跳包在syncLimit之后，还没有从F那里收到响应，那么就认为这个F已经不在线了。注意：不要把这个参数设置得过大，否则可能会掩盖一些问题。(No Java system property)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">leaderServes</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">默认情况下，Leader是会接受客户端连接，并提供正常的读写服务。但是，如果你想让Leader专注于集群中机器的协调，那么可以将这个参数设置为no，这样一来，会大大提高写操作的性能。(Java system property: zookeeper.<strong>leaderServes</strong>)。</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">server.x=[hostname]:nnnnn[:nnnnn]</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">这里的x是一个数字，与myid文件中的id是一致的。右边可以配置两个端口，第一个端口用于F和L之间的数据同步和其它通信，第二个端口用于Leader选举过程中投票通信。 (No Java system property)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">group.x=nnnnn[:nnnnn]weight.x=nnnnn</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">对机器分组和权重设置，可以 </span><a href="http://zookeeper.apache.org/doc/r3.4.3/zookeeperHierarchicalQuorums.html"><span style="font-family: 'Comic Sans MS'; ">参见这里</span></a><span style="font-family: 'Comic Sans MS'; ">(No Java system property)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">cnxTimeout</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">Leader选举过程中，打开一次连接的超时时间，默认是5s。(Java system property: zookeeper.<strong>cnxTimeout</strong>)</span></p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">zookeeper.DigestAuthenticationProvider .superDigest</span></td> 
   <td width="560"> <p><span style="font-family: 'Comic Sans MS'; ">ZK权限设置相关，具体参见</span><a href="http://nileader.blog.51cto.com/1381108/930635"><span style="font-family: 'Comic Sans MS'; ">《<strong>使用super</strong><strong>身份对有权限的节点进行操作</strong>》</span></a><span style="font-family: 'Comic Sans MS'; "> 和 </span><a href="http://nileader.blog.51cto.com/1381108/795525"><span style="font-family: 'Comic Sans MS'; ">《<strong>ZooKeeper</strong><strong>权限控制</strong>》</span></a></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">skipACL</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">对所有客户端请求都不作ACL检查。如果之前节点上设置有权限限制，一旦服务器上打开这个开头，那么也将失效。(Java system property:<strong>zookeeper.skipACL</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">forceSync</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">这个参数确定了是否需要在事务日志提交的时候调用</span><a href="%5C/java%5C/jdk1.6.0_22%5C/jre%5C/lib%5C/rt.jar%3Cjava.nio.channels(FileChannel.class%E2%98%83FileChannel"><span style="font-family: 'Comic Sans MS'; ">FileChannel</span></a><span style="font-family: 'Comic Sans MS'; ">.force来保证数据完全同步到磁盘。(Java system property:<strong>zookeeper.forceSync</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
  <tr> 
   <td width="60"><span style="font-family: 'Comic Sans MS'; ">jute.maxbuffer</span></td> 
   <td width="560"> <p>&nbsp;</p> <p><span style="font-family: 'Comic Sans MS'; ">每个节点最大数据量，是默认是1M。这个限制必须在server和client端都进行设置才会生效。(Java system property:<strong>jute.maxbuffer</strong>)</span></p> <p>&nbsp;</p> </td> 
  </tr> 
 </tbody> 
</table> 
<p><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 26px; ">2.8 常用的四字命令</span></span></p> 
<table width="640" border="1" cellspacing="0" cellpadding="0"> 
 <tbody> 
  <tr> 
   <td width="40"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">参数名</span></p> </td> 
   <td width="600"> <p align="center"><span style="font-family: 'Comic Sans MS'; ">说明</span></p> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">conf</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">输出server的详细配置信息。<strong>New in 3.3.0</strong><br> </span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;conf|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span><span class="attribute">clientPort</span><span>=</span><span class="attribute-value">2181</span><span>&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">dataDir</span><span>=/home/test/taokeeper/zk_data/version-2&nbsp;</span></span></li>
      <li><span><span class="attribute">dataLogDir</span><span>=/test/admin/taokeeper/zk_log/version-2&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">tickTime</span><span>=</span><span class="attribute-value">2000</span><span>&nbsp;</span></span></li>
      <li><span><span class="attribute">maxClientCnxns</span><span>=</span><span class="attribute-value">1000</span><span>&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">minSessionTimeout</span><span>=</span><span class="attribute-value">4000</span><span>&nbsp;</span></span></li>
      <li><span><span class="attribute">maxSessionTimeout</span><span>=</span><span class="attribute-value">40000</span><span>&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">serverId</span><span>=</span><span class="attribute-value">2</span><span>&nbsp;</span></span></li>
      <li><span><span class="attribute">initLimit</span><span>=</span><span class="attribute-value">10</span><span>&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">syncLimit</span><span>=</span><span class="attribute-value">5</span><span>&nbsp;</span></span></li>
      <li><span><span class="attribute">electionAlg</span><span>=</span><span class="attribute-value">3</span><span>&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">electionPort</span><span>=</span><span class="attribute-value">3888</span><span>&nbsp;</span></span></li>
      <li><span><span class="attribute">quorumPort</span><span>=</span><span class="attribute-value">2888</span><span>&nbsp;</span></span></li>
      <li class="alt"><span><span class="attribute">peerType</span><span>=</span><span class="attribute-value">0</span><span>&nbsp;</span></span></li>
     </ol></pre> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">cons</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">输出指定server上所有客户端连接的详细信息，包括客户端IP，会话ID等。 <strong>New in 3.3.0</strong>类似于这样的信息：<br> </span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;cons|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span>/1.2.3.4:43527[1](<span class="attribute">queued</span><span>=</span><span class="attribute-value">0</span><span>,</span><span class="attribute">recved</span><span>=</span><span class="attribute-value">152802</span><span>,</span><span class="attribute">sent</span><span>=</span><span class="attribute-value">152806</span><span>,</span><span class="attribute">sid</span><span>=</span><span class="attribute-value">0x2389e662b98c424</span><span>,</span><span class="attribute">lop</span><span>=</span><span class="attribute-value">PING</span><span>,</span><span class="attribute">est</span><span>=</span><span class="attribute-value">1350385542196</span><span>,</span><span class="attribute">to</span><span>=</span><span class="attribute-value">6000</span><span>,</span><span class="attribute">lcxid</span><span>=</span><span class="attribute-value">0</span><span>×114,</span><span class="attribute">lzxid</span><span>=</span><span class="attribute-value">0xffffffffffffffff</span><span>,</span><span class="attribute">lresp</span><span>=</span><span class="attribute-value">1350690663308</span><span>,</span><span class="attribute">llat</span><span>=</span><span class="attribute-value">0</span><span>,</span><span class="attribute">minlat</span><span>=</span><span class="attribute-value">0</span><span>,</span><span class="attribute">avglat</span><span>=</span><span class="attribute-value">0</span><span>,</span><span class="attribute">maxlat</span><span>=</span><span class="attribute-value">483</span><span>)&nbsp;</span></span></li>
      <li class="alt"><span>……&nbsp;</span></li>
     </ol></pre> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">crst</span></td> 
   <td width="600"><span style="font-family: 'Comic Sans MS'; ">功能性命令。重置所有连接的<strong>统计</strong>信息。<strong>New in 3.3.0</strong></span></td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">dump</span></td> 
   <td width="600"><span style="font-family: 'Comic Sans MS'; ">这个命令针对Leader执行，用于输出所有等待队列中的会话和临时节点的信息。</span></td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">envi</span></td> 
   <td width="600"><span style="font-family: 'Comic Sans MS'; ">用于输出server的环境变量。包括操作系统环境和Java环境。</span></td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">ruok</span></td> 
   <td width="600"><span style="font-family: 'Comic Sans MS'; ">用于测试server是否处于无错状态。如果正常，则返回“imok”,否则没有任何响应。 注意：ruok不是一个特别有用的命令，它不能反映一个server是否处于正常工作。“stat”命令更靠谱。</span></td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">stat</span></td> 
   <td width="600"><span style="font-family: 'Comic Sans MS'; ">输出server简要状态和连接的客户端信息。</span></td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">srvr</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">和stat类似，<strong>New in 3.3.0</strong> </span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;stat|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span>Zookeeper&nbsp;version:&nbsp;3.3.5-1301095,&nbsp;built&nbsp;on&nbsp;03/15/2012&nbsp;19:48&nbsp;GMT&nbsp;</span></li>
      <li class="alt"><span>Clients:&nbsp;</span></li>
      <li><span>/10.2.3.4:59179[1](<span class="attribute">queued</span><span>=</span><span class="attribute-value">0</span><span>,</span><span class="attribute">recved</span><span>=</span><span class="attribute-value">44845</span><span>,</span><span class="attribute">sent</span><span>=</span><span class="attribute-value">44845</span><span>)&nbsp;</span></span></li>
      <li class="alt"><span>&nbsp;</span></li>
      <li><span>Latency&nbsp;min/avg/max:&nbsp;0/0/1036&nbsp;</span></li>
      <li class="alt"><span>Received:&nbsp;2274602238&nbsp;</span></li>
      <li><span>Sent:&nbsp;2277795620&nbsp;</span></li>
      <li class="alt"><span>Outstanding:&nbsp;0&nbsp;</span></li>
      <li><span>Zxid:&nbsp;0xa1b3503dd&nbsp;</span></li>
      <li class="alt"><span>Mode:&nbsp;leader&nbsp;</span></li>
      <li><span>Node&nbsp;count:&nbsp;37473&nbsp;</span></li>
     </ol><br type="_moz"></pre> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;srvr|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span>Zookeeper&nbsp;version:&nbsp;3.3.5-1301095,&nbsp;built&nbsp;on&nbsp;03/15/2012&nbsp;19:48&nbsp;GMT&nbsp;</span></li>
      <li class="alt"><span>Latency&nbsp;min/avg/max:&nbsp;0/0/980&nbsp;</span></li>
      <li><span>Received:&nbsp;2592698547&nbsp;</span></li>
      <li class="alt"><span>Sent:&nbsp;2597713974&nbsp;</span></li>
      <li><span>Outstanding:&nbsp;0&nbsp;</span></li>
      <li class="alt"><span>Zxid:&nbsp;0xa1b356b5b&nbsp;</span></li>
      <li><span>Mode:&nbsp;follower&nbsp;</span></li>
      <li class="alt"><span>Node&nbsp;count:&nbsp;37473&nbsp;</span></li>
     </ol><br></pre> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">srst</span></td> 
   <td width="600"><span style="font-family: 'Comic Sans MS'; ">重置server的统计信息。</span></td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">wchs</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">列出所有watcher信息概要信息，数量等：<strong>New in 3.3.0</strong><br> </span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;wchs|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span>3890&nbsp;connections&nbsp;watching&nbsp;537&nbsp;paths&nbsp;</span></li>
      <li class="alt"><span>Total&nbsp;watches:6909&nbsp;</span></li>
     </ol></pre> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">wchc</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">列出所有watcher信息，以watcher的session为归组单元排列，列出该会话订阅了哪些path：<strong>New in 3.3.0</strong><br> </span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;wchc|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span>0x2389e662b97917f&nbsp;</span></li>
      <li class="alt"><span>/mytest/test/path1/node1&nbsp;</span></li>
      <li><span>0x3389e65c83cd790&nbsp;</span></li>
      <li class="alt"><span>/mytest/test/path1/node2&nbsp;</span></li>
      <li><span>0x1389e65c7ef6313&nbsp;</span></li>
      <li class="alt"><span>/mytest/test/path1/node3&nbsp;</span></li>
      <li><span>/mytest/test/path1/node1&nbsp;</span></li>
     </ol></pre> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">wchp</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">列出所有watcher信息，以watcher的path为归组单元排列，列出该path被哪些会话订阅着：<strong>New in 3.3.0</strong></span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$</span><span class="tag">&gt;</span><span>echo&nbsp;wchp|nc&nbsp;localhost&nbsp;2181&nbsp;</span></span></li>
      <li><span>/mytest/test/path1/node&nbsp;</span></li>
      <li class="alt"><span>0x1389e65c7eea4f5&nbsp;</span></li>
      <li><span>0x1389e65c7ee2f68&nbsp;</span></li>
      <li class="alt"><span>/mytest/test/path1/node2&nbsp;</span></li>
      <li><span>0x2389e662b967c29&nbsp;</span></li>
      <li class="alt"><span>/mytest/test/path1/node3&nbsp;</span></li>
      <li><span>0x3389e65c83dd2e0&nbsp;</span></li>
      <li class="alt"><span>0x1389e65c7f0c37c&nbsp;</span></li>
      <li><span>0x1389e65c7f0c364&nbsp;</span></li>
     </ol></pre> <p><strong><span style="font-family: 'Comic Sans MS'; ">注意</span></strong><span style="font-family: 'Comic Sans MS'; ">，wchc和wchp这两个命令执行的输出结果都是针对session的，对于运维人员来说可视化效果并不理想，可以尝试将cons命令执行输出的信息整合起来，就可以用客户端IP来代替会话ID了，具体可以看这个实现：<a href="http://rdc.taobao.com/team/jm/archives/1450" target="_blank">http://rdc.taobao.com/team/jm/archives/1450</a></span></p> </td> 
  </tr> 
  <tr> 
   <td width="40"><span style="font-family: 'Comic Sans MS'; ">mntr</span></td> 
   <td width="600"> <p><span style="font-family: 'Comic Sans MS'; ">输出一些ZK运行时信息，通过对这些返回结果的解析，可以达到监控的效果。<strong>New in 3.4.0</strong><br> </span></p> <pre>
     <ol class="dp-xml">
      <li class="alt"><span><span>$&nbsp;echo&nbsp;mntr&nbsp;|&nbsp;nc&nbsp;localhost&nbsp;2185&nbsp;</span></span></li>
      <li><span>zk_version&nbsp;3.4.0&nbsp;</span></li>
      <li class="alt"><span>zk_avg_latency&nbsp;0&nbsp;</span></li>
      <li><span>zk_max_latency&nbsp;0&nbsp;</span></li>
      <li class="alt"><span>zk_min_latency&nbsp;0&nbsp;</span></li>
      <li><span>zk_packets_received&nbsp;70&nbsp;</span></li>
      <li class="alt"><span>zk_packets_sent&nbsp;69&nbsp;</span></li>
      <li><span>zk_outstanding_requests&nbsp;0&nbsp;</span></li>
      <li class="alt"><span>zk_server_state&nbsp;leader&nbsp;</span></li>
      <li><span>zk_znode_count&nbsp;4&nbsp;</span></li>
      <li class="alt"><span>zk_watch_count&nbsp;0&nbsp;</span></li>
      <li><span>zk_ephemerals_count&nbsp;0&nbsp;</span></li>
      <li class="alt"><span>zk_approximate_data_size&nbsp;27&nbsp;</span></li>
      <li><span>zk_followers&nbsp;4&nbsp;&#x2013;&nbsp;only&nbsp;exposed&nbsp;by&nbsp;the&nbsp;Leader&nbsp;</span></li>
      <li class="alt"><span>zk_synced_followers&nbsp;4&nbsp;&#x2013;&nbsp;only&nbsp;exposed&nbsp;by&nbsp;the&nbsp;Leader&nbsp;</span></li>
      <li><span>zk_pending_syncs&nbsp;0&nbsp;&#x2013;&nbsp;only&nbsp;exposed&nbsp;by&nbsp;the&nbsp;Leader&nbsp;</span></li>
      <li class="alt"><span>zk_open_file_descriptor_count&nbsp;23&nbsp;&#x2013;&nbsp;only&nbsp;available&nbsp;on&nbsp;Unix&nbsp;platforms&nbsp;</span></li>
      <li><span>zk_max_file_descriptor_count&nbsp;1024&nbsp;&#x2013;&nbsp;only&nbsp;available&nbsp;on&nbsp;Unix&nbsp;platforms&nbsp;</span></li>
     </ol></pre> </td> 
  </tr> 
 </tbody> 
</table> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">2.9 数据文件管理</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">默认情况下，ZK的数据文件和事务日志是保存在同一个目录中，建议是将事务日志存储到单独的磁盘上。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.9.1数据目录</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">ZK的数据目录包含两类文件：</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>A</strong>、myid &#x2013; 这个文件只包含一个数字，和server id对应。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>B</strong>、snapshot. - 按zxid先后顺序的生成的数据快照。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">集群中的每台ZK server都会有一个用于惟一标识自己的id，有两个地方会使用到这个id：myid文件和zoo.cfg文件中。myid文件存储在dataDir目录中，指定了当前server的server id。在zoo.cfg文件中，根据server id，配置了每个server的ip和相应端口。Zookeeper启动的时候，读取myid文件中的server id，然后去zoo.cfg 中查找对应的配置。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">zookeeper在进行数据快照过程中，会生成 snapshot文件，存储在dataDir目录中。文件后缀是zxid，也就是事务id。（这个zxid代表了zk触发快照那个瞬间，提交的最后一个事务id）。注意，一个快照文件中的数据内容和提交第zxid个事务时内存中数据近似相同。仅管如此，由于更新操作的幂等性，ZK还是能够从快照文件中恢复数据。数据恢复过程中，将事务日志和快照文件中的数据对应起来，就能够恢复最后一次更新后的数据了。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.9.2事务日志目录</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">dataLogDir目录是ZK的事务日志目录，包含了所有ZK的事务日志。正常运行过程中，针对所有更新操作，在返回客户端“更新成功”的响应前，ZK会确保已经将本次更新操作的事务日志写到磁盘上，只有这样，整个更新操作才会生效。每触发一次数据快照，就会生成一个新的事务日志。事务日志的文件名是log.，zxid是写入这个文件的第一个事务id。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.9.3文件管理</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">不同的zookeeper server生成的snapshot文件和事务日志文件的格式都是一致的（无论是什么环境，或是什么样的zoo.cfg 配置）。因此，如果某一天生产环境中出现一些古怪的问题，你就可以把这些文件下载到开发环境的zookeeper中加载起来，便于调试发现问题，而不会影响生产运行。另外，使用这些较旧的snapshot和事务日志，我们还能够方便的让ZK回滚到一个历史状态。 </span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">另外，ZK提供的工具类LogFormatter能够帮助可视化ZK的事务日志，帮助我们排查问题，关于事务日志的可以化，请查看这个文章</span><a href="http://nileader.blog.51cto.com/1381108/926753"><span style="font-family: 'Comic Sans MS'; ">《可视化zookeeper的事务日志》</span></a><span style="font-family: 'Comic Sans MS'; ">.</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">需要注意的一点是，zookeeper在运行过程中，不断地生成snapshot文件和事务日志，但是不会自动清理它们，需要管理员来处理。（ZK本身只需要使用最新的snapshot和事务日志即可）关于如何清理文件，上面章节“日常运维”有提到。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 26px; ">2.10 注意事项</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.10.1 保持Server地址列表一致</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>A</strong>、客户端使用的server地址列表必须和集群所有server的地址列表一致。（如果客户端配置了集群机器列表的子集的话，也是没有问题的，只是少了客户端的容灾。）</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; <strong>B</strong>、集群中每个server的zoo.cfg中配置机器列表必须一致。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.10.2 独立的事务日志输出</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">对于每个更新操作，ZK都会在确保事务日志已经落盘后，才会返回客户端响应。因此事务日志的输出性能在很大程度上影响ZK的整体吞吐性能。强烈建议是给事务日志的输出分配一个单独的磁盘。</span></p> 
<p><span style="font-family: 'Comic Sans MS'; "><strong><span style="font-size: 22px; ">2.10.3 配置合理的JVM堆大小</span></strong></span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">确保设置一个合理的JVM堆大小，如果设置太大，会让内存与磁盘进行交换，这将使ZK的性能大打折扣。例如一个4G内存的机器的，如果你把JVM的堆大小设置为4G或更大，那么会使频繁发生内存与磁盘空间的交换，通常设置成3G就可以了。当然，为了获得一个最好的堆大小值，在特定的使用场景下进行一些压力测试。</span></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/1032157">http://nileader.blog.51cto.com/1381108/1032157</a></p>
