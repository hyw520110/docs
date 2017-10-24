<p>进入hbase shell之后，执行list命令，报错如下</p>
<pre class="brush:bash;toolbar:false">15/04/23&nbsp;15:24:31&nbsp;ERROR&nbsp;client.HConnectionManager$HConnectionImplementation:&nbsp;Check&nbsp;the&nbsp;value&nbsp;configured&nbsp;in&nbsp;'zookeeper.znode.parent'.&nbsp;There&nbsp;could&nbsp;be&nbsp;a&nbsp;mismatch&nbsp;with&nbsp;the&nbsp;one&nbsp;configured&nbsp;in&nbsp;the&nbsp;master.</pre>
<p><a href="http://s3.51cto.com/wyfs02/M00/6B/DF/wKiom1U4pNTj768jAAgEVizMkHI576.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/6B/DF/wKiom1U4pNTj768jAAgEVizMkHI576.jpg" title="1.png" style="float:none;" alt="wKiom1U4pNTj768jAAgEVizMkHI576.jpg"></a><br></p>
<p><span style="color:rgb(102,102,102);font-family:'Microsoft YaHei';line-height:26px;background-color:rgb(255,255,255);">查看Hbase下的logs目录，查看了其输出的日志信息</span><br style="color:rgb(102,102,102);font-family:'Microsoft YaHei';line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><span style="color:rgb(102,102,102);font-family:'Microsoft YaHei';line-height:26px;background-color:rgb(255,255,255);">Could not start ZK at requested port of 2181. ZK was started at port:2182. Aborting as clients(e.g. shell) will not be able to find this ZK quorum.</span></p>
<p>怀疑Zookeeper默认端口<span style="color:rgb(102,102,102);font-family:'Microsoft YaHei';line-height:26px;background-color:rgb(255,255,255);">2181被占用，</span></p>
<p><span style="color:rgb(102,102,102);font-family:'Microsoft YaHei';line-height:26px;background-color:rgb(255,255,255);">1、使用命令lsof -i:2181查看端口被占用情况</span></p>
<p><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/6B/DC/wKioL1U4pjWwHyB8AAZBfjkl9G4282.jpg" style="float:none;" title="端口被占用.png" alt="wKioL1U4pjWwHyB8AAZBfjkl9G4282.jpg"><br></p>
<p>2、杀死占用端口的进程</p>
<p>3、重新启动hbase,进入shell，执行list命令</p>
<p><a href="http://s3.51cto.com/wyfs02/M01/6B/DF/wKiom1U4pNvQxW7gAAdARzDneGI964.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/6B/DF/wKiom1U4pNvQxW7gAAdARzDneGI964.jpg" style="float:none;" title="重启hbase.png" alt="wKiom1U4pNvQxW7gAAdARzDneGI964.jpg"></a></p>
<p><br></p>
<p><br></p>
