Mongodb在1.8版本之后开始支持journal，就是我们常说的redo log，用于故障恢复和持久化。

一、启动

启动journal功能使用mongod --journal选项，也可以关闭--nojournal，在2.0之后的版本，journal都是默认打开的，以确保数据安全。在version < 2.0 或者32位的系统上都是默认关闭的 。因为打开journal会使用更多的内存（下面会详细介绍），而32位系统支持的内存太小，所以关闭了。
由于Mongodb会事先初始化journal空间，而且在初始化完成之前是不会打开监听端口的，所以启动后可能会有一段时间连不上，不用紧张，查看日志，待journal初始化完成之后再连接。这里也建议，尽量使用ext4或者xfs等文件系统，诸如ext3这样的文件系统，初始化磁盘会非常慢，你会看到启动mongod之后，很长一段时间都停留在打印日志的状态，而用ext4会瞬间完成。而且Mongodb在运行时对db的空间也采用预分配的机制，所以使用更高级的文件系统是很有帮助的，防止磁盘引起的高并发下拥堵问题。

二、文件、恢复和备份

journal存放在数据文件的/journal/文件夹下，运行时的文件一般是类似这样的几个文件

	j._32、j._33..、lsn、prealloc.2
其中j.32,j.33是使用中的journal文件，当单个文件达到1GB的时候，就会创建一个新的文件，旧文件不会循环使用，自动删除。lsn保存最后使用的journal序列号，是个2进制文件,它实际保存的是系统启动到现在的一个时间戳。prealloc.2是还未使用的初始化的journal文件。使用db.shutdownServer()和kill -2关闭的系统，也就是clean shutdown，journal文件夹下除prealloc.*文件 都会被删除。

如果系统掉电或者运行时死机，再启动时，mongo就会使用journal进行恢复，不用运行repair。

我们可以将journal，oplog，data做快照备份，在数据丢失的时候，可以恢复到最近的状态，保证安全。盛大的云计算系统就是这样做的，同时使用go语言做异步备份。 

三、批量提交

journal除了故障恢复的作用之外，还可以提高写入的性能，批量提交（batch-commit），journal一般默认100ms刷新一次，在这个过程中，所有的写入都可以一次提交，是单事务的，全部成功或者全部失败。关于刷新时间，它是可以更改，范围是2-300ms，但是这并不是绝对的。mongodb提供了journal延迟测试的函数测试刷新journal到磁盘的时间，db.runCommand("journalLatencyTest")

在实际运行中，刷新时间是--journalCommitInterval设置和延迟测试中较大的一个。
 
不得不吐槽一下，有的服务器磁盘有cache却没有电池，情何以堪，在不走cache的情况下，延迟相当大。mongo也是支持ssd的，有条件可以使用。在比较繁忙的系统上，当journal和data放在一个volume上的时候，这个值也会比较大。

查看journal运行情况(journal的性能情况)

	db.serverStatus()
	关注dur节点：
		commits:在journalCommitInterval时间内提交的操作数。
		journaledMB：在journalCommitInterval时间内写到journal文件中的数据量 。
		writeToDataFilesMB：在journalCommitInterval时间内从journal刷新到磁盘的数据量 。
		compression：v>2.0，表示客户端提交写入到journal的数据的压缩比率，注意，写入到journal的数据并不是全部的数据。( journaled_size_of_data / uncompressed_size_of_data ) 。
		commitsInWriteLock:在有写锁的情况下提交的数量，这表示写的压力很大。
		earlyCommits：表示在journalCommitInterval之前的时间，mongod请求提交的次数。用这个参数确定journalCommitInterval是不是设置的过长。
		dur.timeMS.prepLogBuffer：从privateView映射到Logbuffer的时间。
		dur.timeMS.writeToJournal：从logbuffer刷新到journalfile 的时间。
		dur.timeMS.writeToDataFiles：从journalbuffer映射到MMF，然后从MMF刷新到磁盘的时间，文件系统和磁盘会影响写入性能。
		dur.timeMS.remapPrivateView：重新映射数据到PrivateView的时间，越小性能越好。这个之后会介绍，这也是为什么journal会使用更多内存的原因，因为journal会另外使用一个叫PrivateView的内存区域。 

