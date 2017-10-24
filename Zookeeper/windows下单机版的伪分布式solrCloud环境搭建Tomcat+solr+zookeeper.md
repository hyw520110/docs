<p><br></p>
<div class="Section0">
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">前面简单了解了<span style="font-family:'times new roman';">ZooKeeper</span><span style="font-family:'宋体';">的相关知识，为</span><span style="font-family:'times new roman';">SolrCloud</span><span style="font-family:'宋体';">的学习作了一层铺垫。在</span><span style="font-family:'times new roman';">SolrCloud</span><span style="font-family:'宋体';">的</span><span style="font-family:'times new roman';">wiki</span><span style="font-family:'宋体';">中，可以很简单地用</span><span style="font-family:'times new roman';">jetty</span><span style="font-family:'宋体';">实现嵌入式</span><span style="font-family:'times new roman';">ZooKeeper</span><span style="font-family:'宋体';">的单机版</span><span style="font-family:'times new roman';">SolrCloud</span><span style="font-family:'宋体';">。但是在生产环境中，</span><span style="font-family:'times new roman';">Solr</span><span style="font-family:'宋体';">一般都是部署在</span><span style="font-family:'times new roman';">Tomcat</span><span style="font-family:'宋体';">上的。为了使架构更加灵活，</span><span style="font-family:'times new roman';">ZooKeeper</span><span style="font-family:'宋体';">也是单独部署的。日常学习中，就一台单机怎么学习</span><span style="font-family:'times new roman';">solrCloud</span><span style="font-family:'宋体';">呢？本文将记录在</span><span style="font-family:'times new roman';">win7</span><span style="font-family:'宋体';">上实现</span><span style="font-family:'times new roman';">ZooKeeper+Tomcat</span><span style="font-family:'宋体';">版的伪分布式</span><span style="font-family:'times new roman';">SolrCloud</span><span style="font-family:'宋体';">。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h1 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:29px;font-family:'宋体';">1、</span><span style="font-weight:bold;font-size:29px;font-family:'宋体';">软件工具箱</span><span style="font-weight:bold;font-size:29px;font-family:'宋体';"></span></h1>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">在本文的实践中，需要用到以下的软件： &nbsp; </span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';"> solr-4.2.0.zip &nbsp; &nbsp; &nbsp;zookeeper-3.4.6.tar.gz &nbsp; &nbsp; apache-tomcat-6.037.tar.gz</span><span style="font-weight:bold;font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">都是<span style="font-family:'times new roman';">apache</span><span style="font-family:'宋体';">旗下的软件，很容易在官网下载到，就不贴下载地址了。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h1 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:29px;font-family:'宋体';">2、部署过程</span><span style="font-weight:bold;font-size:29px;font-family:'宋体';"></span></h1>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">单机上的学习环境搭建大部分都是体力活，没有什么技术含量。不像生产环境，需要考虑到性能问题。</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h2 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'黑体';">2.1 <span style="font-family:'黑体';">部署好单机版</span><span style="font-family:arial;">Tomcat+Solr</span></span><span style="font-weight:bold;font-size:21px;font-family:'黑体';"></span></h2>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第一步：</span><span style="font-size:14px;font-family:'宋体';">在<span style="font-family:'times new roman';">D</span><span style="font-family:'宋体';">盘根目录下建立</span><span style="font-family:'times new roman';">solrCloud</span><span style="font-family:'宋体';">目录。并把</span><span style="font-family:'times new roman';">apache-tomcat-6.037.tar.gz</span><span style="font-family:'宋体';">解压到</span><span style="font-family:'times new roman';">solrCloud</span><span style="font-family:'宋体';">目录下，重命名为</span><span style="font-family:'times new roman';">tomcat-server_1</span><span style="font-family:'宋体';">。把</span><span style="font-family:'times new roman';">solr-4.2.0.zip</span><span style="font-family:'宋体';">解压，并把</span></span><span style="font-weight:normal;font-size:14px;font-family:'宋体';">solr-4.2.0/example/<span style="font-family:'宋体';">目录下</span></span><span style="font-size:14px;font-family:'宋体';">的<span style="font-family:'times new roman';">solr</span><span style="font-family:'宋体';">文件夹复制到</span><span style="font-family:'times new roman';">solrCloud</span><span style="font-family:'宋体';">目录下，重命名为</span><span style="font-family:'times new roman';">solr_home_1</span><span style="font-family:'宋体';">。如下图：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M02/26/43/wKiom1NrDxnjNRTjAACN-PdkfrY609.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M02/26/43/wKiom1NrDxnjNRTjAACN-PdkfrY609.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-618.png" alt="wKiom1NrDxnjNRTjAACN-PdkfrY609.jpg"></a></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第二步：</span><span style="font-size:14px;font-family:'宋体';">把<span style="font-family:'times new roman';">solr-4.2.0\example\webapps\solr.war</span><span style="font-family:'宋体';">复制到</span><span style="font-family:'times new roman';">tomcat-server_1/webapps</span><span style="font-family:'宋体';">目录下。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第三步：</span><span style="font-size:14px;font-family:'宋体';">修改<span style="font-family:'times new roman';">D:\solrCloud\tomcat-server_1\bin</span><span style="font-family:'宋体';">目录下的</span><span style="font-family:'times new roman';">catalina.bat</span><span style="font-family:'宋体';">文件，里面加入</span><span style="font-family:'times new roman';">tomcat</span><span style="font-family:'宋体';">的启动参数。</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"><span style="font-family:'宋体';"><a href="http://s3.51cto.com/wyfs02/M01/26/43/wKioL1NrDwrDEAnhAABEqO1QdEQ811.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/26/43/wKioL1NrDwrDEAnhAABEqO1QdEQ811.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-765.png" alt="wKioL1NrDwrDEAnhAABEqO1QdEQ811.jpg"></a></span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">截图如下：</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="553" height="192" src="http://s3.51cto.com/wyfs02/M02/26/43/wKioL1NrDxby9CpwAAFpmoHquWI731.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-778.png" alt="wKioL1NrDxby9CpwAAFpmoHquWI731.jpg"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第四步：</span><span style="font-size:14px;font-family:'宋体';">启动<span style="font-family:'times new roman';">tomcat</span><span style="font-family:'宋体';">，并在浏览器中输入：</span></span><a href="http://localhost:8080/solr/" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://localhost:8080/solr/</span></a><span style="font-size:14px;font-family:'宋体';"> 验证是否配置成功。如果配置成功，浏览器的页面如下：</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="555" height="295" src="http://s3.51cto.com/wyfs02/M01/26/43/wKiom1NrD1ChePyFAAErOVH13Z8549.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-900.png" alt="wKiom1NrD1ChePyFAAErOVH13Z8549.jpg"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">关于<span style="font-family:'times new roman';">solr/home</span><span style="font-family:'宋体';">的设置，其实有三种方法：</span><span style="font-family:'times new roman';">1</span><span style="font-family:'宋体';">、在</span><span style="font-family:'times new roman';">solr</span><span style="font-family:'宋体';">的</span><span style="font-family:'times new roman';">web.xml</span><span style="font-family:'宋体';">中设置，在</span><span style="font-family:'times new roman';">tomcat</span><span style="font-family:'宋体';">启动时附带参数，还有就是本文的方法。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h2 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'黑体';">2.2 <span style="font-family:'黑体';">配置多</span><span style="font-family:arial;">Tomcat+solr</span><span style="font-family:'黑体';">同时运行</span></span><span style="font-weight:bold;font-size:21px;font-family:'黑体';"></span></h2>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第一步：</span><span style="font-weight:bold;font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">把<span style="font-family:'times new roman';">tomcat-server_1</span><span style="font-family:'宋体';">复制</span><span style="font-family:'times new roman';">2</span><span style="font-family:'宋体';">份，分别命名</span><span style="font-family:'times new roman';">tomcat-server_2</span><span style="font-family:'宋体';">，</span><span style="font-family:'times new roman';">tomcat-server_3</span><span style="font-family:'宋体';">；</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">把<span style="font-family:'times new roman';">solr_home_1</span><span style="font-family:'宋体';">复制</span><span style="font-family:'times new roman';">2</span><span style="font-family:'宋体';">份，分别命名</span><span style="font-family:'times new roman';">solr_home_2</span><span style="font-family:'宋体';">，</span><span style="font-family:'times new roman';">solr_home_3</span><span style="font-family:'宋体';">。</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">最后的目录结构如下图：</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="556" height="205" src="http://s3.51cto.com/wyfs02/M00/26/43/wKioL1NrDzDhpmBBAADtVltmdkw864.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-1120.png" alt="wKioL1NrDzDhpmBBAADtVltmdkw864.jpg"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第二步：</span><span style="font-weight:bold;font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">为了三个<span style="font-family:'times new roman';">tomcat</span><span style="font-family:'宋体';">能够在一台机器上同时启动，需要修改</span><span style="font-family:'times new roman';">tomcat</span><span style="font-family:'宋体';">的端口信息。修改方案如下：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <table style="border-collapse:collapse;width:568px;padding:0px 7px 0px 7px;">
  <tbody>
   <tr>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:1px solid #000000;border-right:1px solid #000000;border-top:1px solid #000000;border-bottom:1px solid #000000;background:#b3b3b3;"><br></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:1px solid #000000;border-bottom:1px solid #000000;background:#b3b3b3;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">Tomcat Admin Port</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:1px solid #000000;border-bottom:1px solid #000000;background:#b3b3b3;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">HTTP/1.1 Port</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:1px solid #000000;border-bottom:1px solid #000000;background:#b3b3b3;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">AJP/1.3 &nbsp;Port</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
   <tr>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:1px solid #000000;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;background:#c0c0c0;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_1</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8005</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8080</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8009</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
   <tr>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:1px solid #000000;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;background:#c0c0c0;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_2</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8015</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8090</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8019</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
   <tr>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:1px solid #000000;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;background:#c0c0c0;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_3</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8025</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8100</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="142" valign="top" style="width:142px;padding:0px 7px 0px 7px;border-left:none;border-right:1px solid #000000;border-top:none;border-bottom:1px solid #000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">8029</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
  </tbody>
 </table>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">修改位置在<span style="font-family:'times new roman';">D:\solrCloud\tomcat-server_*\conf\server.xml</span><span style="font-family:'宋体';">里面。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">Tomcat Admin Port:</span><span style="font-weight:bold;font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="556" height="94" src="http://s3.51cto.com/wyfs02/M00/26/43/wKioL1NrDz3T-TWYAACxbvJiUaw864.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-1391.png" alt="wKioL1NrDz3T-TWYAACxbvJiUaw864.jpg"><span style="font-size:14px;font-family:'times new roman';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">HTTP/1.1 Port</span><span style="font-weight:bold;font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="556" height="80" src="http://s3.51cto.com/wyfs02/M02/26/43/wKiom1NrD3GzaoHMAACAAlzHkQY468.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-1407.png" alt="wKiom1NrD3GzaoHMAACAAlzHkQY468.jpg"><span style="font-size:14px;font-family:'times new roman';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">AJP/1.3 &nbsp;Port</span><span style="font-weight:bold;font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="556" height="66" src="http://s3.51cto.com/wyfs02/M00/26/43/wKiom1NrD3yScytgAABiq0Z-ckk358.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-1423.png" alt="wKiom1NrD3yScytgAABiq0Z-ckk358.jpg"><span style="font-size:14px;font-family:'times new roman';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第三步：</span><span style="font-size:14px;font-family:'宋体';">修改各个</span><span style="font-size:14px;font-family:'宋体';">tomcat<span style="font-family:'宋体';">服务器</span><span style="font-family:'times new roman';">catalina.bat</span><span style="font-family:'宋体';">文件里面的</span><span style="font-family:'times new roman';">solrhome</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_2<span style="font-family:'宋体';">修改成</span><span style="font-family:'times new roman';">set JAVA_OPTS=-Dsolr.solr.home=D:/solrCloud/solr_home_2</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_3<span style="font-family:'宋体';">修改成</span><span style="font-family:'times new roman';">set JAVA_OPTS=-Dsolr.solr.home=D:/solrCloud/solr_home_3</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第四步：</span><span style="font-size:14px;font-family:'宋体';">验证修改是否成功，依次启动三个<span style="font-family:'times new roman';">Tomcat</span><span style="font-family:'宋体';">。并在浏览器输入如下的</span><span style="font-family:'times new roman';">URL</span><span style="font-family:'宋体';">：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><a href="http://localhost:8080/solr/" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://localhost:8080/solr/</span></a><span style="font-size:14px;font-family:'宋体';"></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><a href="http://localhost:8080/solr/" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://localhost:8090/solr/</span></a><span style="font-size:14px;font-family:'宋体';"></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-left:28px;margin-bottom:0px;margin-top:0px;"><a href="http://localhost:8080/solr/" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://localhost:8100/solr/</span></a><span style="font-size:14px;font-family:'宋体';"></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">如果都能正常访问到<span style="font-family:'times new roman';">solr</span><span style="font-family:'宋体';">的</span><span style="font-family:'times new roman';">admin</span><span style="font-family:'宋体';">页面，那么说明配置是成功的。否则就需要检查哪里错了或者遗漏了。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h2 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'黑体';">2.3 <span style="font-family:'黑体';">配置</span><span style="font-family:arial;">ZooKeeper</span><span style="font-family:'黑体';">集群</span></span><span style="font-weight:bold;font-size:21px;font-family:'黑体';"></span></h2>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">这部分的内容与前面</span><span style="font-size:14px;font-family:'宋体';">tomcat+solr<span style="font-family:'宋体';">是没有关联的，所以配置这里，可以跟忘记前面的内容。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第一步：</span><span style="font-size:14px;font-family:'宋体';">解压<span style="font-family:'times new roman';">zookeeper-3.4.6.tar.gz</span><span style="font-family:'宋体';">到</span><span style="font-family:'times new roman';">D:/solrCloud</span><span style="font-family:'宋体';">目录，重命名为</span><span style="font-family:'times new roman';">zk-server_1</span><span style="font-family:'宋体';">。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第二步：</span><span style="font-size:14px;font-family:'宋体';">把<span style="font-family:'times new roman';">D:\solrCloud\zk-server_1\conf\</span><span style="font-family:'宋体';">目录下的</span><span style="font-family:'times new roman';">zoo_sample.cfg</span><span style="font-family:'宋体';">修改为</span><span style="font-family:'times new roman';">zoo.cfg</span><span style="font-family:'宋体';">。并写入如下的配置参数：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="556" height="239" src="http://s3.51cto.com/wyfs02/M02/26/43/wKiom1NrD4rzP7OkAAFfqUKxN7I033.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-2131.png" alt="wKiom1NrD4rzP7OkAAFfqUKxN7I033.jpg"><span style="font-size:14px;font-family:'times new roman';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">并且按照配置创建相应的</span><span style="font-size:14px;font-family:'宋体';">data<span style="font-family:'宋体';">和</span><span style="font-family:'times new roman';">logs</span><span style="font-family:'宋体';">目录。如果不不创建目录是无法正常启动的。在</span><span style="font-family:'times new roman';">data</span><span style="font-family:'宋体';">目录中创建文件</span><span style="font-family:'times new roman';">myid(</span><span style="font-family:'宋体';">不需要后缀名</span><span style="font-family:'times new roman';">)</span><span style="font-family:'宋体';">，在</span><span style="font-family:'times new roman';">myid</span><span style="font-family:'宋体';">文件中写入数字</span><span style="font-family:'times new roman';">1</span><span style="font-family:'宋体';">并保存退出。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第三步：</span><span style="font-size:14px;font-family:'宋体';">把</span><span style="font-size:14px;font-family:'宋体';">zk-server_1<span style="font-family:'宋体';">复制</span><span style="font-family:'times new roman';">2</span><span style="font-family:'宋体';">份，分别命名为</span><span style="font-family:'times new roman';">zk-server_2</span><span style="font-family:'宋体';">、</span><span style="font-family:'times new roman';">zk-server_3</span><span style="font-family:'宋体';">。然后修改各个</span><span style="font-family:'times new roman';">zk-server</span><span style="font-family:'宋体';">的</span><span style="font-family:'times new roman';">conf</span><span style="font-family:'宋体';">目录下</span><span style="font-family:'times new roman';">zoo.cfg</span><span style="font-family:'宋体';">的</span><span style="font-family:'times new roman';">dataDir</span><span style="font-family:'宋体';">和</span><span style="font-family:'times new roman';">dataLogDir</span><span style="font-family:'宋体';">和</span><span style="font-family:'times new roman';">clientPort</span><span style="font-family:'宋体';">。修改方案如下：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <table style="border-collapse:collapse;padding:0px 7px;margin-left:-21px;" width="679">
  <tbody>
   <tr>
    <td width="147" valign="top" style="padding:0px 7px;border:1px solid #000000;background-color:#CCCCCC;"><br></td>
    <td width="180" valign="top" style="padding:0px 7px;border-style:solid solid solid none;border-right-width:1px;border-right-color:#000000;border-top-width:1px;border-top-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;background-color:#CCCCCC;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">dataDir</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="210" valign="top" style="padding:0px 7px;border-style:solid solid solid none;border-right-width:1px;border-right-color:#000000;border-top-width:1px;border-top-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;background-color:#CCCCCC;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">dataLogDir</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="83" valign="top" style="padding:0px 7px;border-style:solid solid solid none;border-right-width:1px;border-right-color:#000000;border-top-width:1px;border-top-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;background-color:#CCCCCC;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">clientPort</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
   <tr>
    <td width="147" valign="top" style="padding:0px 7px;border-left-width:1px;border-style:none solid solid;border-left-color:#000000;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;background-color:#E0E0E0;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">zk-server_1/conf/zoo.cfg</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="180" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">D:/solrCloud/zk-server_1/data</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="210" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">D:/solrCloud/zk-server_1/logs</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="83" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">2181</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
   <tr>
    <td width="147" valign="top" style="padding:0px 7px;border-left-width:1px;border-style:none solid solid;border-left-color:#000000;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;background-color:#E0E0E0;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">zk-server_2/conf/zoo.cfg</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="180" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">D:/solrCloud/zk-server_</span><span style="font-size:14px;font-family:'宋体';">2/data</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="210" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">D:/solrCloud/zk-server_</span><span style="font-size:14px;font-family:'宋体';">2</span><span style="font-size:14px;font-family:'宋体';">/logs</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="83" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">2182</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
   <tr>
    <td width="147" valign="top" style="padding:0px 7px;border-left-width:1px;border-style:none solid solid;border-left-color:#000000;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;background-color:#E0E0E0;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">zk-server_3/conf/zoo.cfg</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="180" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">D:/solrCloud/zk-server_3/data</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="210" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">D:/solrCloud/zk-server_3/logs</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
    <td width="83" valign="top" style="padding:0px 7px;border-style:none solid solid none;border-right-width:1px;border-right-color:#000000;border-bottom-width:1px;border-bottom-color:#000000;"><p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">2183</span><span style="font-size:14px;font-family:'宋体';"></span></p><p><br></p></td>
   </tr>
  </tbody>
 </table>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">并且修改每个<span style="font-family:'times new roman';">data</span><span style="font-family:'宋体';">目录下的</span><span style="font-family:'times new roman';">myid</span><span style="font-family:'宋体';">文件中的内容。</span><span style="font-family:'times new roman';">zk-server_1</span><span style="font-family:'宋体';">是</span><span style="font-family:'times new roman';">1</span><span style="font-family:'宋体';">， </span><span style="font-family:'times new roman';">zk-server_2</span><span style="font-family:'宋体';">是</span><span style="font-family:'times new roman';">2</span><span style="font-family:'宋体';">，</span><span style="font-family:'times new roman';">zk-server_3</span><span style="font-family:'宋体';">是</span><span style="font-family:'times new roman';">3 </span><span style="font-family:'宋体';">。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第四步：</span><span style="font-size:14px;font-family:'宋体';">启动三个<span style="font-family:'times new roman';">zk-server</span><span style="font-family:'宋体';">。并验证是否配置成功。我是在程序中验证的，程序代码见附录</span><span style="font-family:'times new roman';">1</span><span style="font-family:'宋体';">。验证方法需参看我的另一篇博客。简而言之就是连接三台服务器的任意一台，创建结点，然后连接另外一台，取得结点的数据，如果能够取到，则说明配置是成功的。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">注意：连接第一台时有异常信息，不用管，等都连接起来就没有异常了。</span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <h2 style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:21px;font-family:'黑体';">2.4 <span style="font-family:'黑体';">配置</span><span style="font-family:arial;">Tomcat+solr+zookeeper</span><span style="font-family:'黑体';">集群</span></span><span style="font-weight:bold;font-size:21px;font-family:'黑体';"></span></h2>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">前面<span style="font-family:'times new roman';">tomcat+solr</span><span style="font-family:'宋体';">能够启动和访问了，而且</span><span style="font-family:'times new roman';">zookeeper</span><span style="font-family:'宋体';">也能启动和访问了。接下来就需要把他们关联起来。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第一步：</span><span style="font-size:14px;font-family:'宋体';">修改<span style="font-family:'times new roman';">solr_home_*</span><span style="font-family:'宋体';">的</span><span style="font-family:'times new roman';">solr.xml</span><span style="font-family:'宋体';">配置信息，把</span><span style="font-family:'times new roman';">hostPort</span><span style="font-family:'宋体';">分别修改成对应的</span><span style="font-family:'times new roman';">tomcat</span><span style="font-family:'宋体';">端口。</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">solr_home_1/solr.xml</span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="556" height="44" src="http://s3.51cto.com/wyfs02/M01/26/43/wKioL1NrD3PCCvd6AABbW_UhzV0155.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-3039.png" alt="wKioL1NrD3PCCvd6AABbW_UhzV0155.jpg"></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">solr_home_2/solr.xml</span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="555" height="40" src="http://s3.51cto.com/wyfs02/M02/26/43/wKioL1NrD4LxgMHdAABcIiLCW7M838.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-3062.png" alt="wKioL1NrD4LxgMHdAABcIiLCW7M838.jpg"></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">solr_home_3/solr.xml</span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><a href="http://s3.51cto.com/wyfs02/M01/26/43/wKiom1NrD63QKMReAABVlW3nP04799.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/26/43/wKiom1NrD63QKMReAABVlW3nP04799.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-3085.png" alt="wKiom1NrD63QKMReAABVlW3nP04799.jpg"></a></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第二步<span style="font-family:'times new roman';">:</span></span><span style="font-size:14px;font-family:'宋体';">修改<span style="font-family:'times new roman';">tomcat-server_*</span><span style="font-family:'宋体';">中的</span><span style="font-family:'times new roman';">catalina.bat</span><span style="font-family:'宋体';">的参数信息。</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_1<span style="font-family:'宋体';">参数信息如下</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">set JAVA_OPTS=-Dsolr.solr.home=D:/solrCloud/solr_home_1 &nbsp;</span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">-Dbootstrap_confdir=D:/solrCloud/solr_home_1/collection1/conf -Dcollection.configName=myconf -DnumShards=2 -DzkHost=127.0.0.1:2181 </span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_2<span style="font-family:'宋体';">的参数信息如下：</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">set JAVA_OPTS=-Dsolr.solr.home=D:/solrCloud/solr_home_2 &nbsp;-DzkHost=127.0.0.1:2181</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">tomcat-server_3<span style="font-family:'宋体';">的参数信息如下：</span></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">set JAVA_OPTS=-Dsolr.solr.home=D:/solrCloud/solr_home_3 &nbsp;-DzkHost=127.0.0.1:2181</span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-weight:bold;font-size:14px;font-family:'宋体';">第三步：</span><span style="font-size:14px;font-family:'宋体';">先启动<span style="font-family:'times new roman';">tomcat-server_1</span><span style="font-family:'宋体';">，然后启动其它的</span><span style="font-family:'times new roman';">tomcat-server</span><span style="font-family:'宋体';">。启动完成后，在浏览器中输入：</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';"><a href="http://localhost:8080/solr/#/~cloud" target="_blank">http://localhost:8080/solr/#/~cloud</a></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';"><a href="http://localhost:8080/solr/#/~cloud" target="_blank">http://localhost:8090/solr/#/~cloud</a></span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><a href="http://localhost:8080/solr/#/~cloud" target="_blank"><span class="15" style="color:#0000ff;text-decoration:underline;font-family:'宋体';">http://localhost:8100/solr/#/~cloud</span></a><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">得到的页面都是一样的：</span></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><img onload="if(this.width>650) this.width=650;" width="555" height="258" src="http://s3.51cto.com/wyfs02/M00/26/43/wKioL1NrD5TSLjTOAAB-1mLVCqk996.jpg" title="2014-5-7_SolrCloud+ZooKeeper+Tomcat单机伪分布式部署 2-3890.png" alt="wKioL1NrD5TSLjTOAAB-1mLVCqk996.jpg"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">这样一个简单的<span style="font-family:'times new roman';">solrCloud</span><span style="font-family:'宋体';">运行环境就搭建起来了。</span></span><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="text-indent:28px;margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';">附录<span style="font-family:'times new roman';">1:</span></span></p>
 <pre class="brush:java;toolbar:false;">package zookeeper_learning;
