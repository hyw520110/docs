<p><br></p>
<table>
 <tbody>
  <tr>
   <td width="123" valign="top">Gibhub地址</td>
   <td width="528" valign="top" class="selectTdClass"><a href="https://github.com/zookeeper-user-group/zookeeper/issues/2" title="" target="_blank">https://github.com/zookeeper-user-group/zookeeper/issues/2</a></td>
   <td width="18" valign="top"><br></td>
  </tr>
  <tr>
   <td width="123" valign="top">标题</td>
   <td width="528" valign="top" class="selectTdClass">job 做 ha 问题<span style="line-height:0px;"></span><span style="line-height:0px;"></span><span style="line-height:0px;"></span><span style="line-height:0px;"></span><span style="line-height:0px;"></span></td>
   <td width="18" valign="top"><br></td>
  </tr>
  <tr>
   <td>描述</td>
   <td class="selectTdClass"><p>mogu1986 commented on 25 Mar</p><p>环境:单机zk3.4.5&nbsp;</p><p>cleint : Curator 2.4 session timeout 5s connetion timeout 10s</p><p>我现在有一个job,想做HA功能,用的LeaderLatch , 经常出现LOST, ,不知道有啥折中办法没?</p></td>
   <td><br></td>
  </tr>
  <tr>
   <td>解答</td>
   <td class="selectTdClass"><p>nileader commented on 26 Mar</p><p>5s的超时时间还是略短了。</p><p>另：你zookeeper集群的机器数是几台，客户端进程出现LOST的时候，客户端和服务端的负载情况分别如何?</p><p><br></p><p>mogu1986 commented on 29 Mar</p><p>就只有1 台，机器负载在1左右徘徊， dell R620 服务器，32G内存</p></td>
   <td><br></td>
  </tr>
  <tr>
   <td><br></td>
   <td class="selectTdClass"><br></td>
   <td><br></td>
  </tr>
  <tr>
   <td><br></td>
   <td class="selectTdClass"><br></td>
   <td><br></td>
  </tr>
 </tbody>
</table>
<p><br></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/1589961">http://nileader.blog.51cto.com/1381108/1589961</a></p>
