<p>&nbsp;&nbsp; 好久没写技术博客了，因为之前一直在开发跟公司内部业务相关的接口以及项目，感觉大多是跟公司具体业务相关的东西，因此不方便在此公开记录下来。今天抓住休息的时间想在工作之余给自己补充一点大数据的知识(工作上暂时用不到)在自己电脑上安装了6台虚拟linux系统，然后在这个6台机器上分别部署了zookeeper集群以及hadoop-2.2.0集群，部署zookeeper集群相对来说简单一点，因为网上的资料比较多，而由于自己的虚拟机是64位的，因此在部署hadoop的时候需要重新编译一遍，在这个过程中遇到的问题还蛮多的，不过幸好都解决了。</p>
<p><br></p>
<p>1：首先，在VM上安装6台64位的虚拟机主要是遇到了安装包的问题以及环境部署的问题。</p>
<p>&nbsp;&nbsp; 以下是自己安装使用的ISO文件下载地址：</p>
<p>&nbsp;&nbsp; <a href="http://mirrors.sohu.com/centos/6.5/isos/x86_64/CentOS-6.5-x86_64-bin-DVD1.iso" target="_blank">http://mirrors.sohu.com/centos/6.5/isos/x86_64/CentOS-6.5-x86_64-bin-DVD1.iso</a><br></p>
<p>&nbsp;&nbsp; 其实我是之前就把这个页面的所有安装包都下载下来的，一个个试着去安装，然后最终选定了无桌面版的，可以再安装的时候选择设置，这个过程就是有点耗时间。接下来我分别在每个主机上部署了jdk，maven，git，mysql，openssh-clients,还有把相关的项目部署上去，之歌过程也有点耗时间，接下来我想尝试写个ssh脚本自动化安装测试一下。</p>
<p>&nbsp;&nbsp; 配置环境变量之后，就开始搭建zookeeper集群了，这个集群主要是配合阿里的开源项目dubbo(git下载：<a href="https://github.com/alibaba/dubbo)%E4%BD%BF%E7%94%A8%EF%BC%8C%E6%88%91%E6%98%AF%E4%BD%BF%E7%94%A85%E5%8F%B0%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%99%A8%E9%83%A8%E7%BD%B2zookeeper%E9%9B%86%E7%BE%A4%E4%BD%9C%E4%B8%BAdubbo%E7%9A%84%E6%B3%A8%E5%86%8C%E4%B8%AD%E5%BF%83%EF%BC%8C%E8%BF%99%E4%B8%AA%E8%BF%87%E7%A8%8B%E4%B9%9F%E6%98%AF%E6%AF%94%E8%BE%83%E7%AE%80%E5%8D%95%E7%9A%84%EF%BC%8C%E5%9B%A0%E4%B8%BA%E5%85%B3%E4%BA%8Ezookeeper%E9%9B%86%E7%BE%A4%E7%9A%84%E9%83%A8%E7%BD%B2%E4%BB%A5%E5%89%8Ddubbo%E7%9A%84%E9%83%A8%E7%BD%B2%E7%BD%91%E4%B8%8A%E8%B5%84%E6%96%99%E4%B8%80%E5%A4%A7%E6%8A%8A%EF%BC%8C%E5%BD%93%E7%84%B6%E7%94%B1%E4%BA%8E%E5%9C%A8%E9%83%A8%E7%BD%B2zookeeper%E9%9B%86%E7%BE%A4%E7%9A%84%E6%97%B6%E5%80%99%E6%B2%A1%E6%9C%89%E9%87%87%E7%94%A8%E8%84%9A%E6%9C%AC%E9%83%A8%E7%BD%B2%E6%96%B9%E5%BC%8F%EF%BC%8C%E8%BF%99%E4%B8%AA%E8%BF%87%E7%A8%8B%E4%B9%9F%E6%98%AF%E6%AF%94%E8%BE%83%E8%80%97%E6%97%B6%E9%97%B4%E7%9A%84%EF%BC%8C%E6%8E%A5%E4%B8%8B%E6%9D%A5%E4%BC%9A%E5%B0%9D%E8%AF%95%E8%84%9A%E6%9C%AC%E9%83%A8%E7%BD%B2%E6%96%B9%E5%BC%8F%EF%BC%8C%E9%83%A8%E7%BD%B2%E5%AE%8C%E4%B9%8B%E5%90%8E%E8%B7%91%E4%BA%86dubbo%E7%9A%84demo%E4%BB%A5%E5%89%8Ddubbo-admin%E6%9F%A5%E7%9C%8B%E4%BA%86%E4%B8%80%E4%B8%8B%E8%BF%98%E6%98%AFOK%E7%9A%84%EF%BC%8C%E5%BD%93%E7%84%B6%E7%94%B1%E4%BA%8E%E6%9D%A1%E4%BB%B6%E6%9C%89%E9%99%90%E6%B2%A1%E6%9C%89%E7%BB%A7%E7%BB%AD%E6%B7%B1%E5%85%A5%E4%B8%8B%E5%8E%BB%E3%80%82" target="_blank">https://github.com/alibaba/dubbo)使用，我是使用5台虚拟机器部署zookeeper集群作为dubbo的注册中心，这个过程也是比较简单的，因为关于zookeeper集群的部署以前dubbo的部署网上资料一大把，当然由于在部署zookeeper集群的时候没有采用脚本部署方式，这个过程也是比较耗时间的，接下来会尝试脚本部署方式，部署完之后跑了dubbo的demo以前dubbo-admin查看了一下还是OK的，当然由于条件有限没有继续深入下去。</a></p>
<p><br></p>
<p>2：hadoop的编译，这个编译比较繁琐，自己也是走一步再修改一下，整理了一下，之后发现原来网上有一篇文章记载的步骤跟错误跟我在操作的时候没多大的差异，大概就是以下步骤</p>
<p>首先需要安装的是：</p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>maven:maven有版本冲突的问题，确实是这样的，我机子上面安装的都是最新的版本，但是都会报错，之后我下载了3.0.5这个版本之后那个错误九消失了。wget <a href="http://mirrors.cnnic.cn/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz" target="_blank">http://mirrors.cnnic.cn/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz</a></p></li>
 <li><p><a href="http://mirrors.cnnic.cn/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz" target="_blank">yum install gcc-c++</a></p></li>
 <li><p>wget <a href="http://prdownloads.sourceforge.net/findbugs/findbugs-2.0.3.tar.gz?download" target="_blank">http://prdownloads.sourceforge.net/findbugs/findbugs-2.0.3.tar.gz?download</a></p></li>
</ul>
<p>&nbsp;&nbsp;&nbsp;&nbsp; findbugs需要配置环境变量<br></p>
<p><a href="http://prdownloads.sourceforge.net/findbugs/findbugs-2.0.3.tar.gz?download" target="_blank"></a></p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>wget <a href="https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz" target="_blank">https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz</a></p></li>
 <li><p>wget <a href="http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz" target="_blank">http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz</a></p></li>
 <li><p>yum install pkgconfig</p></li>
 <li><p>yum install openssl</p></li>
 <li><p>yum install openssl-devel</p></li>
 <li><p>vi hadoop-common-project/hadoop-auth/pom.xml(增加有加号的)</p><p>&lt;/dependency&gt;<br>&nbsp; &nbsp; &lt;dependency&gt;<br>&nbsp; &nbsp; &nbsp; &lt;groupId&gt;org.mortbay.jetty&lt;/groupId&gt;<br>+&nbsp; &nbsp; &nbsp; &lt;artifactId&gt;jetty-util&lt;/artifactId&gt;<br>+&nbsp; &nbsp; &nbsp; &lt;scope&gt;test&lt;/scope&gt;<br>+&nbsp; &nbsp; &lt;/dependency&gt;<br>+&nbsp; &nbsp; &lt;dependency&gt;<br>+&nbsp; &nbsp; &nbsp; &lt;groupId&gt;org.mortbay.jetty&lt;/groupId&gt;<br>&nbsp; &nbsp; &nbsp; &lt;artifactId&gt;jetty&lt;/artifactId&gt;<br>&nbsp; &nbsp; &nbsp; &lt;scope&gt;test&lt;/scope&gt;<br>&nbsp; &nbsp; &lt;/dependency&gt;</p></li>
 <li><p>最后就是执行命令：mvn package -DskipTests -Pdist,native -Dtar</p></li>
</ul>
<p><br></p>
<p><br></p>
<p>&nbsp; 执行以上步骤后，接下来就是漫长的等待了，反正我是至少等待了30分钟，不过还好最终编译成功了，接下来的事情就是重复使用scp命令传输文件了，关于hadoop+zookeeper集群的搭建网上也有一大堆。</p>
<p>&nbsp; <br></p>
<p>本文出自 “<a href="http://chenyanxi.blog.51cto.com">陈砚羲</a>” 博客，请务必保留此出处<a href="http://chenyanxi.blog.51cto.com/4599355/1552425">http://chenyanxi.blog.51cto.com/4599355/1552425</a></p>