import java.io.IOException;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
public class ZkClient {
    //创建 一个结点
    public static void create(ZooKeeper zk) throws KeeperException, InterruptedException{
        System.out.println("/n1. 创建 ZooKeeper 节点 (znode ： zoo2, 数据： myData2 ，权限： OPEN_ACL_UNSAFE ，节点类型： Persistent");
        zk.create("/zoo2","myData2".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
                                                                                         
    }
    //修改结点信息
    public static void modify(ZooKeeper zk) throws KeeperException, InterruptedException{
        System.out.println("/n3. 修改节点数据 ");
        zk.setData("/zoo2", "shenlan211314".getBytes(), -1);
    }
    //查看结点信息
    public static void monitor(ZooKeeper zk) throws KeeperException, InterruptedException{
        System.out.println("/n4. 查看节点： ");
        System.out.println(new String(zk.getData("/zoo2", false, null)));
    }
    //查看结点是否存在
    public static void exist(ZooKeeper zk) throws KeeperException, InterruptedException{
        System.out.println("/n6. 查看节点是否被删除： ");
        System.out.println(" 节点状态： ["+zk.exists("/zoo2", false)+"]");
    }
    //删除一个结点
    public static void delete(ZooKeeper zk) throws InterruptedException, KeeperException{
        System.out.println("/n5. 删除节点 ");
        zk.delete("/zoo2", -1);
    }
                                                                                         
    public static ZooKeeper connect(String host) throws IOException{
        return new ZooKeeper(host, 3000, new Watcher(){
            @Override
            public void process(WatchedEvent arg0) {
                System.out.println("watch "+arg0);
            }
        });
    }
                                                                                         
    public static void main(String[] args) {
        try {
            ZooKeeper zk1=connect("0.0.0.0:2181");
            create(zk1);
            //modify(zk1);
            zk1.close();
            ZooKeeper zk2=connect("0.0.0.0:2182");
            monitor(zk2);
            zk2.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
                                                                                         
}</pre>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
 <p class="p0" style="margin-bottom:0px;margin-top:0px;"><span style="font-size:14px;font-family:'宋体';"></span></p>
 <p><br></p>
</div>
<p>本文出自 “<a href="http://sbp810050504.blog.51cto.com">每天进步一点点</a>” 博客，请务必保留此出处<a href="http://sbp810050504.blog.51cto.com/2799422/1408322">http://sbp810050504.blog.51cto.com/2799422/1408322</a></p>
