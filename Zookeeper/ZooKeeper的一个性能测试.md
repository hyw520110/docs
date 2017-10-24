<p>3台ZooKeeper服务器。8核64位jdk1.6；log和snapshot放在不同磁盘</p>
<h2>场景一</h2>
<p>同一个目录下，先createEPHEMERALnode，再delete；create和delete各计一次更新。没有订阅。<br>一个进程开多个连接，每个连接绑定一个线程，在多个path下做上述操作；不同的连接操作的path不同</p>
<p>测试结果数据汇总如下：</p>
<table width="758" style="width:701px;" cellspacing="0" cellpadding="0">
 <colgroup>
  <col width="138">
  <col width="72" span="2">
  <col width="84">
  <col width="72">
  <col width="80">
  <col width="30">
  <col width="138">
  <col width="72">
 </colgroup>
 <tbody>
  <tr>
   <td width="210" height="18" colspan="2">dataSize(字节)</td>
   <td width="72">totalReq</td>
   <td width="84">recentTPS</td>
   <td width="72">avgTPS</td>
   <td width="80">recentRspTim</td>
   <td width="30"></td>
   <td width="138">avgRspTim</td>
   <td width="72">failTotal</td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>4096</td>
   <td></td>
   <td>2037</td>
   <td></td>
   <td>1585</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>1024</td>
   <td></td>
   <td>7677</td>
   <td></td>
   <td>280</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>255</td>
   <td></td>
   <td>14723</td>
   <td></td>
   <td>82</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>说明</td>
   <td>总请求数</td>
   <td>实时TPS</td>
   <td></td>
   <td>实时响应时间(ms)</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
 </tbody>
</table>
<h2>场景二</h2>
<p>一个进程开多个连接，每连接一个线程，每个连接在多个path下做下述操作；不同的连接操作的path不同<br>每个path有3个订阅者连接，一个修改者连接。先全部订阅好。然后每个修改者在自己的每个path下创建一个EPHEMERALnode，不删除；创建前记录时间，订阅者收到event后记录时间(eventStat)；重新get到数据后再记录时间(dataStat)。共1000个pub连接，3000个sub连接，20W条数据。</p>
<table width="721" style="width:701px;" cellspacing="0" cellpadding="0">
 <colgroup>
  <col width="84">
  <col width="138">
  <col width="76">
  <col width="84">
  <col width="60">
  <col width="111">
  <col width="84" span="2">
 </colgroup>
 <tbody>
  <tr>
   <td width="721" height="18" colspan="8">结果汇总：getAfterNotify=false（只收事件，受到通知后不去读取数据）；五台4核client机器</td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>dataSize(字节)</td>
   <td>totalReq</td>
   <td>recentTPS</td>
   <td>avgTPS</td>
   <td>recentRspTim</td>
   <td>avgRspTim</td>
   <td>failTotal</td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>4096</td>
   <td></td>
   <td>8000+</td>
   <td></td>
   <td>520左右</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>2048</td>
   <td></td>
   <td>1W+</td>
   <td></td>
   <td>270左右</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>1024</td>
   <td></td>
   <td>1W+</td>
   <td></td>
   <td>256左右</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>255</td>
   <td></td>
   <td>1W+</td>
   <td></td>
   <td>256左右</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>说明</td>
   <td>总请求数</td>
   <td>实时TPS</td>
   <td></td>
   <td>实时响应时间(ms)</td>
   <td></td>
   <td></td>
  </tr>
 </tbody>
</table>
<p>收到通知后再去读取数据，五台4核client机器</p>
<table width="721" style="width:701px;" cellspacing="0" cellpadding="0">
 <colgroup>
  <col width="84">
  <col width="138">
  <col width="76">
  <col width="84">
  <col width="60">
  <col width="111">
  <col width="84" span="2">
 </colgroup>
 <tbody>
  <tr>
   <td width="84" height="18"></td>
   <td width="138">dataSize(字节)</td>
   <td width="76">totalReq</td>
   <td width="84">recentTPS</td>
   <td width="60">avgTPS</td>
   <td width="111">recentRspTim</td>
   <td width="84">avgRspTim</td>
   <td width="84">failTotal</td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>4096</td>
   <td></td>
   <td>8000+</td>
   <td></td>
   <td>1000左右</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>4096</td>
   <td></td>
   <td>3200</td>
   <td></td>
   <td>2200-2600</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">dataStat</td>
   <td>4096</td>
   <td></td>
   <td>3200</td>
   <td></td>
   <td>4000-4300</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>1024</td>
   <td></td>
   <td>9500</td>
   <td></td>
   <td>400-900</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">dataStat</td>
   <td>1024</td>
   <td></td>
   <td>9500</td>
   <td></td>
   <td>700-1100</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>256</td>
   <td></td>
   <td>8500</td>
   <td></td>
   <td>200-1000</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">dataStat</td>
   <td>256</td>
   <td></td>
   <td>8500</td>
   <td></td>
   <td>300-1400</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>说明</td>
   <td>总请求数</td>
   <td>实时TPS</td>
   <td></td>
   <td>实时响应时间(ms)</td>
   <td></td>
   <td></td>
  </tr>
 </tbody>
