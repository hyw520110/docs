七月份的Mongodb 热门新闻里有这么一篇文章，How to speed up MongoDB Map Reduce by 20x，通过几种方式提升Mongodb 的Map Reduce性能，作者的实验结果是从1200s到60s，效果斐然。我根据这个做了下试验，果然提升很多，从758秒提升到了50s（测试机器的问题）。翻译一下，并附上测试代码，我是用python测试，替代原文中的js方式,测试中发现js有些问题，还未解决。
      
Mongodb提供了两种方式来进行数据分析，MR（map reduce）和聚合框架。MR比较灵活也容易掌握，（图），在Mongodb的sharding架构上运行非常合适，而且允许更大的吞吐量（聚合框架最大允许返回maxBsonSize的大小，一般为16M，MR没有限制）。从2.4之后的版本，Mongodb的MR性能提升很大，js引擎从蜘蛛猴（Spoider Monkey）改为谷歌的V8引擎，大家都知道V8现今最快。但是MR跑起来还是很慢，不太满足需求。

      
测试步骤：
     
1、插入测试数据：

插入1千万数据，只有一个int类型的字段，字段值为0-1百万，也就是说大约每个数会重复10次。
       

    mongomgr:PRIMARY> for (var i = 0; i < 10000000; ++i){ db.mrtest.insert({ dim0: Math.floor(Math.random()*1000000) });}
    mongomgr:PRIMARY> db.mrtest.stats()
    {
        "ns" : "test.mrtest",
        "count" : 10000000,
        "size" : 360000032,
        "avgObjSize" : 36.0000032,
        "storageSize" : 629612544,
        "numExtents" : 16,
        "nindexes" : 2,
        "lastExtentSize" : 168730624,
        "paddingFactor" : 1,
        "systemFlags" : 1,
        "userFlags" : 0,
        "totalIndexSize" : 543597712,
        "indexSizes" : {
            "_id_" : 292014016,
            "dmi0_1" : 251583696
        },
        "ok" : 1
    }


2、现在我们用MR做group操作，计算重复值，单线程无排序：
           

        #省略一些链接和引用的代码，后边一并放出。
        ....
        map=Code("""
                function(){emit(this.dmi0,1);}
         """)
        reducer=Code("""
                function(key,values){return Array.sum(values)}
         """)
        before=time.time()
        res=test.mrtest.map_reduce(map,reducer,"mrtest_out")
        after=time.time()
        print str(floor(after-before))

这一步在我们的机器上用了758s，共999959条，56M.
     

    mongomgr:PRIMARY> db.mrtest1_out.stats()
    {
        "ns" : "test.mrtest1_out",
        "count" : 999959,
        "size" : 35998556,
        "avgObjSize" : 36.00003200131206,
        "storageSize" : 58441728,
        "numExtents" : 9,
        "nindexes" : 1,
        "lastExtentSize" : 20643840,
        "paddingFactor" : 1,
        "systemFlags" : 1,
        "userFlags" : 0,
        "totalIndexSize" : 27921040,
        "indexSizes" : {
            "_id_" : 27921040
        },
        "ok" : 1
    }


3、单线程，使用排序sort

在MR的运行过程中，map操作会将匹配的数据存到一个临时表里，然后再从临时表里有序的进行reduce操作。如果没有sort函数，那么map的读取将是无序的，每次都要遍历全表。我们看加上sort参数MR性能会不会有提升，前提是先对这个map字段加索引。
      

    db.mrtest.ensureIndex({dmi0:1})

      

        .....
        map=Code("""
                function(){emit(this.dmi0,1);}
         """)
        reducer=Code("""
                function(key,values){return Array.sum(values)}
         """)
        before=time.time()
        res=test.mrtest.map_reduce(map,reducer,"mrtest_out",sort={"dmi0":1})
        after=time.time()
        print str(floor(after-before))

这个参数相当的管用，我的测试时间直接降到了269s。

4、多线程，多数据库

Mongodb不可以对单个MR并行操作，但是可以并行运行多个MR。多核CPU可以提升更多的性能。我们尝试将这个表的数据分为多个chunk，然后并行启动MR，对每个chunk空间进行MR操作。使用Mongodb自带的splitVector命令我们可以很轻松的将表分为多个chunk。
      

    mongomgr:PRIMARY> db.runCommand({"splitVector":"test.mrtest",keyPattern:{dmi0:1},maxChunkSizeBytes:32*1024*1024})
    {
        "timeMillis" : 3599,
        "splitKeys" : [
            {
                "dmi0" : 24952
            },
            {
                "dmi0" : 49968
            },
            {
                "dmi0" : 75041
            },
            {
                "dmi0" : 100060
            },
            {
                "dmi0" : 125107
            },
            {
                "dmi0" : 150000
            },
                    .....]
    }


