<p>很多人是通过wordcount入门分布式并行计算, 该demo演示了Hadoop的经典实例wordcount的实现</p> 
<p>输入数据：n个数据文件，每个1g大小，为了方面统计，每个文件的数据由“aaa bbb ... ccc”(由空格分割的1k单词组)不断复制组成。</p> 
<p>输出数据：输出这n*1g个数据文件中的每个单词总数</p> 
<p>fourinone简单实现思路，假设有n台计算机，将这n个1g数据文件放置在每台计算机上，每台计算机各自统计1g数据，然后合并得到结果</p> 
<p>WordcountCT:为一个工头实现，它把需要处理的数据文件名称发给各个工人，然后用一个HashMap&lt;String,Integer&gt; wordcount的map用来装结果</p> 
<p>WordcountWK：为一个工人实现，它按照每次读取8m的方式处理文件数据，将文件大小除以8m得到总次数，每次处理过程将字符串进行空格拆分，然后放入本地一个map里，完成后将此map发给工头</p> 
<p>ParkServerDemo: 分布式计算过程的协同服务park</p> 
<p>运行步骤：<br> 1、启动ParkServerDemo（它的IP端口已经在配置文件的PARK部分的SERVERS指定）<br> 2、运行WordcountWK, 通过传入不同的端口指定多个Worker,这里假设在同机演示,ip设置为localhost<br> 3、运行WordcountCT，传入文件路径（假设多个工人处理相同数据文件）</p> 
<p>思维发散：如果将以上实现部署到分布式环境里，它是1*n的并行计算模式，也就是每台机器一个计算实例，fourinone可以支持充分利用一台机器的并行计算能力，可以进行n*n的并行计算模式，比如，每台机器4个实例，每个只需要计算256m，总共1g，这样整体的速度会大幅上升，以下是就wordcount和hadoop的运行对比结果：</p> 
<p><a href="http://img1.51cto.com/attachment/201210/141241758.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" border="0" alt="" src="http://img1.51cto.com/attachment/201210/141241758.jpg"></a></p> 
<p>demo源码和开发包下载：<br> <a rel="nofollow" href="http://www.skycn.com/soft/68321.html">http://www.skycn.com/soft/68321.html</a></p>
