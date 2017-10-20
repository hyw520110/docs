# 优势

- 在创建节点的时候就已经把关系给建立起来，避免了在复杂查询场景下的处理
- 由于底层直接以图的形式存储节点和关系，在查询的时候可以使时间复杂度保持在常数级别。
- 基于JVM实现
- 提供一套易于理解的查询语言Cypher以及内置的可视化UI
- 很好的支持ACID，有事务机制

# 场景

- 社交网络
- 基于图的搜索
- 推荐引擎
- 企业基础设施及网络架构
- 等等等 

# 安装

neo4j支持嵌入式和独立部署的两种模式，独立部署前提安装jdk



# 配置

配置文档存储在conf目录下，Neo4j通过配置文件neo4j.conf控制服务器的工作，默认情况下，不需要进行任意配置，就可以启动服务器

核心数据文件存储的位置，默认是在data/graph.db目录中，要改变默认的存储目录，可以更新配置选项：
	

	#dbms.active_database=graph.db
	#dbms.directories.data=data

安全验证，默认是启用的	
	
	#dbms.security.auth_enabled=false
配置JAVA 堆内存的大小	
	
	#dbms.memory.heap.initial_size=512m
	#dbms.memory.heap.max_size=512m

## 网络连接配置

Neo4j支持三种网络协议（Protocol）

Neo4j支持三种网络协议（Protocol），分别是Bolt 7687，HTTP 7474和HTTPS7473 

## 设置默认的监听地址

Neo4j只允许本地主机（localhost）访问，要想通过网络远程访问Neo4j数据库，需要修改监听地址为 0.0.0.0，这样设置之后，就能允许远程主机的访问

	dbms.connectors.default_listen_address=0.0.0.0

分别设置各个网络协议的监听地址和端口

HTTP链接器默认的端口号是7474，Bolt链接器默认的端口号是7687，必须在Windows 防火墙中允许远程主机访问这些端口号。
	 
	# Bolt connector
	dbms.connector.bolt.enabled=true
	#dbms.connector.bolt.tls_level=OPTIONAL
	#dbms.connector.bolt.listen_address=0.0.0.0:7687
	
	# HTTP Connector. There must be exactly one HTTP connector.
	dbms.connector.http.enabled=true
	#dbms.connector.http.listen_address=0.0.0.0:7474
	
	# HTTPS Connector. There can be zero or one HTTPS connectors.
	#dbms.connector.https.enabled=true
	#dbms.connector.https.listen_address=0.0.0.0:7473
# 启动Neo4j 

通过控制台启动Neo4j程序(管理员身份)

	neo4j.bat console

安装和卸载服务：
	
	bin\neo4j install-service
	bin\neo4j uninstall-service
启动服务，停止服务，重启服务和查询服务的状态：
	
	bin\neo4j start
	bin\neo4j stop
	bin\neo4j restart
	bin\neo4j status

启动后访问http://localhost:7474

默认的host是bolt://localhost:7687，默认的用户是neo4j，其默认的密码是：neo4j，第一次成功登陆到Neo4j服务器之后，需要重置密码。

访问Graph Database需要输入身份验证，Host是Bolt协议标识的主机。

在Neo4j浏览器中创建节点和关系

恩比德

- 身份球员
- 身高2.13米
- 国籍喀麦隆
蕾哈娜

- 身份歌手
- 生日88-2-20
- 血型O型
 
恩比德和蕾哈娜，类别分别是球员和歌手，分别拥有身高，国籍以及生日，血型属性。两个节点之间通过一个“喜欢”关系关联，“喜欢”关系拥有自己的一个属性“自从”，属性值为2014年。

创建一个球员节点恩比德
	
	CREATE (embiid: PLAYER {name: 'Embiid', height: '2.13m', nationality: 'Cameroon'})
其中

- create关键字
- embiid变量
- PLAYER类别
- {...}自定义属性

点击Neo4j左边的侧边栏数据库中的PLAYER标签看到刚才新建的节点

创建歌手蕾哈娜节点以及“喜欢”关系
	
	MATCH (embiid:PLAYER{name:'Embiid'})
	MERGE (embiid)-[:LIKES{since:'2014'}]->(Rihanna: SINGER{name:'Rihanna',dob:'1988/2/20',bloodType:'O'})
其中