mongodb在使用journal之后，备份，容灾得到保障，批量提交也使得写入更加快速。我们也需要选用较高级的文件系统和磁盘还有更多的内存来保障journal的良好运行

当系统启动时，mongodb会将数据文件映射到一块内存区域，称之为Shared view，在不开启journal的系统中，数据直接写入shared view，然后返回，系统每60s刷新这块内存到磁盘，这样，如果断电或down机，就会丢失很多内存中未持久化的数据。当系统开启了journal功能，系统会再映射一块内存区域供journal使用，称之为private view，mongodb默认每100ms刷新privateView到journal，也就是说，断电或宕机，有可能丢失这100ms数据，一般都是可以忍受的，如果不能忍受，那就用程序写log吧。这也是为什么开启journal后mongod使用的虚拟内存是之前的两倍。Mongodb的隔离级别是read_uncommitted，不管使用不使用journal，都是以内存中的数据为准，只不过，不开启journal，数据从shared view读取，开启journal，数据从private view读取。

在开启journal的系统中，写操作从请求到写入磁盘共经历5个步骤，在serverStatus()中已经列出各个步骤消耗的时间

	①、Write to privateView
	②、prepLogBuffer
	③、WritetoJournal
	④、WritetoDataFile
	⑤、RemaptoPrivateView

下面详细介绍每个步骤的过程：
	
![image](http://blog.chinaunix.net/attachment/201211/23/15795819_13536557498aw3.jpg)	

1、preplogbuffer：

Private view(PV) 中的数据并不是直接刷新到journal文件，而是通过一个中间内存块（journalbuffer，或者alogned buffer）一部分一部分的刷新到journal，这样可以提高并发。preplogbuffer即是将PV中的数据写入到aligned buffer中的过程。这个过程有两部分，basic write 操作和非 basic write操作（e.g.create file）。一次preplogbuffer是以一个commitJob为一个单位，可能会有很多个commitJob写入到aligned buffer，然后提交。一个commitJob中包含多个basic write 和非basic write 操作，basic write是存在Writeintent结构体中的，Writeintent记录了写操作的地址信息。非basic write 操作存在一个vector中。

具体结构如下:

![image](http://blog.chinaunix.net/attachment/201211/23/15795819_1353655749NaD2.jpg)

Aligned buffer 有自己的结构，这也是写入到journalfile中的结构。包含Jheader，JsectHeader lsn，Durop，JSectFooter：

![image](http://blog.chinaunix.net/attachment/201211/23/15795819_1353655749yuIG.jpg)

每个JsectHeader之间的Durop是属于一个事务范围，一起提交，一起成功，一起失败，即all-or-nothing.上篇文章中介绍的lsn文件，就是记录这个lsn号。

2、WritetoJournal：

writetoJournal操作是将alignedbuffer刷新到JournalFile的过程。默认100ms刷新一次，由--journalCommitInterval 参数控制。writetoJournal会做一些checksum验证，将alignedbuffer进行压缩，然后将压缩过后的alignedbuffer写入到磁盘。写入磁盘后将删除已经满的Journal文件，更新lsn号到lsn文件。写操作到这一步就是安全的了，因为数据已经在磁盘上，如果使用getlasterror（j=true），这一步即可返回。

3、WritetoDataFile：

WritetoDataFile是将未压缩的aligned buffer写入到shared view的过程，然后由操作系统刷新到磁盘文件中。WritetoDataFile首先会对aligned buffer进行严格的验证，确保没有改变过，然后解析aligned buffer，通过memcpy函数拷贝到shareview

4、RemaptoprivateView：

RemaptoprivateView会将持久化的数据重新映射到PV，以减小PV的大小，防止它不断扩大，按照源码上说，RemaptoprivateView会两秒钟重新映射一次，大约有1000个view，不是一次全做完，而是一部分一部分的做。由于读操作是读取PV，所以在映射完成之后会有短暂的时间读取磁盘。

经过这四步，一个写操作就完成了，journal提高了数据的安全性，并不像想象中的会丢数据，重要的是如何使用和维护。

以上均参考自mongo官方文档和源码,k参考：

    1、journalFormat
    2、Dur process steps
    3、http://www.mongodb.org/display/DOCS/Durability+Internals
    4、源码/src/mongo/db/dur.*