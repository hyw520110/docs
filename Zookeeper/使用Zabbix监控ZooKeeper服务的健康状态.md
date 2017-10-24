<p><span style="color:rgb(112,48,160);">一 应用场景描述</span></p>
<p>在目前公司的业务中，没有太多使用ZooKeeper作为协同服务的场景。但是我们将使用Codis作为Redis的集群部署方案，Codis依赖ZooKeeper来存储配置信息。所以做好ZooKeeper的监控也很重要。</p>
<p><br></p>
<p><span style="color:rgb(112,48,160);">二 ZooKeeper监控要点</span></p>
<p><span style="color:#7030a0;">系统监控</span></p>
<p>内存使用量 &nbsp; &nbsp;ZooKeeper应当完全运行在内存中，不能使用到SWAP。Java Heap大小不能超过可用内存。<br></p>
<p>Swap使用量 &nbsp; &nbsp;使用Swap会降低ZooKeeper的性能，设置vm.swappiness = 0</p>
<p>网络带宽占用 &nbsp; 如果发现ZooKeeper性能降低关注下网络带宽占用情况和丢包情况，通常情况下ZooKeeper是20%写入80%读入</p>
<p>磁盘使用量 &nbsp; &nbsp;ZooKeeper数据目录使用情况需要注意</p>
<p>磁盘I/O &nbsp; &nbsp; &nbsp;ZooKeeper的磁盘写入是异步的，所以不会存在很大的I/O请求，如果ZooKeeper和其他I/O密集型服务公用应该关注下磁盘I/O情况</p>
<p><br></p>
<p><span style="color:rgb(112,48,160);">ZooKeeper监控</span></p>
<p>zk_avg/min/max_latency&nbsp; &nbsp; 响应一个客户端请求的时间，建议这个时间大于10个Tick就报警</p>
<p>zk_outstanding_requests&nbsp; &nbsp; &nbsp; &nbsp; 排队请求的数量，当ZooKeeper超过了它的处理能力时，这个值会增大，建议设置报警阀值为10<br></p>
<p>zk_packets_received&nbsp; &nbsp; &nbsp; 接收到客户端请求的包数量<br></p>
<p>zk_packets_sent&nbsp; &nbsp; &nbsp; &nbsp; 发送给客户单的包数量，主要是响应和通知<br></p>
<p>zk_max_file_descriptor_count &nbsp; 最大允许打开的文件数，由ulimit控制</p>
<p>zk_open_file_descriptor_count &nbsp; &nbsp;打开文件数量，当这个值大于允许值得85%时报警</p>
<p>Mode &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;运行的角色，如果没有加入集群就是standalone,加入集群式follower或者leader<br></p>
<p>zk_followers &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;leader角色才会有这个输出,集合中follower的个数。正常的值应该是集合成员的数量减1</p>
<p>zk_pending_syncs&nbsp; &nbsp; &nbsp; &nbsp;leader角色才会有这个输出，pending syncs的数量</p>
<p>zk_znode_count &nbsp; &nbsp; &nbsp; &nbsp; znodes的数量</p>
<p>zk_watch_count &nbsp; &nbsp; &nbsp; &nbsp; watches的数量</p>
<p>Java Heap Size &nbsp; &nbsp; &nbsp; &nbsp; ZooKeeper Java进程的</p>
<p><br></p>
<pre class="brush:plain;toolbar:false">#&nbsp;echo&nbsp;ruok|nc&nbsp;127.0.0.1&nbsp;2181
imok


#&nbsp;echo&nbsp;mntr|nc&nbsp;127.0.0.1&nbsp;2181
zk_version	3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
zk_avg_latency	0
zk_max_latency	0
zk_min_latency	0
zk_packets_received	11
zk_packets_sent	10
zk_num_alive_connections	1
zk_outstanding_requests	0
zk_server_state	leader
zk_znode_count	17159
zk_watch_count	0
zk_ephemerals_count	1
zk_approximate_data_size	6666471
zk_open_file_descriptor_count	29
zk_max_file_descriptor_count	102400
zk_followers	2
zk_synced_followers	2
zk_pending_syncs	0


