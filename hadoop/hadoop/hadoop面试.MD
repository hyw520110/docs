对于正在找大数据相关工作的同学们来说，面试时遇到什么问题才是他们最关心的。在下文中，本文专门搜集了86道hadoop面试时出现过的题目，希望助同学们面试一臂之力。
1.0   简要描述如何安装配置apache的一个开源hadoop，只描述即可，无需列出具体步骤，列出具体步骤更好。
答：
1使用root账户登录
2 修改IP
3 修改host主机名
4 配置SSH免密码登录
5 关闭防火墙
6  安装JDK
7 解压hadoop安装包
8 配置hadoop的核心文件 hadoop-env.sh，core-site.xml , mapred-site.xml ， hdfs-site.xml
9 配置hadoop环境变量
10 格式化 hadoop namenode-format
11 启动节点start-all.sh
 
2.0 请列出正常的hadoop集群中hadoop都分别需要启动 哪些进程，他们的作用分别都是什么，请尽量列的详细一些。
       答：namenode：负责管理hdfs中文件块的元数据，响应客户端请求，管理datanode上文件block的均衡，维持副本数量
Secondname:主要负责做checkpoint操作；也可以做冷备，对一定范围内数据做快照性备份。
Datanode:存储数据块，负责客户端对数据块的io请求
Jobtracker :管理任务，并将任务分配给 tasktracker。
Tasktracker: 执行JobTracker分配的任务。
Resourcemanager
Nodemanager
Journalnode
Zookeeper
Zkfc
 
3.0请写出以下的shell命令 
（1）杀死一个job
（2）删除hdfs上的 /tmp/aaa目录
（3）加入一个新的存储节点和删除一个节点需要执行的命令
答：（1）hadoop job –list   得到job的id，然后执      行 hadoop job  -kill  jobId就可以杀死一个指定jobId的job工作了。
（2）hadoopfs  -rmr /tmp/aaa
(3)  增加一个新的节点在新的几点上执行
            Hadoop  daemon.sh start  datanode
                     Hadooop daemon.sh  start  tasktracker/nodemanager
 
下线时，要在conf目录下的excludes文件中列出要下线的datanode机器主机名
              然后在主节点中执行  hadoop  dfsadmin  -refreshnodes  à下线一个datanode
删除一个节点的时候，只需要在主节点执行
 hadoop mradmin -refreshnodes  ---à下线一个tasktracker/nodemanager
 
4.0      请列出你所知道的hadoop调度器，并简要说明其工作方法
答：Fifo schedular :默认，先进先出的原则
Capacity schedular :计算能力调度器，选择占用最小、优先级高的先执行，依此类推。
Fair schedular:公平调度，所有的 job 具有相同的资源。
 
5.0      请列出你在工作中使用过的开发mapreduce的语言
答：java，hive，（python，c++）hadoop streaming
 
6.0      当前日志采样格式为
           a , b , c , d
           b , b , f , e
           a , a , c , f        
请你用最熟悉的语言编写mapreduce，计算第四列每个元素出现的个数
 
答：
public classWordCount1 {
       public static final String INPUT_PATH ="hdfs://hadoop0:9000/in";
       public static final String OUT_PATH ="hdfs://hadoop0:9000/out";
       public static void main(String[] args)throws Exception {
              Configuration conf = newConfiguration();
              FileSystem fileSystem =FileSystem.get(conf);
              if(fileSystem.exists(newPath(OUT_PATH))){}
              fileSystem.delete(newPath(OUT_PATH),true);
              Job job = newJob(conf,WordCount1.class.getSimpleName());
              //1.0读取文件，解析成key,value对
              FileInputFormat.setInputPaths(job,newPath(INPUT_PATH));
              //2.0写上自己的逻辑，对输入的可以，value进行处理，转换成新的key,value对进行输出
              job.setMapperClass(MyMapper.class);
              job.setMapOutputKeyClass(Text.class);
              job.setMapOutputValueClass(LongWritable.class);
              //3.0对输出后的数据进行分区
              //4.0对分区后的数据进行排序，分组，相同key的value放到一个集合中
              //5.0对分组后的数据进行规约
              //6.0对通过网络将map输出的数据拷贝到reduce节点
              //7.0 写上自己的reduce函数逻辑，对map输出的数据进行处理
              job.setReducerClass(MyReducer.class);
              job.setOutputKeyClass(Text.class);
              job.setOutputValueClass(LongWritable.class);
              FileOutputFormat.setOutputPath(job,new Path(OUT_PATH));
              job.waitForCompletion(true);
       }
       static class MyMapper extendsMapper<LongWritable, Text, Text, LongWritable>{
              @Override
              protected void map(LongWritablek1, Text v1,
                            org.apache.hadoop.mapreduce.Mapper.Contextcontext)
                            throws IOException,InterruptedException {
                     String[] split =v1.toString().split("\t");
                     for(String words :split){
                            context.write(split[3],1);
                     }
              }
       }
       static class MyReducer extends Reducer<Text,LongWritable, Text, LongWritable>{
             
              protected void reduce(Text k2,Iterable<LongWritable> v2,
                            org.apache.hadoop.mapreduce.Reducer.Contextcontext)
                            throws IOException,InterruptedException {
                     Long count = 0L;
                     for(LongWritable time :v2){
                            count += time.get();
                     }
                     context.write(v2, newLongWritable(count));
              }
       }
}
 
