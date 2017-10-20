

最近根据Mongodb使用中出现的一些问题，对Mongodb的源码进行了一些简单的修改，记录如下：
高连接数解决方案：mongodb连接池优化

优化连接池使用效率,更细粒度的调整连接数设置，降低分片集群和复制集的连接数。

1.mongos,mongod启动参数添加connPoolTimeout参数，设置连接数超时时间。

2.添加connPoolTimeout 命令，设置超时时间 db.runCommand({ setParameter : 1, connPoolTimeout : 900 })

3.mongos,mongod启动参数添加connPoolMaxPerHost 参数，设置每个Host最大连接池大小。

4.默认启用releaseConnectionsAfterResponse 参数，降低分片集群情况下连接数。

mongod 功能增强

5.mongod 添加syncFrom参数（官方一直没解决，[SERVER-7680](https://jira.mongodb.org/browse/SERVER-7680) Allow replsetsyncfrom to restart initial sync），

用于初始化同步指定syncTarget(从哪个复制集成员同步),给复制集添加成员或者3台以上的复制集重新初始化同步时避免对主库造成压力。

6.默认启用usePowerOf2Sizes，减少碎片和优化磁盘使用效率（[SERVER-9331](https://jira.mongodb.org/browse/SERVER-9331)）

MongoDB工具系列功能增强

7.mongoexport导出csv增加3个参数，方便导数据。

fields-terminated-by,字段分隔符

lines-terminated-by ,换行符

noheaders,不输出字段名称

发现并修复mongoexport log输出一个小bug（[SERVER-10204](https://jira.mongodb.org/browse/SERVER-10204)）