#&nbsp;echo&nbsp;srvr|nc&nbsp;127.0.0.1&nbsp;2181
Zookeeper&nbsp;version:&nbsp;3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
Latency&nbsp;min/avg/max:&nbsp;0/0/0
Received:&nbsp;26
Sent:&nbsp;25
Connections:&nbsp;1
Outstanding:&nbsp;0
Zxid:&nbsp;0x500000000
Mode:&nbsp;leader
Node&nbsp;count:&nbsp;17159</pre>
<p><br></p>
<p><span style="color:rgb(112,48,160);">三 编写Zabbix监控ZooKeeper的脚本和配置文件</span></p>
<p>要让Zabbix收集到这些监控数据，有两种方法一种是每个监控项目通过zabbix agent单独获取，主动监控和被动监控都可以。还有一种方法就是将这些监控数据一次性使用zabbix_sender全部发送给zabbix。这里我们选择第二种方式。那么采用zabbix_sender一次性发送全部监控数据的脚本就不能像通过zabbix agent这样逐个获取监控项目来编写脚本。</p>
<p>首先想办法将监控项目汇集成一个字典，然后遍历这个字典，将字典中的key:value对通过zabbix_sender的-k和-o参数指定发送出去</p>
<p><br></p>
<p>echo mntr|nc 127.0.0.1 2181</p>
<p>这条命令可以使用Python的subprocess模块调用，也可以使用socket模块去访问2181端口然后发送命令获取数据，获取到mntr执行的数据后还需要将其转化成为字典数据</p>
<p>即需要将这种样式的数据</p>
<pre class="brush:plain;toolbar:false">zk_version	3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
zk_avg_latency	0
zk_max_latency	0
zk_min_latency	0
zk_packets_received	91
zk_packets_sent	90
zk_num_alive_connections	1
zk_outstanding_requests	0
zk_server_state	follower
zk_znode_count	17159
zk_watch_count	0
zk_ephemerals_count	1
zk_approximate_data_size	6666471
zk_open_file_descriptor_count	27
zk_max_file_descriptor_count	102400</pre>
<p><br></p>
<p>转换成为这样的数据</p>
<pre class="brush:plain;toolbar:false">{'zk_followers':&nbsp;2,&nbsp;'zk_outstanding_requests':&nbsp;0,&nbsp;'zk_approximate_data_size':&nbsp;6666471,&nbsp;'zk_packets_sent':&nbsp;2089,&nbsp;'zk_pending_syncs':&nbsp;0,&nbsp;'zk_avg_latency':&nbsp;0,&nbsp;'zk_version':&nbsp;'3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT',&nbsp;'zk_watch_count':&nbsp;2,&nbsp;'zk_packets_received':&nbsp;2090,&nbsp;'zk_open_file_descriptor_count':&nbsp;30,&nbsp;'zk_server_ruok':&nbsp;'imok',&nbsp;'zk_server_state':&nbsp;'leader',&nbsp;'zk_synced_followers':&nbsp;2,&nbsp;'zk_max_latency':&nbsp;28,&nbsp;'zk_num_alive_connections':&nbsp;2,&nbsp;'zk_min_latency':&nbsp;0,&nbsp;'zk_ephemerals_count':&nbsp;1,&nbsp;'zk_znode_count':&nbsp;17159,&nbsp;'zk_max_file_descriptor_count':&nbsp;102400}</pre>
<p><br></p>
<p><br></p>
<p>到最后需要使用zabbix_sender发送的数据格式这个样子的</p>
<p>zookeeper.status[zk_version]这是key的名称</p>
<pre class="brush:plain;toolbar:false">zookeeper.status[zk_outstanding_requests]:0
zookeeper.status[zk_approximate_data_size]:6666471
zookeeper.status[zk_packets_sent]:48
zookeeper.status[zk_avg_latency]:0
zookeeper.status[zk_version]:3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
zookeeper.status[zk_watch_count]:0
zookeeper.status[zk_packets_received]:49
zookeeper.status[zk_open_file_descriptor_count]:27
zookeeper.status[zk_server_ruok]:imok
zookeeper.status[zk_server_state]:follower
zookeeper.status[zk_max_latency]:0
zookeeper.status[zk_num_alive_connections]:1
zookeeper.status[zk_min_latency]:0
zookeeper.status[zk_ephemerals_count]:1
zookeeper.status[zk_znode_count]:17159
zookeeper.status[zk_max_file_descriptor_count]:102400</pre>
<p><br></p>
<p><br></p>
<p>精简代码如下：</p>
<pre class="brush:python;toolbar:false">#!/usr/bin/python
import&nbsp;socket
#from&nbsp;StringIO&nbsp;import&nbsp;StringIO
from&nbsp;cStringIO&nbsp;import&nbsp;StringIO
s=socket.socket()
s.connect(('localhost',2181))
s.send('mntr')
data_mntr=s.recv(2048)
s.close()
#print&nbsp;data_mntr
h=StringIO(data_mntr)
result={}
zresult={}
for&nbsp;line&nbsp;in&nbsp;&nbsp;h.readlines():
&nbsp;&nbsp;&nbsp;&nbsp;key,value=map(str.strip,line.split('\t'))
&nbsp;&nbsp;&nbsp;&nbsp;zkey='zookeeper.status'&nbsp;+&nbsp;'['&nbsp;+&nbsp;key&nbsp;+&nbsp;']'
&nbsp;&nbsp;&nbsp;&nbsp;zvalue=value
&nbsp;&nbsp;&nbsp;&nbsp;result[key]=value
&nbsp;&nbsp;&nbsp;&nbsp;zresult[zkey]=zvalue
print&nbsp;result
print&nbsp;'\n\n'
print&nbsp;zresult</pre>
<pre class="brush:plain;toolbar:false">#&nbsp;python&nbsp;test.py&nbsp;
{'zk_outstanding_requests':&nbsp;'0',&nbsp;'zk_approximate_data_size':&nbsp;'6666471',&nbsp;'zk_max_latency':&nbsp;'0',&nbsp;'zk_avg_latency':&nbsp;'0',&nbsp;'zk_version':&nbsp;'3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT',&nbsp;'zk_watch_count':&nbsp;'0',&nbsp;'zk_num_alive_connections':&nbsp;'1',&nbsp;'zk_open_file_descriptor_count':&nbsp;'27',&nbsp;'zk_server_state':&nbsp;'follower',&nbsp;'zk_packets_sent':&nbsp;'542',&nbsp;'zk_packets_received':&nbsp;'543',&nbsp;'zk_min_latency':&nbsp;'0',&nbsp;'zk_ephemerals_count':&nbsp;'1',&nbsp;'zk_znode_count':&nbsp;'17159',&nbsp;'zk_max_file_descriptor_count':&nbsp;'102400'}