7.0      你认为用java ， streaming ， pipe方式开发map/reduce ， 各有哪些优点
就用过 java 和 hiveQL。
Java 写 mapreduce 可以实现复杂的逻辑，如果需求简单，则显得繁琐。
HiveQL 基本都是针对 hive 中的表数据进行编写，但对复杂的逻辑（杂）很难进行实现。写起来简单。
 
8.0 hive有哪些方式保存元数据，各有哪些优点
              三种：自带内嵌数据库derby，挺小，不常用，只能用于单节点
mysql常用
上网上找了下专业名称：single user mode..multiuser mode...remote user mode
 
9.0 请简述hadoop怎样实现二级排序（就是对key和value双排序）
    第一种方法是，Reducer将给定key的所有值都缓存起来，然后对它们再做一个Reducer内排序。但是，由于Reducer需要保存给定key的所有值，可能会导致出现内存耗尽的错误。
第二种方法是，将值的一部分或整个值加入原始key，生成一个组合key。这两种方法各有优势，第一种方法编写简单，但并发度小，数据量大的情况下速度慢(有内存耗尽的危险)，
第二种方法则是将排序的任务交给MapReduce框架shuffle，更符合Hadoop/Reduce的设计思想。这篇文章里选择的是第二种。我们将编写一个Partitioner，确保拥有相同key(原始key，不包括添加的部分)的所有数据被发往同一个Reducer，还将编写一个Comparator，以便数据到达Reducer后即按原始key分组。
 
10.简述hadoop实现jion的几种方法
Map side join----大小表join的场景，可以借助distributed cache
Reduce side join
 
11.0 请用java实现非递归二分查询
1.  public class BinarySearchClass  
2.  {  
3.    
4.      public static int binary_search(int[] array, int value)  
5.      {  
6.          int beginIndex = 0;// 低位下标  
7.          int endIndex = array.length - 1;// 高位下标  
8.          int midIndex = -1;  
9.          while (beginIndex <= endIndex) {  
10.              midIndex = beginIndex + (endIndex - beginIndex) / 2;//防止溢出  
11.              if (value == array[midIndex]) {  
12.                  return midIndex;  
13.              } else if (value < array[midIndex]) {  
14.                  endIndex = midIndex - 1;  
15.              } else {  
16.                  beginIndex = midIndex + 1;  
17.              }  
18.          }  
19.          return -1;  
20.          //找到了，返回找到的数值的下标，没找到，返回-1         
21.      }  
22.    
23.    
24.      //start 提示：自动阅卷起始唯一标识，请勿删除或增加。  
25.      public static void main(String[] args)  
26.      {  
27.          System.out.println("Start...");  
28.          int[] myArray = new int[] { 1, 2, 3, 5, 6, 7, 8, 9 };  
29.          System.out.println("查找数字8的下标：");  
30.          System.out.println(binary_search(myArray, 8));          
31.      }  
32.      //end //提示：自动阅卷结束唯一标识，请勿删除或增加。  
33.  }     
 
12.0 请简述mapreduce中的combine和partition的作用
答：combiner是发生在map的最后一个阶段，其原理也是一个小型的reducer，主要作用是减少输出到reduce的数据量，缓解网络传输瓶颈，提高reducer的执行效率。
partition的主要作用将map阶段产生的所有kv对分配给不同的reducer task处理，可以将reduce阶段的处理负载进行分摊
 
13.0 hive内部表和外部表的区别
Hive 向内部表导入数据时，会将数据移动到数据仓库指向的路径；若是外部表，数据的具体存放目录由用户建表时指定
在删除表的时候，内部表的元数据和数据会被一起删除， 
而外部表只删除元数据，不删除数据。
这样外部表相对来说更加安全些，数据组织也更加灵活，方便共享源数据。 
 
