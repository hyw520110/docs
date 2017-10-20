MongoDB Sharding架构下高连接数一直困扰着我们。因此下定决心寻求解决之道。

何时出现高连接数

我们遇到的场景，当连接到mongos的应用服务器（如Tomcat实例数量）过百，甚至达到近200台时，tcp连接数超高，达到15000以上，查看mongod对应端口连接数高达8000多，mongos 2000多。此时ops（query,insert,update,delete）低于200每秒,。定期重启（如一周一次）mongos可适当缓解该问题。

原因分析

我们在排除了应用程序连接池相关配置参数设置问题后，将源头指向了MongoDB的连接池实现细节。
在src/client/connpool.cpp中，有如下代码：

    bool PoolForHost::StoredConnection::ok( time_t now ) {
            // if connection has been idle for 30 minutes, kill it
            return ( now - when ) < 1800;
        }

    void PoolForHost::getStaleConnections( vector<DBClientBase*>& stale ) {
            time_t now = time(0);

            vector<StoredConnection> all;
            while ( ! _pool.empty() ) {
                StoredConnection c = _pool.top();
                _pool.pop();

                if ( c.ok( now ) )
                    all.push_back( c );
                else
                    stale.push_back( c.conn );
            }

            for ( size_t i=0; i<all.size(); i++ ) {
                _pool.push( all[i] );
            }
        }

初步来看，当连接空闲时间超过1800秒即30分钟才会释放连接。于是我们想调低该值会不会解决问题？

如何解决

发现不是就我们遇到该问题，github上已经有了个pull request。

	https://github.com/mongodb/mongo/pull/278
通过添加“maxSpareConnPools" "connPoolTimeout”两个参数来对连接池更细粒度的控制。

	https://github.com/mongodb/mongo/pull/359
"maxSpareConnPools" option was abolished.

"connPoolMaxPerHost" is available instead

相关bug：
	https://jira.mongodb.org/browse/SERVER-6726
	https://jira.mongodb.org/browse/SERVER-9022
官方对该解决方案目前没有接受，官方目前的解决方案是添加了一个参数（2.2.4版本以上），该参数为隐藏参数releaseConnectionsAfterResponse ，版本2.2.4, 2.4.2, 2.5.0 。

	mongos> use admin
	switched to db admin
	mongos> db.runCommand({ setParameter : 1, releaseConnectionsAfterResponse : true }) 

	mongos> { "was" : false, "ok" : 1 }

或者

	shell> mongos --setParameter "releaseConnectionsAfterResponse=true" --configdb ... 

该参数注意事项：

写操作需要立即调用getLastError （w=1，即安全写模式）,w=2（等待从库写确认）的时候可能会有些错误。

升级过后，或者重启mongos进程后，需要重新设置该参数，该参数只对单个mongos生效。

代码：
	https://github.com/mongodb/mongo/commit/706459a8af0b278609d70e7122595243df6aeee8
	https://github.com/mongodb/mongo/commit/74323d671a216c8c87fcb295ed743f830d5212ee
	https://github.com/mongodb/mongo/commit/5d5fe49dfb5f452832b9d44fddbfb2a4e8b42f2a

方案

这两个方案需要进一步验证，检验是否能解决高连接数问题。
启用releaseConnectionsAfterResponse 参数，tcp 连接数明显降低到比较稳定数目。几个小时，tcp连接数从8000多降到4000多，效果不错。

releaseConnectionsAfterResponse 参数原理

通常，对于每个mongos->mongod连接是单独缓存的，并且该连接不能重复使用，即使该连接是空闲时也是如此，一直到连接关闭连接回到连接池中才能再使用；releaseConnectionsAfterResponse 参数启用后，mongos->mongod之间的连接在完成一个读操作或者安全写操作后能够重复使用（把连接放到连接池中而不是缓存，即更早的回归到连接池中），releaseConnectionsAfterResponse参数简单讲就是mongos->mongod的连接更早的回到连接池中，这样就不会开太多的连接了，从而减少连接数。
Create a new serverParameter for mongos, "releaseConnectionsAfterResponse," which enables returning ShardConnections from the per-socket pool to the global pool after each read operation. This should reduce the total number of outgoing mongos connections to each shard.
the option allows better use of the connection pool, it doesn't invalidate the connections in the pool. Normally, mongos->mongod connections for insert/update/delete/query are cached individually for each incoming connection, and can't be re-used until the incoming connection is closed, even if they are idle and there are other active incoming connections.
What the releaseConnectionsAfterResponse option does is allow the mongos->mongod connection to be re-used (returned to the pool) after any read op (including getLastError(), so after safe writes as well). It shouldn't have a significant performance impact - the connection isn't destroyed, it's just returned from the incoming connection cache to the shared pool early.


connPoolTimeout设置

（该参数不在官方没有）
效果

	mongos> db.runCommand({ setParameter : 1, connPoolTimeout : 900 }) { "was" : 1800, "ok" : 1 }



这是同事总结的一篇文章，参见：

	http://nosql-db.com/topic/518510c8735345ad0a04fef8

请关注http://nosql-db.com