</table>
<p>收到通知后再去读取数据，1台8核client机器</p>
<table width="721" style="width:701px;" cellspacing="0" cellpadding="0">
 <colgroup>
  <col width="84">
  <col width="138">
  <col width="76">
  <col width="84">
  <col width="60">
  <col width="111">
  <col width="84" span="2">
 </colgroup>
 <tbody>
  <tr>
   <td width="84" height="18"></td>
   <td width="138">dataSize(字节)</td>
   <td width="76">totalReq</td>
   <td width="84">recentTPS</td>
   <td width="60">avgTPS</td>
   <td width="111">recentRspTim</td>
   <td width="84">avgRspTim</td>
   <td width="84">failTotal</td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>4096</td>
   <td></td>
   <td>5771</td>
   <td></td>
   <td>9604</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>4096</td>
   <td></td>
   <td>5558</td>
   <td></td>
   <td>10633</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">dataStat</td>
   <td>4096</td>
   <td></td>
   <td>5558</td>
   <td></td>
   <td>10743</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>1024</td>
   <td></td>
   <td>6000</td>
   <td></td>
   <td>9400</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">dataStat</td>
   <td>1024</td>
   <td></td>
   <td>6000</td>
   <td></td>
   <td>10000</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">eventStat</td>
   <td>256</td>
   <td></td>
   <td>6374</td>
   <td></td>
   <td>10050</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18">dataStat</td>
   <td>256</td>
   <td></td>
   <td>6374</td>
   <td></td>
   <td>10138</td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>说明</td>
   <td>总请求数</td>
   <td>实时TPS</td>
   <td></td>
   <td>实时响应时间(ms)</td>
   <td></td>
   <td></td>
  </tr>
 </tbody>
</table>
<h2>场景三</h2>
<p>一个进程开多个连接，每连接一个线程，每个连接在多个path下做下述操作；不同的连接操作的path不同<br>每个path有一个修改者连接，没有订阅者。每个修改者在自己的每个path下设置数据。</p>
<table width="758" style="width:701px;" cellspacing="0" cellpadding="0">
 <colgroup>
  <col width="138">
  <col width="72" span="2">
  <col width="84">
  <col width="72">
  <col width="80">
  <col width="30">
  <col width="138">
  <col width="72">
 </colgroup>
 <tbody>
  <tr>
   <td width="758" height="18" colspan="9">结果汇总：getAfterNotify=false（只收事件，受到通知后不去读取数据）；五台4核client机器</td>
  </tr>
  <tr>
   <td height="18" colspan="2">dataSize(字节)</td>
   <td>totalReq</td>
   <td>recentTPS</td>
   <td>avgTPS</td>
   <td>recentRspTim</td>
   <td></td>
   <td>avgRspTim</td>
   <td>failTotal</td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>4096</td>
   <td></td>
   <td>2037</td>
   <td></td>
   <td>1585</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>1024</td>
   <td></td>
   <td>7677</td>
   <td></td>
   <td>280</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>255</td>
   <td></td>
   <td>14723</td>
   <td></td>
   <td>82</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
  <tr>
   <td height="18"></td>
   <td>说明</td>
   <td>总请求数</td>
   <td>实时TPS</td>
   <td></td>
   <td>实时响应时间(ms)</td>
   <td></td>
   <td></td>
   <td></td>
  </tr>
 </tbody>
</table>
<p>总结<br>由于一致性协议带来的额外网络交互，消息开销，以及本地log的IO开销，再加上ZK本身每1000条批量处理1次的优化策略，写入的平均响应时间总会在50-60ms之上。但是整体的TPS还是可观的。单个写入数据的体积越大，响应时间越长，TPS越低，这也是普遍规律了。压测过程中log文件对磁盘的消耗很大。实际运行中应该使用自动脚本定时删除历史log和snapshot文件。</p>
<p></p>