{'zookeeper.status[zk_watch_count]':&nbsp;'0',&nbsp;'zookeeper.status[zk_avg_latency]':&nbsp;'0',&nbsp;'zookeeper.status[zk_max_latency]':&nbsp;'0',&nbsp;'zookeeper.status[zk_approximate_data_size]':&nbsp;'6666471',&nbsp;'zookeeper.status[zk_server_state]':&nbsp;'follower',&nbsp;'zookeeper.status[zk_num_alive_connections]':&nbsp;'1',&nbsp;'zookeeper.status[zk_min_latency]':&nbsp;'0',&nbsp;'zookeeper.status[zk_outstanding_requests]':&nbsp;'0',&nbsp;'zookeeper.status[zk_packets_received]':&nbsp;'543',&nbsp;'zookeeper.status[zk_ephemerals_count]':&nbsp;'1',&nbsp;'zookeeper.status[zk_znode_count]':&nbsp;'17159',&nbsp;'zookeeper.status[zk_packets_sent]':&nbsp;'542',&nbsp;'zookeeper.status[zk_open_file_descriptor_count]':&nbsp;'27',&nbsp;'zookeeper.status[zk_max_file_descriptor_count]':&nbsp;'102400',&nbsp;'zookeeper.status[zk_version]':&nbsp;'3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT'}</pre>
<p><br></p>
<p><br></p>
<p>详细代码如下：</p>
<pre class="brush:python;toolbar:false">#!/usr/bin/python