- 第一行先匹配到之前创建的name为Embiid的PLAYER节点
- MERGE关键字表示如果节点关系不存在就创建，如果存在不做任何操作
- [:LIKES{since:'2014'}]代表一个likes关系，并且包含一个属性since
- (Rihanna: SINGER name:'Rihanna',dob:'1988/2/20',bloodType:'O'}) 类别为SINGER的Rihanna节点，包含生日和血型属性

创建完点击Neo4j左边的侧边栏数据库中的node labels下的*,点击右侧的Graph查看ui图，从图中可以看出新建的蕾哈娜节点和之前的恩比德节点通过LIKES关系关联了起来

查询返回所有喜欢蕾哈娜的PLAYER节点

	MATCH(p:PLAYER)-[:LIKES]->(:SINGER{name:'Rihanna'}) RETURN p;
	 
编写Cypher命令创建2个人，两个人互为朋友关系

	CREATE (n:Person { name: 'Andres', title: 'Developer' }) return n;
	CREATE (n:Person { name: 'Vic', title: 'Developer' }) return n;
	match(n:Person{name:"Vic"}),(m:Person{name:"Andres"}) create (n)-[r:Friend]->(m) return r;
	match(n:Person{name:"Vic"}),(m:Person{name:"Andres"}) create (n)<-[r:Friend]-(m) return r;


# 集群

只在其商用版本中可用

修改配置信息
       
	vim Neo4j.properties     
	keep_logical_logs=true
	online_backup_enabled=true
	online_backup_server=127.0.0.1:6362
	ha.server_id=1
	ha.initial_hosts=127.0.0.1:5001，127.0.0.1:5002，127.0.0.1:5003
	ha.server=127.0.0.1:6362

	vim neo4j-server.properties
	org.neo4j.server.database.location=data/graph.db
	org.neo4j.server.webserver.port=7474
	org.neo4j.server.webserver.https.enabled=true
	org.neo4j.server.webserver.https.port=7473
	org.neo4j.server.webserver.https.cert.location=conf/ssl/snakeoil.cert
	org.neo4j.server.webserver.https.key.location=conf/ssl/snakeoil.key

# 概念

图：一个属性图是由顶点（Vertex）也称作节点（Node），边（Edge）也称作关系（Relationship），标签（Lable），关系类型和属性（Property）组成的有向图；

在图形中，节点和关系是最重要的实体，所有的节点是独立存在的，为节点设置标签，那么拥有相同标签的节点属于一个分组，一个集合；关系通过关系类型来分组，类型相同的关系属于同一个集合。关系是有向的，关系的两端是起始节点和结束节点，通过有向的箭头来标识方向，节点之间的双向关系通过两个方向相反的关系来标识。节点可有零个，一个或多个标签，但是关系必须设置关系类型，并且只能设置一个关系类型。Neo4j图形数据库的查询语言是Cypher，用于操作属性图，是图形语言中事实上的标准

Neo4j创建的图（Graph）基于属性图模型，在该模型中，每个实体都有ID（Identity）唯一标识，每个节点由标签（Lable）分组，每个关系都有一个唯一的类型，属性图模型的基本概念有：

- 实体（Entity）是指节点（Node）和关系（Relationship）；
	- 每个实体都有一个唯一的ID；
	- 每个实体都有零个，一个或多个属性，一个实体的属性键是唯一的；
	- 每个节点都有零个，一个或多个标签，属于一个或多个分组；
	- 每个关系都只有一个类型，用于连接两个节点；
- 路径（Path）是指由起始节点和终止节点之间的实体（节点和关系）构成的有序组合；
- 标记（Token）是非空的字符串，用于标识标签（Lable），关系类型（Relationship Type），或属性键（Property Key）；
	- 标签：用于标记节点的分组，多个节点可以有相同的标签，一个节点可以有多个Lable，Lable用于对节点进行分组；
	- 关系类型：用于标记关系的类型，多个关系可以有相同的关系类型；
	- 属性键：用于唯一标识一个属性；
- 属性（Property）是一个键值对（Key/Value Pair），每个节点或关系可以有一个或多个属性；属性值可以是标量类型，或这标量类型的列表（数组）；
	

# 示例

