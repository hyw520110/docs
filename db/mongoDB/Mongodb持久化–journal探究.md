http://www.lirongzhen.cn/?p=1116

Mongodb在1.8版本之后开始支持journal，就是我们常说的redo log，用于故障恢复和持久化。

一、启动

启动journal功能使用mongod --journal选项，也可以关闭--nojournal，在2.0之后的版本，journal都是默认打开的，以确保数据安全。在version < 2.0 或者32位的系统上都是默认关闭的 。因为打开journal会使用更多的内存（下面会详细介绍），而32位系统支持的内存太小，所以关闭了。
由于Mongodb会事先初始化journal空间，而且在初始化完成之前是不会打开监听端口的，所以启动后可能会有一段时间连不上，不用紧张，查看日志，待journal初始化完成之后再连接。这里也建议，尽量使用ext4或者xfs等文件系统，诸如ext3这样的文件系统，初始化磁盘会非常慢，你会看到启动mongod之后，很长一段时间都停留在打印日志的状态，而用ext4会瞬间完成。而且Mongodb在运行时对db的空间也采用预分配的机制，所以使用更高级的文件系统是很有帮助的，防止磁盘引起的高并发下拥堵问题。

二、文件、恢复和备份

journal存放在数据文件的/journal/文件夹下，运行时的文件一般是这样的

15795819_135090443129yb

其中j.32,j.33是使用中的journal文件，当单个文件达到1GB的时候，就会创建一个新的文件，旧文件不会循环使用，自动删除。lsn保存最后使用的journal序列号，是个2进制文件，跟mysql-bin.index作用差不多。prealloc.2是还未使用的初始化的journal文件。使用db.shutdownServer()和kill -2关闭的系统，也就是clean shutdown，journal文件夹下除prealloc.*文件 都会被删除。       如果系统掉电或者运行时死机，再启动时，mongo就会使用journal进行恢复，不用运行repair。
我们可以将journal，oplog，data做快照备份，在数据丢失的时候，可以恢复到最近的状态，保证安全。盛大的云计算系统就是这样做的，同时使用go语言做异步备份，有机会可以跟他们交流。

三、批量提交

journal除了故障恢复的作用之外，还可以提高写入的性能，批量提交（batch-commit），journal一般默认100ms刷新一次，在这个过程中，所有的写入都可以一次提交，是单事务的，全部成功或者全部失败。关于刷新时间，它是可以更改，上一篇博客有介绍，范围是2-300ms，但是这并不是绝对的。mongodb提供了journal延迟测试的函数，

db.runCommand("journalLatencyTest")：

15795819_1350904432Zftx

在实际运行中，刷新时间是--journalCommitInterval设置和延迟测试中较大的一个。         不得不吐槽一下，有的服务器磁盘有cache却没有电池，情何以堪，在不走cache的情况下，延迟相当大，图中就是不走cache的情况。mongo也是支持ssd的，有条件可以使用。在比较繁忙的系统上，当journal和data放在一个volume上的时候，这个值也会比较大。
查看journal运行情况
db.serverStatus():

15795819_1350904432p0mi

commits:在journalCommitInterval时间内提交的操作数。
journaledMB：在journalCommitInterval时间内写到journal文件中的数据量 。
writeToDataFilesMB：在journalCommitInterval时间内从journal刷新到磁盘的数据量 。
compression：v>2.0，表示客户端提交写入到journal的数据的压缩比率，注意，写入到journal的数据并不是全部的数据。( journaled_size_of_data / uncompressed_size_of_data ) 。
commitsInWriteLock:在有写锁的情况下提交的数量，这表示写的压力很大。
earlyCommits：表示在journalCommitInterval之前的时间，mongod请求提交的次数。用这个参数确定journalCommitInterval是不是设置的过长。
dur.timeMS.prepLogBuffer：写journal的准备时间，时间越短，说明journal的性能越好 。 dur.timeMS.writeToJournal：真正的写入到journal的时间，比较抽象，因为写入到journal要经历很多步骤，之后会讲解。
dur.timeMS.writeToDataFiles：刷新journal到磁盘的时间，文件系统和磁盘会影响写入性能。
dur.timeMS.remapPrivateView：重新映射数据到PrivateView的时间，数据越小，性能越好。这个之后会介绍，这也是为什么journal会使用更多内存的原因，因为journal会另外使用一个叫PrivateView的内存区域。

总结：

mongodb在使用journal之后，备份，容灾得到保障，批量提交也使得写入更加快速（不持久化的不算）。我们也需要选用较高级的文件系统和磁盘还有更多的内存来保障journal的良好运行。下一篇博客会着重介绍journal的数据结构和工作原理。

 

参考：

    http://docs.mongodb.org/manual/reference/server-status/#dur
    http://www.mongodb.org/display/DOCS/Journaling
    http://www.mongodb.org/display/DOCS/Journaling+Administration+Notes