"""&nbsp;Check&nbsp;Zookeeper&nbsp;Cluster

zookeeper&nbsp;version&nbsp;should&nbsp;be&nbsp;newer&nbsp;than&nbsp;3.4.x

#&nbsp;echo&nbsp;mntr|nc&nbsp;127.0.0.1&nbsp;2181
zk_version	3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
zk_avg_latency	0
zk_max_latency	4
zk_min_latency	0
zk_packets_received	84467
zk_packets_sent	84466
zk_num_alive_connections	3
zk_outstanding_requests	0
zk_server_state	follower
zk_znode_count	17159
zk_watch_count	2
zk_ephemerals_count	1
zk_approximate_data_size	6666471
zk_open_file_descriptor_count	29
zk_max_file_descriptor_count	102400

#&nbsp;echo&nbsp;ruok|nc&nbsp;127.0.0.1&nbsp;2181
imok

"""

import&nbsp;sys
import&nbsp;socket
import&nbsp;re
import&nbsp;subprocess
from&nbsp;StringIO&nbsp;import&nbsp;StringIO
import&nbsp;os


zabbix_sender&nbsp;=&nbsp;'/opt/app/zabbix/sbin/zabbix_sender'
zabbix_conf&nbsp;=&nbsp;'/opt/app/zabbix/conf/zabbix_agentd.conf'
send_to_zabbix&nbsp;=&nbsp;1