文中作者提供了一种new ScopedThread（）的方式，但是我测试发现如果数据库由密码，是无法使用的，提示unauthorized。所以，我使用admin库，每次验证，才可执行。
  原文中的js代码：    

    ###原js代码：
    > var res = db.runCommand({splitVector: "test.uniques", keyPattern: {dim0: 1}, maxChunkSizeBytes: 32 *1024 * 1024 })
    > var keys = res.splitKeys
    > keys.length
    39
    > var mapred = function(min, max) {
    return db.runCommand({ mapreduce: "uniques",
    map: function () { emit(this.dim0, 1); },
    reduce: function (key, values) { return Array.sum(values); },
    out: { replace: "mrout" + min, db: "mrdb" + min },
    ###out: "mrout" + min,
    sort: {dim0: 1},
    query: { dim0: { $gte: min, $lt: max } } }) }
    > var numThreads = 4
    > var inc = Math.floor(keys.length / numThreads) + 1
    > threads = []; for (var i = 0; i < numThreads; ++i) { var min = (i == 0) ? 0 : keys[i * inc].dim0; var max = (i * inc + inc >= keys.length) ? MaxKey : keys[i * inc + inc].dim0 ; print("min:" + min + " max:" + max); var t = new ScopedThread(mapred, min, max); threads.push(t); t.start() }
    min:0 max:274736
    min:274736 max:524997
    min:524997 max:775025
    min:775025 max:{ "$maxKey" : 1 }
    connecting to: test
    connecting to: test
    connecting to: test
    connecting to: test
    > for (var i in threads) { var t = threads[i]; t.join(); printjson(t.returnData()); }
    {
            "result" : "mrout0",
            "timeMillis" : 205790,
            "counts" : {
                    "input" : 2750002,
                    "emit" : 2750002,
                    "reduce" : 274828,
                    "output" : 274723
            },
            "ok" : 1
    }


我测试的python源码：

    import pymongo
    from pymongo import MongoClient
    import bson
    from bson import Code,SON
    import time
    from math import floor
    from threading import Thread
    from Queue import Queue

    conn=MongoClient("localhost",20011)
    admin=conn.admin
    flag=admin.authenticate("admin","123")
    test=conn.test
    splitvector=test.command("splitVector","test.mrtest",keyPattern={"dmi0":1},maxChunkSizeBytes=32*1024*1024)
    keys=splitvector["splitKeys"]
    numberThreads=10
    inc=int(floor((len(keys)/numberThreads))+1)
    def mapreduce(min,max):
        conn=MongoClient("localhost",20011)
        admin=conn.admin
        flag=admin.authenticate("admin","123")
        test=conn.test
        map=Code("""
                function(){emit(this.dmi0,1);}
         """)
        reducer=Code("""
                function(key,values){return Array.sum(values)}
         """)
        before=time.time()
        res=test.mrtest.map_reduce(map,reducer,out=SON([("replace","mrres"+str(int(min))),("db","mrdb"+str(int(min)))]),sort={"dmi0":1},query={"dmi0":{"$gte":min,"$lt":max}})
        after=time.time()
        print str(floor(after-before))
    def threadmr(i,q):
        while True:
            print "Thread "+str(i)+":start!"
            task=q.get()
            mapreduce(task.get("min"),task.get("max"))
            q.task_done()
    if __name__=='__main__':
        q=Queue()
        for i in range(numberThreads):
                    worker=Thread(target=threadmr,args=(i,q))
                    worker.setDaemon(True)
                    worker.start()
        for i in range(numberThreads):
            min=0
            if i==0:
                min=0
            else:
                min=keys[i*inc]['dmi0']
            if (i*inc+inc)>=len(keys):
                max=keys[len(keys)-1]['dmi0']
            else:
                max=keys[i*inc+inc]['dmi0']
            dic={}
            dic['min']=min
            dic['max']=max
            q.put(dic)
        q.join()


注意原文代码中标红的地方，其实当out为当前库的时候，效果是不明显的，这步测试我略去了，因为mongodb为库级锁，对单个库的插入是序列化的，多线程并不起作用。当换为多个库的时候，效果异常明显，执行时间为65s-70s。

5、多线程，多数据库，使用纯jsMode。
     
我们将数据拆分之后，10个chunk，每个chunk大概就只有10万条数据，而不是100万，大大减少了MR的执行时间。MR中有一个jsMode参数，当这个参数开启时，MR不会将数据在js和BSON之间互转，而是使用内部JS字典函数（Internal JS dictionary）直接reduce。注意这个字典限制50万个key。
     

    res=test.mrtest.map_reduce(map,reducer,out=SON([("replace","mrres"+str(int(min))),("db","mrdb"+str(int(min)))]),sort={"dmi0":1},query={"dmi0":{"$gte":min,"$lt":max}},jsMode=True)


这次执行又提升了10s，大概在40-50s之间。
    

总结：

mongodb中MR的操作还是比较慢的，需要多重优化才能达到预期。注意点，使用多数据库的时候，必须要使用admin账户，确保有对应权限，否则将无法执行。以后的Mongodb将对splitVector和单数据库的并行MR进行优化，到时将会更加适合这些方法的使用。

参考：

①、http://api.mongodb.org/python/current/examples/aggregation.html

②、http://edgystuff.tumblr.com/post/7624019777/optimizing-map-reduce-with-mongodb