Mongodb replica set的主要作用就是保障整个系统的高可用.当primary down掉的时候,secondary可以迎难而上,但是,整个replica set每个参数非常详细的作用,以及primary down机后会发生什么事,这个在mongo的主页上讲的不是特别详细,我以前没有找到相关的资料.今天抽空看找了下相关资料,终于找到这篇文章,也不知道啥时候冒出来的.


总结一下:

在replica set里,有四种结点(官方的说法是三种,把secondary,primary认为是同一种Standard node):


1.Primary. 负责client的读写.
    
2.Secondary.热备.从Primary的oplog读取操作日志,以便与Primary保持一致.
    
其实secondary有两种类型: 

a) normal secondary 随时和Primay保持同步, 

b) delayed secondary, 延时指定时间和primary保持同步,防止误操作. 话说delayed secondary 其实在实际中作用真的不是很大,一般情况都不太愿意浪费机器去做这个事,延时的时间也不好定,定短了,来不及反应,定长了嘛,要注意primary的oplog size要保证在这个延时的时间段内可以保存所有的操作日志.事实上用incremental back up 也可以很好的解决误操作的问题,但是怎么incremental back up其实也不是个简单的事.本质上和使用delayed secondary + replay oplog from primary上区别不大,只是incremental back 会比delayed secondary更加灵活
    
3.Arbiter.玩过星际看过星际迷航的人都知道.它不负责任何读写,只负责primary down的时候的选举.这个其实也是我原来比较迷惑的地方,以前一直不明白为啥要加入这个角色.它当然不可能成为primary. Arbiter因为不负责读写,所以在启动这个节点的时候,请把OPLOG的size设小点,比如说8M,节省不是那么贵的硬盘空间吧..因为mongod启动的时候默认会分配系统空闲硬盘空间的5%做为oplog的存储空间
    
4.Passive Node.除了没有被选举权(和中国屁民一样,没机会成为Primary),其它同secondary.

 

在开始讲怎么选举Primary之前,有个概念需要介绍一下:OpOrdinal.    opordinal 其实就是记录某个操作时候的time stamp. maxLocalOpOrdinal()就是最后一条操作的time stamp. 在mongodb中,为了节省单条log的大小,log的time stamp是由两部分组成,  如果你打开  http://XXX.XXX.XXX.XXX:28017/_replSetOplog?2 ,你会发现在optime这列有类似 4d72baa3:16的东西.OK,具体不解释了.

 

当primary down的时候,官方的说法是.


We use a consensus protocol to pick a primary. Exact details will be spared here but that basic process is:


1.get maxLocalOpOrdinal from each server.  //获取每个node的maxLocalOpOrdinal
    
2.if a majority of servers are not up (from this server's POV), remain in Secondary mode and stop.
    这条需要注意,如果一个replica set中有超过一半,包括一半的节点完完了,那么整个set也完完了.所以replica set千万不要只有两个节点,如果真是机器紧张,好歹也加个arbiter. 
    
3.if the last op time seems very old, stop and await human intervention.
    一般情况下不会出secondary离primary很远情况.所以delayed secondary 是基本上没有机会成为primary 
    
4.else, using a consensus protocol, pick the server with the highest maxLocalOpOrdinal as the Primary. 
    好吧,如果只有一台机器的maxLocalOpOrdinal是最大小的,它就会成为primary.不然就进入

consensus protocol


query all others for their maxappliedoptime
    
try to elect self if we have the highest time and can see a majority of nodes
        
if a tie on highest time, delay a short random amount first
        
elect (selfid,maxoptime) msg -> others
    
if we get a msg and our time is higher, we send back NO
    
we must get back a majority of YES
    
if a YES is sent, we respond NO to all others for 1 minute. Electing ourself counts as a YES.
    
repeat as necessary after a random sleep


这里就不多解释了.说个个典型的案例.

1. 一个replica set. 三台机器, primary down了.两台sceondary的maxLocalOpOrdinal一样,完了,整个replica set可能就死了.当replica set不是特别繁忙的时候,secondary是可能都和primary保持一致的.

所以加入arbiter的作用是,它总是会发YES出去,有助于快速选出primary.  注意if a YES is sent, we respond NO to all others for 1 minute. Electing ourself counts as a YES.  如果几分钟才能选出primary是比较恐怖的事..

PS：在google.group上提问了下如何解决选举冲突的问题，这是开发者给出的回答：

    A node won't nominate itself if
    there is already another node that nominated itself. If by chance
    timing two nodes nominate themselves simultaneously and neither of
    them get the majority required they will relinquish nomination and
    that will trigger another election round. There is code to assure
    that they don't both immediately re-nominate themselves.


 

说到这儿, 官方其实还漏了两个事没有说. 如果你仔细读过replica set的配置参数,你会发现, votes, priority这两个参数在整个过程中的重要没有讲清楚.

 

以下内容纯属猜测

1.votes要慎用.它的意思是一台机器可以有多个投票权.比如说,一开始三台机votes的值分别为1, 2, 4,不意外4应该成为primary,但是4 down后,1,2都不会成为primary, 因1+2 <= (1+2+4)/2. 也就是说votes为4的机器不是一个人在战斗,它是4个人在战斗.

2.priority在secondary机器有好坏的时候可以考虑设置.priority有助于打破tie

 

 

最后再说两点.

1.primary down机后,可能会丢最新数据,这取决于secondary的同步情况

2.primary down机后,整个系统会在短暂的时间内不可用.这时间取决于新primary产生的速度,所以理解整个elect过程有助于配置replica set,缩短down机时间.


转载自：http://blog.csdn.net/guolijing/article/details/6234320
哈，现在也是同事了,虽然木有见过面儿.... 