#############&nbsp;get&nbsp;zookeeper&nbsp;server&nbsp;status
class&nbsp;ZooKeeperServer(object):

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;__init__(self,&nbsp;host='localhost',&nbsp;port='2181',&nbsp;timeout=1):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self._address&nbsp;=&nbsp;(host,&nbsp;int(port))
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self._timeout&nbsp;=&nbsp;timeout
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self._result&nbsp;&nbsp;=&nbsp;{}

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;_create_socket(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;socket.socket()


&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;_send_cmd(self,&nbsp;cmd):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""&nbsp;Send&nbsp;a&nbsp;4letter&nbsp;word&nbsp;command&nbsp;to&nbsp;the&nbsp;server&nbsp;"""
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s&nbsp;=&nbsp;self._create_socket()
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s.settimeout(self._timeout)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s.connect(self._address)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s.send(cmd)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;data&nbsp;=&nbsp;s.recv(2048)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s.close()

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;data

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;get_stats(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""&nbsp;Get&nbsp;ZooKeeper&nbsp;server&nbsp;stats&nbsp;as&nbsp;a&nbsp;map&nbsp;"""
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;data_mntr&nbsp;=&nbsp;self._send_cmd('mntr')
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;data_ruok&nbsp;=&nbsp;self._send_cmd('ruok')
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;data_mntr:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;result_mntr&nbsp;=&nbsp;self._parse(data_mntr)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;data_ruok:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;result_ruok&nbsp;=&nbsp;self._parse_ruok(data_ruok)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self._result&nbsp;=&nbsp;dict(result_mntr.items()&nbsp;+&nbsp;result_ruok.items())
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;not&nbsp;self._result.has_key('zk_followers')&nbsp;and&nbsp;not&nbsp;self._result.has_key('zk_synced_followers')&nbsp;and&nbsp;not&nbsp;self._result.has_key('zk_pending_syncs'):

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#####&nbsp;the&nbsp;tree&nbsp;metrics&nbsp;only&nbsp;exposed&nbsp;on&nbsp;leader&nbsp;role&nbsp;zookeeper&nbsp;server,&nbsp;we&nbsp;just&nbsp;set&nbsp;the&nbsp;followers'&nbsp;to&nbsp;0
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;leader_only&nbsp;=&nbsp;{'zk_followers':0,'zk_synced_followers':0,'zk_pending_syncs':0}&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self._result&nbsp;=&nbsp;dict(result_mntr.items()&nbsp;+&nbsp;result_ruok.items()&nbsp;+&nbsp;leader_only.items()&nbsp;)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;self._result&nbsp;&nbsp;



&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;_parse(self,&nbsp;data):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""&nbsp;Parse&nbsp;the&nbsp;output&nbsp;from&nbsp;the&nbsp;'mntr'&nbsp;4letter&nbsp;word&nbsp;command&nbsp;"""
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;h&nbsp;=&nbsp;StringIO(data)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;result&nbsp;=&nbsp;{}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for&nbsp;line&nbsp;in&nbsp;h.readlines():
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;key,&nbsp;value&nbsp;=&nbsp;self._parse_line(line)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;result[key]&nbsp;=&nbsp;value
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;except&nbsp;ValueError:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pass&nbsp;#&nbsp;ignore&nbsp;broken&nbsp;lines

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;result

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;_parse_ruok(self,&nbsp;data):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""&nbsp;Parse&nbsp;the&nbsp;output&nbsp;from&nbsp;the&nbsp;'ruok'&nbsp;4letter&nbsp;word&nbsp;command&nbsp;"""
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;h&nbsp;=&nbsp;StringIO(data)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;result&nbsp;=&nbsp;{}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruok&nbsp;=&nbsp;h.readline()
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;ruok:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;result['zk_server_ruok']&nbsp;=&nbsp;ruok
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;result
&nbsp;


&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;_parse_line(self,&nbsp;line):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;key,&nbsp;value&nbsp;=&nbsp;map(str.strip,&nbsp;line.split('\t'))
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;except&nbsp;ValueError:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;raise&nbsp;ValueError('Found&nbsp;invalid&nbsp;line:&nbsp;%s'&nbsp;%&nbsp;line)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;not&nbsp;key:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;raise&nbsp;ValueError('The&nbsp;key&nbsp;is&nbsp;mandatory&nbsp;and&nbsp;should&nbsp;not&nbsp;be&nbsp;empty')

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value&nbsp;=&nbsp;int(value)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;except&nbsp;(TypeError,&nbsp;ValueError):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pass

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;key,&nbsp;value



&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;get_pid(self):
#&nbsp;&nbsp;ps&nbsp;-ef|grep&nbsp;java|grep&nbsp;zookeeper|awk&nbsp;'{print&nbsp;$2}'
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pidarg&nbsp;=&nbsp;'''ps&nbsp;-ef|grep&nbsp;java|grep&nbsp;zookeeper|grep&nbsp;-v&nbsp;grep|awk&nbsp;'{print&nbsp;$2}'&nbsp;'''&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pidout&nbsp;=&nbsp;subprocess.Popen(pidarg,shell=True,stdout=subprocess.PIPE)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pid&nbsp;=&nbsp;pidout.stdout.readline().strip('\n')
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;pid


&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;send_to_zabbix(self,&nbsp;metric):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;key&nbsp;=&nbsp;"zookeeper.status["&nbsp;+&nbsp;&nbsp;metric&nbsp;+&nbsp;"]"

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;send_to_zabbix&nbsp;&gt;&nbsp;0:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#print&nbsp;key&nbsp;+&nbsp;":"&nbsp;+&nbsp;str(self._result[metric])
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;subprocess.call([zabbix_sender,&nbsp;"-c",&nbsp;zabbix_conf,&nbsp;"-k",&nbsp;key,&nbsp;"-o",&nbsp;str(self._result[metric])&nbsp;],&nbsp;stdout=FNULL,&nbsp;stderr=FNULL,&nbsp;shell=False)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;except&nbsp;OSError,&nbsp;detail:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;"Something&nbsp;went&nbsp;wrong&nbsp;while&nbsp;exectuting&nbsp;zabbix_sender&nbsp;:&nbsp;",&nbsp;detail
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;else:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;"Simulation:&nbsp;the&nbsp;following&nbsp;command&nbsp;would&nbsp;be&nbsp;execucted&nbsp;:\n",&nbsp;zabbix_sender,&nbsp;"-c",&nbsp;zabbix_conf,&nbsp;"-k",&nbsp;key,&nbsp;"-o",&nbsp;self._result[metric],&nbsp;"\n"




def&nbsp;usage():
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""Display&nbsp;program&nbsp;usage"""

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;"\nUsage&nbsp;:&nbsp;",&nbsp;sys.argv[0],&nbsp;"&nbsp;alive|all"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;"Modes&nbsp;:&nbsp;\n\talive&nbsp;:&nbsp;Return&nbsp;pid&nbsp;of&nbsp;running&nbsp;zookeeper\n\tall&nbsp;:&nbsp;Send&nbsp;zookeeper&nbsp;stats&nbsp;as&nbsp;well"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sys.exit(1)



accepted_modes&nbsp;=&nbsp;['alive',&nbsp;'all']

if&nbsp;len(sys.argv)&nbsp;==&nbsp;2&nbsp;and&nbsp;sys.argv[1]&nbsp;in&nbsp;accepted_modes:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mode&nbsp;=&nbsp;sys.argv[1]
else:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;usage()




zk&nbsp;=&nbsp;ZooKeeperServer()
#&nbsp;&nbsp;print&nbsp;zk.get_stats()
pid&nbsp;=&nbsp;zk.get_pid()

if&nbsp;pid&nbsp;!=&nbsp;""&nbsp;and&nbsp;&nbsp;mode&nbsp;==&nbsp;'all':
&nbsp;&nbsp;&nbsp;zk.get_stats()
&nbsp;&nbsp;&nbsp;#&nbsp;print&nbsp;zk._result
&nbsp;&nbsp;&nbsp;FNULL&nbsp;=&nbsp;open(os.devnull,&nbsp;'w')
&nbsp;&nbsp;&nbsp;for&nbsp;key&nbsp;in&nbsp;zk._result:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk.send_to_zabbix(key)
&nbsp;&nbsp;&nbsp;FNULL.close()
&nbsp;&nbsp;&nbsp;print&nbsp;pid

elif&nbsp;pid&nbsp;!=&nbsp;""&nbsp;and&nbsp;mode&nbsp;==&nbsp;"alive":
&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;pid
else:
&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;0</pre>
<p><br></p>
<p><br></p>
<p><br></p>
<p>zabbix配置文件check_zookeeper.conf</p>
<pre class="brush:plain;toolbar:false">UserParameter=zookeeper.status[*],/usr/bin/python&nbsp;/opt/app/zabbix/sbin/check_zookeeper.py&nbsp;$1</pre>
<p><br></p>
<p>重新启动zabbix agent服务</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><span style="color:rgb(112,48,160);">四 制作Zabbix监控ZooKeeper的模板并设置报警阀值</span></p>
<p>模板参见附件</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>参考文档：</p>
<p><a href="https://blog.serverdensity.com/how-to-monitor-zookeeper/" target="_blank">https://blog.serverdensity.com/how-to-monitor-zookeeper/</a> </p>
<p><a href="https://github.com/apache/zookeeper/tree/trunk/src/contrib/monitoring" target="_blank">https://github.com/apache/zookeeper/tree/trunk/src/contrib/monitoring</a> </p>
<p><a href="http://john88wang.blog.51cto.com/2165294/1708302" target="_blank">http://john88wang.blog.51cto.com/2165294/1708302</a> </p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>本文出自 “<a href="http://john88wang.blog.51cto.com">Linux SA John</a>” 博客，请务必保留此出处<a href="http://john88wang.blog.51cto.com/2165294/1745339">http://john88wang.blog.51cto.com/2165294/1745339</a></p>
