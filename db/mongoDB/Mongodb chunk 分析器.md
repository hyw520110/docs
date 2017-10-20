近日花时间写了一个Mongodb chunk分析脚本，主要功能就是分析分片的集合在每个片上的分布情况。Mongodb的sharding还是有一些问题，有时会由于片键选择不合理或者删除数据等情况，导致各个片上数据严重不均。Mongodb并没有提供合并chunk的功能，想要合并只能重新导入数据，这其实是个缺陷。虽然并不要求自动合并，因为这个对线上的负担太大，但是还是希望Mongodb能提供这么一个操作，在数据严重不均的时候能够合并分片，重新分配。

执行命令：

    python shard_chunk_analize.py --help

![image](http://blog.chinaunix.net/attachment/201310/22/15795819_1382454926S4Qn.jpg)

	python shard_chunk_analize.py -H 192.168.1.1 -P 27017 -u admin -p
![image](http://blog.chinaunix.net/attachment/201310/22/15795819_1382455212mqsk.jpg)

大图连接http://blog.chinaunix.net/attachment/201310/22/15795819_1382455212mqsk.jpg

可以看出，第一个集合就是严重不平均的，因为之前删除数据，chunk并没有回收。
      Mongos的平衡器只是根据chunk数量去平均的，并不关心chunk里面的数据大小，这其实是比较有缺陷的。在这样的环境下，我们需要谨慎的选择片键，尽可能的让数据平均。


执行条件：

python>=2.7 使用了OrderedDict
    
pymongo>2.4.1 并未严格测试，之前版本也可能支持。
    
请不要在系统压力大的情况下执行,切记！
   
脚本能力有限，见谅，大家如有需要，可自行修改，有任何bug请告诉我：horizonhyg#163.com
           
[shard_chunk_analize.zip](http://blog.chinaunix.net/blog/downLoad/fileid/9277.html)