![](http://images2015.cnblogs.com/blog/628084/201705/628084-20170518140347807-1692730594.png)

节点有标签和属性，关系是有向的，链接两个节点，具有属性和关系类型

存在三个节点和两个关系共5个实体；Person和Movie是Lable，ACTED_ID和DIRECTED是关系类型，name，title，roles等是节点和关系的属性

# 遍历（Traversal）

遍历一个图形，是指沿着关系及其方向，访问图形的节点。关系是有向的，连接两个节点，从起始节点沿着关系，一步一步导航（navigate）到结束节点的过程叫做遍历，遍历经过的节点和关系的有序组合称作路径（Path）。

在示例图形中，查找Tom Hanks参演的电影，遍历的过程是：从Tom Hanks节点开始，沿着ACTED_IN关系，寻找标签为Movie的目标节点。

遍历的路径如图：
![](http://images2015.cnblogs.com/blog/628084/201705/628084-20170519145740463-717146106.png)

# 图形数据库的模式

Neo4j的模式（Schema）通常是指索引，约束和统计，通过创建模式，Neo4j能够获得查询性能的提升和建模的便利；Neo4j数据库的模式可选的，也可以是无模式的。

## 索引

图形数据库也能创建索引，用于提高图形数据库的查询性能。和关系型数据库一样，索引是图形数据的一个冗余副本，通过额外的存储空间和牺牲数据写操作的性能，来提高数据搜索的性能，避免创建不必要的索引，这样能够减少数据更新的性能损失。

Neo4j在图形节点的一个或多个属性上创建索引，在索引创建完成之后，当图形数据更新时，Neo4j负责索引的自动更新，索引的数据是实时同步的；在查询被索引的属性时，Neo4j自动应用索引，以获得查询性能的提升。

例如，使用Cypher创建索引：
	
	CREATE INDEX ON :Person(firstname)
	CREATE INDEX ON :Person(firstname, surname)

## 约束

在图形数据库中，能够创建四种类型的约束：

- 节点属性值唯一约束（Unique node property）：如果节点具有指定的标签和指定的属性，那么这些节点的属性值是唯一的
- 节点属性存在约束（Node property existence）：创建的节点必须存在标签和指定的属性
- 关系属性存在约束（Relationship property existence）：创建的关系存在类型和指定的属性
- 节点键约束（Node Key）：在指定的标签中的节点中，指定的属性必须存在，并且属性值的组合是唯一的

例如，使用Cypher创建约束：
	
	CREATE CONSTRAINT ON (book:Book) ASSERT book.isbn IS UNIQUE;
	CREATE CONSTRAINT ON (book:Book) ASSERT exists(book.isbn);
	CREATE CONSTRAINT ON ()-[like:LIKED]-() ASSERT exists(like.day);
	CREATE CONSTRAINT ON (n:Person) ASSERT (n.firstname, n.surname) IS NODE KEY;
		 
## 统计信息

当使用Cypher查询图形数据库时，Cypher脚本被编译成一个执行计划，执行该执行计划获得查询结果。为了生成一个性能优化的执行计划，Neo4j需要收集统计信息以对查询进行优化。当统计信息变化到一定的赋值时，Neo4j需要重新生成执行计划，以保证Cypher查询是性能优化的 
默认情况下，Neo4j自动更新统计信息，但是，统计信息的更新不是实时的，更新统计信息可能是一个非常耗时的操作，因此，Neo4j在后台运行，并且只有当变化的数据达到一定的阈值时，才会更新统计信息。
 

Neo4j把执行计划被缓存起来，在统计信息变化之前，执行计划不会被重新生成。通过配置选项，Neo4j能够控制执行计划的重新生成：

- dbms.index_sampling.background_enabled：是否在后台统计索引信息，由于Cypher查询的执行计划是根据统计信息生成的，及时更新索引的统计数据对生成性能优化的执行计划非常重要；
- dbms.index_sampling.update_percentage：在更新索引的统计信息之前，索引中有多大比例的数据被更新；
- cypher.statistics_divergence_threshold：当统计信息变化时，Neo4j不会立即更新Cypher查询的执行计划；只有当统计信息变化到一定的程度时，Neo4j才会重新生成执行计划。

# Cypher

和SQL很相似，Cypher语言的关键字不区分大小写，但是属性值，标签，关系类型和变量是区分大小写的。

## 变量（Variable）

变量用于对搜索模式的部分进行命名，并在同一个查询中引用，在小括号()中命名变量，变量名是区分大小写的，示例代码创建了两个变量：n和b，通过return子句返回变量b；

	MATCH (n)-->(b)
	RETURN b
在Cypher查询中，变量用于引用搜索模式（Pattern），但是变量不是必需的，如果不需要引用，那么可以忽略变量。

## 访问属性

在Cypher查询中，通过逗号来访问属性，格式是：Variable.PropertyKey，通过id函数来访问实体的ID，格式是id(Variable)。
	
	match (n)-->(b)
	where id(n)=5 and b.age=18
	return b;
## 创建节点

节点模式的构成：(Variable:Lable1:Lable2{Key1:Value1,Key2,Value2})，实际上，每个节点都有一个整数ID，在创建新的节点时，Neo4j自动为节点设置ID值，在整个数据库中，节点的ID值是递增的和唯一的。

下面的Cypher查询创建一个节点，标签是Person，具有两个属性name和born，通过RETURN子句，返回新建的节点：
	
	create (n:Person { name: 'Tom Hanks', born: 1956 }) return n;
继续创建其他节点：
	
	create (n:Person { name: 'Robert Zemeckis', born: 1951 }) return n;
	create (n:Movie { title: 'Forrest Gump', released: 1951 }) return n;

## 查询节点

通过match子句查询数据库，match子句用于指定搜索的模式（Pattern），where子句为match模式增加谓词（Predicate），用于对Pattern进行约束；

### 查询整个图形数据库

	match(n) return n;
在图形数据库中，有三个节点，Person标签有连个节点，Movie有1个节点

在图节点上点击可以查看节点属性

查询born属性小于1955的节点
	
	match(n) 
	where n.born<1955 
	return n;	

查询具有指定Lable的节点

	match(n:Movie) 
	return n;
查询具有指定属性的节点
	
	match(n{name:'Tom Hanks'}) 
	return n;	

## 创建关系

关系的构成：StartNode - [Variable:RelationshipType{Key1:Value1,Key2:Value2}] -> EndNode，在创建关系时，必须指定关系类型。

### 创建没有任何属性的关系
	
	MATCH (a:Person),(b:Movie)
	WHERE a.name = 'Robert Zemeckis' AND b.title = 'Forrest Gump'
	CREATE (a)-[r:DIRECTED]->(b)
	RETURN r;
### 创建关系，并设置关系的属性
	
	MATCH (a:Person),(b:Movie)
	WHERE a.name = 'Tom Hanks' AND b.title = 'Forrest Gump'
	CREATE (a)-[r:ACTED_IN { roles:['Forrest'] }]->(b)
	RETURN r;

## 查询关系

在Cypher中，关系分为三种：符号“--”，表示有关系，忽略关系的类型和方向；符号“-->”和“<--”，表示有方向的关系；

查询整个数据图形

	match(n) return n;

查询跟指定节点有关系的节点
	
	match(n)--(m:Movie) 
	return n;
返回跟Movie标签有关系的所有节点

查询有向关系的节点
	
	MATCH (:Person { name: 'Tom Hanks' })-->(movie)
	RETURN movie;

为关系命名，通过[r]为关系定义一个变量名，通过函数type获取关系的类型
	
	MATCH (:Person { name: 'Tom Hanks' })-[r]->(movie)
	RETURN r,type(r);

查询特定的关系类型，通过[Variable:RelationshipType{Key:Value}]指定关系的类型和属性
	
	MATCH (:Person { name: 'Tom Hanks' })-[r:ACTED_IN{roles:'Forrest'}]->(movie)
	RETURN r,type(r);

## 更新图形

set子句，用于对更新节点的标签和实体的属性；remove子句用于移除实体的属性和节点的标签；

创建一个完整的Path

由于Path是由节点和关系构成的，当路径中的关系或节点不存在时，Neo4j会自动创建；

	CREATE p =(vic:Worker:Person{ name:'vic',title:"Developer" })-[:WORKS_AT]->(neo)<-[:WORKS_AT]-(michael:Worker:Person { name: 'Michael',title:"Manager" })
	RETURN p
变量neo代表的节点没有任何属性，但是，其有一个ID值，通过ID值为该节点设置属性和标签

为节点增加属性

通过节点的ID获取节点，Neo4j推荐通过where子句和ID函数来实现。
	
	match (n)
	where id(n)=7
	set n.name = 'neo'
	return n;

为节点增加标签
	
	match (n)
	where id(n)=7
	set n:Company
	return n;

为关系增加属性
	
	match (n)<-[r]-(m)
	where id(n)=7 and id(m)=8
	set r.team='Azure'
	return n;

## Merge子句

Merge子句的作用有两个：当模式（Pattern）存在时，匹配该模式；当模式不存在时，创建新的模式，功能是match子句和create的组合。在merge子句之后，可以显式指定on creae和on match子句，用于修改绑定的节点或关系的属性。

通过merge子句，你可以指定图形中必须存在一个节点，该节点必须具有特定的标签，属性等，如果不存在，那么merge子句将创建相应的节点。

通过merge子句匹配搜索模式

匹配模式是：一个节点有Person标签，并且具有name属性；如果数据库不存在该模式，那么创建新的节点；如果存在该模式，那么绑定该节点；
	
	MERGE (michael:Person { name: 'Michael Douglas' })
	RETURN michael;

在merge子句中指定on create子句

如果需要创建节点，那么执行on create子句，修改节点的属性；

	MERGE (keanu:Person { name: 'Keanu Reeves' })
	ON CREATE SET keanu.created = timestamp()
	RETURN keanu.name, keanu.created

在merge子句中指定on match子句

如果节点已经存在于数据库中，那么执行on match子句，修改节点的属性；

	MERGE (person:Person)
	ON MATCH SET person.found = TRUE , person.lastAccessed = timestamp()
	RETURN person.name, person.found, person.lastAccessed

在merge子句中同时指定on create 和 on match子句
	
	MERGE (keanu:Person { name: 'Keanu Reeves' })
	ON CREATE SET keanu.created = timestamp()
	ON MATCH SET keanu.lastSeen = timestamp()
	RETURN keanu.name, keanu.created, keanu.lastSeen

merge子句用于match或create一个关系
	
	MATCH (charlie:Person { name: 'Charlie Sheen' }),(wallStreet:Movie { title: 'Wall Street' })
	MERGE (charlie)-[r:ACTED_IN]->(wallStreet)
	RETURN charlie.name, type(r), wallStreet.title

merge子句用于match或create多个关系
	
	MATCH (oliver:Person { name: 'Oliver Stone' }),(reiner:Person { name: 'Rob Reiner' })
	MERGE (oliver)-[:DIRECTED]->(movie:Movie)<-[:ACTED_IN]-(reiner)
	RETURN movie

merge子句用于子查询

	 
	MATCH (person:Person)
	MERGE (city:City { name: person.bornIn })
	RETURN person.name, person.bornIn, city;
	
	MATCH (person:Person)
	MERGE (person)-[r:HAS_CHAUFFEUR]->(chauffeur:Chauffeur { name: person.chauffeurName })
	RETURN person.name, person.chauffeurName, chauffeur;
	
	MATCH (person:Person)
	MERGE (city:City { name: person.bornIn })
	MERGE (person)-[r:BORN_IN]->(city)
	RETURN person.name, person.bornIn, city;

跟实体相关的函数

1，通过id函数，返回节点或关系的ID

	MATCH (:Person { name: 'Oliver Stone' })-[r]->(movie)
	RETURN id(r);
2，通过type函数，查询关系的类型

	MATCH (:Person { name: 'Oliver Stone' })-[r]->(movie)
	RETURN type(r);
3，通过lables函数，查询节点的标签
	
	MATCH (:Person { name: 'Oliver Stone' })-[r]->(movie)
	RETURN lables(movie);
4，通过keys函数，查看节点或关系的属性键

	MATCH (a)
	WHERE a.name = 'Alice'
	RETURN keys(a)
5，通过properties()函数，查看节点或关系的属性
	
	CREATE (p:Person { name: 'Stefan', city: 'Berlin' })
	RETURN properties(p)

# 批量更新数据

相比图形数据的查询，Neo4j更新图形数据的速度较慢，通常情况下，Neo4j更新数据的工作流程是：每次数据更新都会执行一次数据库连接，打开一个事务，在事务中更新数据。当数据量非常大时，这种做法非常耗时，大多数时间耗费在连接数据库和打开事务上，高效的做法是利用Neo4j提供的参数（Parameter）机制和UNWIND子句：在一次数据更新中，进行一次连接，打开一次事务，批量更新数据；参数用于提供列表格式的数据，UNWIND子句是把列表数据展开成一行一行的数据，每行数据都会执行结构相同的Cypher语句。再批量更新图形数据之前，用户必须构造结构固定的、参数化的Cypher语句。当Cypher语句的结构相同时，Neo4j数据库直接从缓存中复用已生成的执行计划，而不需要重新生成，这也能够提高查询性能。

除了官方的Neo4j Driver之外，本文分享使用Neo4jClient对图形数据批量更新，Neo4jClient提供的功能更强大，并支持参数和批量更新操作。


## 参数和UNWIND子句

### 通过RESTful API传递参数

Neo4j提供HTTP API处理Cypher语句和参数，在示例代码中，Neo4j的参数通过HTTP请求传递，statement定义的是查询语句，parameters定义的是参数。

在批量更新数据时，没有必要发送多个HTTP请求，通过参数，可以在一个HTTP请求（Request）中，开始一个事务，在事务中执行Cypher语句批量更新数据，最后提交该事务。

在发送HTTP请求传递参数批量更新数据时，设置HTTP Request的参数如下：

	POST http://localhost:7474/db/data/transaction/commit
	Accept: application/json; charset=UTF-8
	Content-Type: application/json
注意：在HTTP API中，引用参数的格式是：{param}。

	 
	{
	  "statements" : [ {
	    "statement" : "CREATE (n {props}) RETURN n",
	    "parameters" : {
	      "props" : {
	        "name" : "My Node"
	      }
	    }
	  } ]
	}
 
### 展开（UNWIND）子句

UNWIND子句把列表式的数据展开成一行一行的数据，每一个行都包含更新所需要的全部信息，列表式的数据，可以通过参数来传递。

例如，定义参数events，该参数是一个JSON字符串，键events是参数名，其值是一个数组，包含两个数组元素。

	{
	  "events" : [ {  "year" : 2014, "id" : 1}, {"year" : 2014, "id" : 2 } ]
	}   
通过$events引用参数，UNWIND子句把events数组中的两个元素展开，每个元素执行一次Cypher语句，由于Cypher的语句结构固定，因此，执行计划被缓存起来，在执行数据更新任务时，参数被UNWIND子句展开，复用执行计划，提高数据更新的速度。

	UNWIND $events AS event
	MERGE (y:Year { year: event.year })
	MERGE (y)<-[:IN]-(e:Event { id: event.id })
	RETURN e.id AS x
	ORDER BY x
## 在Neo4j Browser中使用参数

Neo4j Browser是Neo4j内置的浏览器，用于管理数据库，更新数据库和查询数据，再命令窗体中，通过“:”能够引用内置的命令，例如，通过 ":param"能够定义参数，并能够在下一个Cypher语句中引用参数。

### 通过:param命令定义参数

在Neo4j Browser中，输入第一个命令，通过:param 命令定义参数 

	:param events: [{year: 2014, id: 1},{year: 2014,id: 2}] 	

### 通过$param引用参数

紧接着，输入Cypher语句，通过$param引用参数

	UNWIND $events AS event MERGE (y:Year { year: event.year})MERGE (y)<-[:IN]-(e:Event { id: event:id}) RETURN e.id AS x ORDER BY x	
 	

### 查看创建的图形

参数是一个列表格式的数据，在参数events中，两个event的year属性都是2014，因此，MERGE子句只会创建一个Year节点；由于两个event的id属性不同，因此MERGE子句会创建两个Event节点，并创建Year节点和Event节点之间的关系，图形如下图：



## 使用Neo4jClient批量更新数据

在工程（Projects）中输入命令安装Neo4jClient，

	Package-Install Neo4jClient
### 连接Neo4j数据库

创建客户端，连接到数据库，创建的Uri的格式是：http://host_name:7474/db/data，并输入用户名和密码，然后创建图形客户端，并连接到Neo4j数据库。

	 
	private GraphClient _client;
	public Neo4jClientProvider()
	{
	    _client = new GraphClient(new Uri("http://localhost:7474/db/data"), "user_name", "password");
	    _client.Connect();
	}
 
### 批量创建节点

传递List<T>参数，通过Unwind函数引用List，并为参数命名为"ns"，在Cypher语句中引用参数"ns"

	 
	public void CreateNodes(List<DataModel> nodes)
	{
	    _client.Cypher
	        .Unwind(nodes, "ns")
	        .Create("(n:NodeLable)")
	        .Set("n.NodeID=ns.NodeID")
	        .Set("n.Name=ns.Name")
	        .ExecuteWithoutResults();
	}
 
### 批量创建关系

在List<T>参数中，传递两个节点的映射，在Neo4j数据库中，关系必须具有类型，因此，在把参数传递到Neo4j数据中时，需要确定两个节点和关系类型，以创建关系

	 
	public bool CreateRelationships(List<RelationshipModel> nodes)
	{
	    _client.Cypher
	        .Unwind(nodes, "ns")
	        .Match("(n:Lable1),(s:Lable2)")
	        .Where("n.NodeID=ns.NodeID and s.NodeID=ns.RelatedID")
	        .Merge("(n)-[r:RelationshipType]->(s)")
	        .ExecuteWithoutResults();
	}
	