14. Hbase的rowKey怎么创建比较好？列簇怎么创建比较好？
答：
rowKey最好要创建有规则的rowKey，即最好是有序的。
经常需要批量读取的数据应该让他们的rowkey连续；
将经常需要作为条件查询的关键词组织到rowkey中；
 
列族的创建：
按照业务特点，把数据归类，不同类别的放在不同列族
 
15. 用mapreduce怎么处理数据倾斜问题
本质：让各分区的数据分布均匀
可以根据业务特点，设置合适的partition策略
如果事先根本不知道数据的分布规律，利用随机抽样器抽样后生成partition策略再处理
  
16. hadoop框架怎么来优化
答：
可以从很多方面来进行：比如hdfs怎么优化，mapreduce程序怎么优化，yarn的job调度怎么优化，hbase优化，hive优化。。。。。。。
 
17. hbase内部机制是什么
答：
Hbase是一个能适应联机业务的数据库系统
物理存储：hbase的持久化数据是存放在hdfs上
存储管理：一个表是划分为很多region的，这些region分布式地存放在很多regionserver上
Region内部还可以划分为store，store内部有memstore和storefile
版本管理：hbase中的数据更新本质上是不断追加新的版本，通过compact操作来做版本间的文件合并
Region的split
集群管理：zookeeper  + hmaster（职责）  + hregionserver（职责）
 
18. 我们在开发分布式计算job的时候，是否可以去掉reduce阶段
答：可以，例如我们的集群就是为了存储文件而设计的，不涉及到数据的计算，就可以将mapReduce都省掉。
比如，流量运营项目中的行为轨迹增强功能部分
怎么样才能实现去掉reduce阶段
去掉之后就不排序了，不进行shuffle操作了
 
19 hadoop中常用的数据压缩算法
答：
Lzo
Gzip
Default
Snapyy
如果要对数据进行压缩，最好是将原始数据转为SequenceFile  或者 Parquet File（spark）
 
20. mapreduce的调度模式（题意模糊，可以理解为yarn的调度模式，也可以理解为mr的内部工作流程）
答： appmaster作为调度主管，管理maptask和reducetask
Appmaster负责启动、监控maptask和reducetask
Maptask处理完成之后，appmaster会监控到，然后将其输出结果通知给reducetask，然后reducetask从map端拉取文件，然后处理；
当reduce阶段全部完成之后，appmaster还要向resourcemanager注销自己
 
21. hive底层与数据库交互原理
答：
Hive的查询功能是由hdfs + mapreduce结合起来实现的
Hive与mysql的关系：只是借用mysql来存储hive中的表的元数据信息，称为metastore
  
22. hbase过滤器实现原则
答：可以说一下过滤器的父类（比较过滤器，专用过滤器）
过滤器有什么用途：
增强hbase查询数据的功能
减少服务端返回给客户端的数据量
 
23. reduce之后数据的输出量有多大（结合具体场景，比如pi）
Sca阶段的增强日志（1.5T---2T）
过滤性质的mr程序，输出比输入少
解析性质的mr程序，输出比输入多（找共同朋友）
 
24.datanode在什么情况下不会备份数据
答：在客户端上传文件时指定文件副本数量为1
 
25.combine出现在哪个过程
答：shuffle过程中
具体来说，是在maptask输出的数据从内存溢出到磁盘，可能会调多次
Combiner使用时候要特别谨慎，不能影响最后的逻辑结果
 
26. hdfs的体系结构
答：
集群架构： 
namenode  datanode  secondarynamenode
 (active namenode ,standby namenode)journalnode  zkfc

内部工作机制：
数据是分布式存储的
对外提供一个统一的目录结构
对外提供一个具体的响应者（namenode）
数据的block机制，副本机制
Namenode和datanode的工作职责和机制
读写数据流程
 
27. flush的过程
答：flush是在内存的基础上进行的，首先写入文件的时候，会先将文件写到内存中，当内存写满的时候，一次性的将文件全部都写到硬盘中去保存，并清空缓存中的文件，
 
28. 什么是队列
答：是一种调度策略，机制是先进先出
 
29. List与set的区别
答：List和Set都是接口。他们各自有自己的实现类，有无顺序的实现类，也有有顺序的实现类。
最大的不同就是List是可以重复的。而Set是不能重复的。
List适合经常追加数据，插入，删除数据。但随即取数效率比较低。
Set适合经常地随即储存，插入，删除。但是在遍历时效率比较低。
 
30.数据的三范式
答：
第一范式（）无重复的列
第二范式（2NF）属性完全依赖于主键  [消除部分子函数依赖]
第三范式（3NF）属性不依赖于其它非主属性  [消除传递依赖]