#Leader选举

ZooKeeper 需要在所有的服务（可以理解为服务器）中选举出一个 Leader ，然后让这个 Leader 来负责管理集群。此时，集群中的其它服务器则成为此 Leader 的 Follower 。并且，当 Leader 故障的时候，需要 ZooKeeper 能够快速地在 Follower 中选举出下一个 Leader 。这就是 ZooKeeper 的 Leader 机制，下面我们将简单介绍在 ZooKeeper 中， Leader 选举（ Leader Election ）是如何实现的。

此操作实现的核心思想是：首先创建一个 EPHEMERAL 目录节点，例如“ /election ”。然后。每一个 ZooKeeper 服务器在此目录下创建一个 SEQUENCE| EPHEMERAL 类型的节点，例如“ /election/n_ ”。在 SEQUENCE 标志下， ZooKeeper 将自动地为每一个 ZooKeeper 服务器分配一个比前一个分配的序号要大的序号。此时创建节点的 ZooKeeper 服务器中拥有最小序号编号的服务器将成为 Leader 。

在实际的操作中，还需要保障：当 Leader 服务器发生故障的时候，系统能够快速地选出下一个 ZooKeeper 服务器作为 Leader 。一个简单的解决方案是，让所有的 follower 监视 leader 所对应的节点。当 Leader 发生故障时， Leader 所对应的临时节点将会自动地被删除，此操作将会触发所有监视 Leader 的服务器的 watch 。这样这些服务器将会收到 Leader 故障的消息，并进而进行下一次的 Leader 选举操作。但是，这种操作将会导致“从众效应”的发生，尤其当集群中服务器众多并且带宽延迟比较大的时候，此种情况更为明显。

在 Zookeeper 中，为了避免从众效应的发生，它是这样来实现的：每一个 follower 对 follower 集群中对应的比自己节点序号小一号的节点（也就是所有序号比自己小的节点中的序号最大的节点）设置一个 watch 。只有当 follower 所设置的 watch 被触发的时候，它才进行 Leader 选举操作，一般情况下它将成为集群中的下一个 Leader 。很明显，此 Leader 选举操作的速度是很快的。因为，每一次 Leader 选举几乎只涉及单个 follower 的操作。

#选举算法
zookeeper集群中选举出一个leader使用了三种算法,具体使用哪种算法,在配置文件中是可以配置的,对应的配置项是”electionAlg”,其中1对应的是LeaderElection算法,2对应的是AuthFastLeaderElection算法,3对应的是FastLeaderElection算法.默认使用FastLeaderElection算法
 
无论使用哪种Leader选举方法，一个机器要想成为Leader，都必须具备以下两点：
- Leader一定是所有机器中zxid最新的。
- 集群中必须大于等于quorum台机器同意。

当一个Leader被选出后，那么其余的机器都会和这个机器来连接上，并开始同步状态。如果一个Follower落后的状态过多的话，那么就会将整个snapshot同步给他。

新的Leader会根据当前最大的zxid来确定下次开始的zxid。当所有的Follower已经和Leader保持同步之后，Leader会向所有的Follower发出“NEW_LEADER”的提议，一旦过半的机器接受了这个提议，
也就是说这个提议能够被提交，接下去Leader才被真正激活，并开始对外服务：开始接收新的请求并处理。

这个算法听起来有点复杂，但实际上，只要遵守一下5点就可以选出Leader

- Follower在和Leader保持同步之后，就会对“NEW_LEADER”提议响应ACK。
- A follower will only ACK a NEW_LEADER proposal with a given zxid from a single server.
- 一旦集群中已经有过半的机器响应了ACK, 那么Leader就会提交“NEW_LEADER”提议
- 一旦“NEW_LEADER”已经被提交，也就是说，Leader选举完毕，Leader确定后，之后Follower就会提交所有来自Leader的状态变更。
- 在“NEW_LEADER”提议被提交之前，也就是说在完成Leader选举之前，Leader将不再接收任何来自客户端的任何请求。

基于以上的5个规则，即使在Leader选举的时候出现问题，也不会有事。因为只要“NEW_LEADER”提议没有被过半的机器接受，那么就不会提交。因此，在这种情况下，剩下的所有机器会开始新一轮的Leader选举。