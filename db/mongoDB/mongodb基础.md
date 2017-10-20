#mongodb基本三元素：

数据库，集合，文档，其中“集合”就是对应关系数据库中的“表”，“文档”对应“行”

#数据库

一个mongodb中可以建立多个数据库。
MongoDB的默认数据库为"db"，该数据库存储在data目录中。
MongoDB的单个实例可以容纳多个独立的数据库，每一个都有自己的集合和权限，不同的数据库也放置在不同的文件中。

"show dbs" 命令可以显示所有数据的列表。

执行 "db" 命令可以显示当前数据库对象或集合。

运行"use"命令，可以连接到一个指定的数据库。

数据库也通过名字来标识。数据库名可以是满足以下条件的任意UTF-8字符串。

- 不能是空字符串（"")。
- 不得含有' '（空格)、.、$、/、\和\0 (空宇符)。
- 应全部小写。
- 最多64字节。

有一些数据库名是保留的，可以直接访问这些有特殊作用的数据库。

- admin： 从权限的角度来看，这是"root"数据库。要是将一个用户添加到这个数据库，这个用户自动继承所有数据库的权限。一些特定的服务器端命令也只能从这个数据库运行，比如列出所有的数据库或者关闭服务器。
- local: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合
- config: 当Mongo用于分片设置时，config数据库在内部使用，用于保存分片的相关信息。

#文档

文档是一个键值(key-value)对(即BSON)。MongoDB 的文档不需要设置相同的字段，并且相同的字段不需要相同的数据类型，这与关系型数据库有很大的区别，也是 MongoDB 非常突出的特点。

一个简单的文档例子如下：

	{"site":"www.runoob.com", "name":"菜鸟教程"}

RDBMS/MongoDB 对应的术语：

	
	数据库/数据库
	表格/集合
	行/文档
	列/字段
	表联合/嵌入文档
	主键/主键 (MongoDB 提供了 key 为 _id )

需要注意的是：

- 文档中的键/值对是有序的。
- 文档中的值不仅可以是在双引号里面的字符串，还可以是其他几种数据类型（甚至可以是整个嵌入的文档)。
- MongoDB区分类型和大小写。
- MongoDB的文档不能有重复的键。
- 文档的键是字符串。除了少数例外情况，键可以使用任意UTF-8字符。

文档键命名规范：

- 键不能含有\0 (空字符)。这个字符用来表示键的结尾。
- .和$有特别的意义，只有在特定环境下才能使用。
- 以下划线"_"开头的键是保留的(不是严格要求的)。

#集合

集合就是 MongoDB 文档组，类似于 RDBMS （关系数据库管理系统：Relational Database Management System)中的表格。
集合存在于数据库中，集合没有固定的结构，这意味着你在对集合可以插入不同格式和类型的数据，但通常情况下我们插入集合的数据都会有一定的关联性。

比如，我们可以将以下不同数据结构的文档插入到集合中：

	{"site":"www.baidu.com"}
	{"site":"www.google.com","name":"Google"}
	{"site":"www.runoob.com","name":"菜鸟教程","num":5}
当第一个文档插入时，集合就会被创建。

合法的集合名

- 集合名不能是空字符串""。
- 集合名不能含有\0字符（空字符)，这个字符表示集合名的结尾。
- 集合名不能以"system."开头，这是为系统集合保留的前缀。
- 用户创建的集合名字不能含有保留字符。有些驱动程序的确支持在集合名里面包含，这是因为某些系统生成的集合中包含该字符。除非你要访问这种系统创建的集合，否则千万不要在名字里出现$。　

如下实例：

	db.col.findOne()

capped collections

Capped collections 就是固定大小的collection。
它有很高的性能以及队列过期的特性(过期按照插入的顺序). 有点和 "RRD" 概念类似。
Capped collections是高性能自动的维护对象的插入顺序。它非常适合类似记录日志的功能 和标准的collection不同，你必须要显式的创建一个capped collection， 指定一个collection的大小，单位是字节。collection的数据存储空间值提前分配的。

要注意的是指定的存储大小包含了数据库的头信息。

	db.createCollection("mycoll", {capped:true, size:100000})
- 在capped collection中，你能添加新的对象。
- 能进行更新，然而，对象不会增加存储空间。如果增加，更新就会失败 。
- 数据库不允许进行删除。使用drop()方法删除collection所有的行。

注意: 删除之后，你必须显式的重新创建这个collection。
在32bit机器中，capped collection最大存储为1e9( 1X109)个字节。

#元数据

数据库的信息是存储在集合中。它们使用了系统的命名空间：

	dbname.system.*
在MongoDB数据库中名字空间 <dbname>.system.* 是包含多种系统信息的特殊集合(Collection)，如下:

	集合命名空间	描述
	dbname.system.namespaces	列出所有名字空间。
	dbname.system.indexes	列出所有索引。
	dbname.system.profile	包含数据库概要(profile)信息。
	dbname.system.users	列出所有可访问数据库的用户。
	dbname.local.sources	包含复制对端（slave）的服务器信息和状态。
对于修改系统集合中的对象有如下限制。
在{{system.indexes}}插入数据，可以创建索引。但除此之外该表信息是不可变的(特殊的drop index命令将自动更新相关信息)。
{{system.users}}是可修改的。 {{system.profile}}是可删除的。


#MongoDB 数据类型

MongoDB中常用的几种数据类型：

	数据类型	描述
	String	字符串。存储数据常用的数据类型。在 MongoDB 中，UTF-8 编码的字符串才是合法的。
	Integer	整型数值。用于存储数值。根据你所采用的服务器，可分为 32 位或 64 位。
	Boolean	布尔值。用于存储布尔值（真/假）。
	Double	双精度浮点值。用于存储浮点值。
	Min/Max keys	将一个值与 BSON（二进制的 JSON）元素的最低值和最高值相对比。
	Arrays	用于将数组或列表或多个值存储为一个键。
	Timestamp	时间戳。记录文档修改或添加的具体时间。
	Object	用于内嵌文档。
	Null	用于创建空值。
	Symbol	符号。该数据类型基本上等同于字符串类型，但不同的是，它一般用于采用特殊符号类型的语言。
	Date	日期时间。用 UNIX 时间格式来存储当前日期或时间。你可以指定自己的日期时间：创建 Date 对象，传入年月日信息。
	Object ID	对象 ID。用于创建文档的 ID。
	Binary Data	二进制数据。用于存储二进制数据。
	Code	代码类型。用于在文档中存储 JavaScript 代码。
	Regular expression	正则表达式类型。用于存储正则表达式。

#基本操作

在cmd下进入mongodb的bin目录，输入mongo命令打开shell，其实这个shell就是mongodb的客户端，同时也是一个js的编译器，默认连接的是“test”数据库。 


MongoDB连接命令格式

使用用户名和密码连接到MongoDB服务器，你必须使用 'username:password@hostname/dbname' 格式，'username'为用户名，'password' 为密码。

使用用户名和密码连接登陆到默认数据库：

	./mongo
	mongodb://admin:123456@localhost/
连接到指定数据库的格式如下：

	mongodb://admin:123456@localhost/test

更多连接实例

连接本地数据库服务器，端口是默认的。
	
	mongodb://localhost
使用用户名fred，密码foobar登录localhost的admin数据库。

	mongodb://fred:foobar@localhost
使用用户名fred，密码foobar登录localhost的baz数据库。

	mongodb://fred:foobar@localhost/baz
连接 replica pair, 服务器1为example1.com服务器2为example2。

	mongodb://example1.com:27017,example2.com:27017
连接 replica set 三台服务器 (端口 27017, 27018, 和27019):

	mongodb://localhost,localhost:27018,localhost:27019
连接 replica set 三台服务器, 写入操作应用在主服务器 并且分布查询到从服务器。

	mongodb://host1,host2,host3/?slaveOk=true
直接连接第一个服务器，无论是replica set一部分或者主服务器或者从服务器。

	mongodb://host1,host2,host3/?connect=direct;slaveOk=true
当你的连接服务器有优先级，还需要列出所有服务器，你可以使用上述连接方式。

安全模式连接到localhost:

	mongodb://localhost/?safe=true
以安全模式连接到replica set，并且等待至少两个复制服务器成功写入，超时时间设置为2秒。

	mongodb://host1,host2,host3/?safe=true;w=2;wtimeoutMS=2000

参数选项说明

标准格式：

	mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]
标准的连接格式包含了多个选项(options)，如下所示：

	选项					描述
	replicaSet=name		验证replica set的名称。 Impliesconnect=replicaSet.
	
	slaveOk=true|false	true:在connect=direct模式下，驱动会连接第一台机器，即使这台服务器不是主。在connect=replicaSet模式下，驱动会发送所有的写请求到主并且把读取操作分布在其他从服务器。
						false: 在 connect=direct模式下，驱动会自动找寻主服务器. 在connect=replicaSet 模式下，驱动仅仅连接主服务器，并且所有的读写命令都连接到主服务器。
	
	safe=true|false		true: 在执行更新操作之后，驱动都会发送getLastError命令来确保更新成功。(还要参考 wtimeoutMS).
						false: 在每次更新之后，驱动不会发送getLastError来确保更新成功。
	
	w=n					驱动添加 { w : n } 到getLastError命令. 应用于safe=true。
	wtimeoutMS=ms		驱动添加 { wtimeout : ms } 到 getlasterror 命令. 应用于 safe=true.
	fsync=true|false	true: 驱动添加 { fsync : true } 到 getlasterror 命令.应用于 safe=true.
						false: 驱动不会添加到getLastError命令中。
	journal=true|false	如果设置为 true, 同步到 journal (在提交到数据库前写入到实体中). 应用于 safe=true
	connectTimeoutMS=ms	可以打开连接的时间。
	socketTimeoutMS=ms	发送和接受sockets的时间。 
#MongoDB 创建数据库

MongoDB 创建数据库的语法格式如下：

	use DATABASE_NAME
如果数据库不存在，则创建数据库，否则切换到指定数据库。

默认的数据库为 test，如果你没有创建新的数据库，集合将存放在 test 数据库中。
	
查看所有数据库，可以使用 show dbs 命令，注意：刚创建的数据库并不在数据库的列表中， 要显示刚创建的数据需要插入数据才可以。

#MongoDB 删除数据库

语法

MongoDB 删除数据库的语法格式如下：

	db.dropDatabase()
删除当前数据库，默认为 test，你可以使用 db 命令查看当前数据库名。

#删除集合

集合删除语法格式如下：

	db.collection.drop()
#插入文档

使用 insert() 或 save() 方法向集合中插入文档，语法如下：

	db.COLLECTION_NAME.insert(document)

数据库有了，下一步就是集合，这里就取集合名为“person”，要注意的就是文档是一个json的扩展（Bson)形式,是采用“K-V”格式存储的,JSON里面Value可能是“字符串”，可能是“数组”，又有可能是内嵌的一个JSON对象，相同的方式也适合于BSON。

基本示例:

	db.person.insert({"name":"jack",age:25})
	db.person.insert({"name":"rose",age:22})
person是集合名，如果该集合不在该数据库中， MongoDB 会自动创建该集合并插入文档。

查看已插入文档：

	db.person.find()

也可以将数据定义为一个变量，如下所示：

	document=({title: 'MongoDB 教程', 
	    description: 'MongoDB 是一个 Nosql 数据库',
	    by: '菜鸟教程',
	    url: 'http://www.runoob.com',
	    tags: ['mongodb', 'database', 'NoSQL'],
	    likes: 100	
	});
	
	db.docs.insert(document)

插入文档你也可以使用 db.col.save(document) 命令。如果不指定 _id 字段 save() 方法类似于 insert() 方法。如果指定 _id 字段，则会更新该 _id 的数据。
 
js示例：
	
	var single={"name":"jack","password":"123456","age":22,"address":{"province":"hubei","city":"anlu"},"favourite":["apple","banana"]}
	db.user.insert(single)
	single.name="joe"
	single.age=30
	single.address={"province":"zhejiang","city":"hangzhou"}
	single.favourite=["mm","money"]
	db.user.insert(single)	
	db.user.find()
##save方法

save() 方法通过传入的文档来替换已有文档。语法格式如下：
	
	db.collection.save(
	   <document>,
	   {
	     writeConcern: <document>
	   }
	)
参数说明：

	document : 文档数据。
	writeConcern :可选，抛出异常的级别。
实例,以下实例中我们替换了 _id 为 56064f89ade2f21f36b03136 的文档数据：
	
	>db.col.save({
		"_id" : ObjectId("56064f89ade2f21f36b03136"),
	    "title" : "MongoDB",
	    "description" : "MongoDB 是一个 Nosql 数据库",
	    "by" : "Runoob",
	    "url" : "http://www.runoob.com",
	    "tags" : [
	            "mongodb",
	            "NoSQL"
	    ],
	    "likes" : 110
	})
替换成功后，我们可以通过 find() 命令来查看替换后的数据
	
	>db.col.find().pretty()

#find 操作

查询数据的语法格式如下：

	db.COLLECTION_NAME.find()

find()方法以非结构化的方式来显示所有文档。

如果你需要以易读的方式来读取数据，可以使用 pretty() 方法，语法格式如下：

	db.col.find().pretty()
除了 find() 方法之外，还有一个 findOne() 方法，它只返回一个文档。

查询结果：

	① “_id"： 这个字段是数据库默认给我们加的GUID，目的就是保证数据的唯一性。

	② 严格的按照Bson的形式书写文档，不过也没关系，错误提示还是很强大的。

示例：
	db.person.find()
	db.person.find().pretty()
	db.person.find({"name":"rose"})	

常见查询操作符：
	
	①： >, >=, <, <=, !=, =。

    ②：And，OR，In，NotIn

"$gt", "$gte", "$lt", "$lte", "$ne", "没有特殊关键字"，这些跟上面是一一对应的,示例：

	/* find age>22 */
	db.person.find({"age",{$gt:22}})
	/* find age<22 */
	db.person.find({"age",{$lt:22}})
	/* find age!=22 */
	db.person.find({"age",{$ne:22}})

	/* find name="jack" && province="hubei" */
	db.user.find({"name":"jack","address.province":"hubei"})
	/* find province="zhejiang" || province="hubei" */
	db.user.find({$or:[{"address.province":"zhejiang"},{"address.province":"hubei"}]})
	/* find name="jack" && (province="zhejiang" || province="hubei" ) */
	db.user.find({"name":"jack"},{$or:[{"address.province":"zhejiang"},{"address.province":"hubei"}]})
	/* find province in ["zhejiang" , province="hubei"] */
	db.user.find({"address.province":{$in:["hubei","zhejiang"]}})
	/* find province not in ["zhejiang" , province="hubei"] */
	db.user.find({"address.province":{$min:["hubei","zhejiang"]}})
	/*没有地址的用户*/
	db.user.find({address:{$in:[null]}})
正则表达式查询：

	/* find name startwith j and endwith e */
	db.user.find({"name":/^j/,"name":/e$/})
复杂查询$where：
	
	/* find name='jack' */
	db.user.find({$where:function(){return this.name=='jack'}})
#$type 操作符

$type操作符是基于BSON类型来检索集合中匹配的数据类型，并返回结果。

MongoDB 中可以使用的类型如下表所示：

	类型						数字		备注
	Double					1	 
	String					2	 
	Object					3	 
	Array					4	 
	Binary data				5	 
	Undefined				6		已废弃。
	Object id				7	 
	Boolean					8	 
	Date					9	 
	Null					10	 
	Regular Expression		11	 
	JavaScript				13	 
	Symbol					14	 
	JavaScript (with scope)	15	 
	32-bit integer			16	 
	Timestamp				17	 
	64-bit integer			18	 
	Min key					255		Query with -1.
	Max key					127	 
示例，如果想获取 "col" 集合中 title 为 String 的数据，你可以使用以下命令：
	
	db.col.find({"title" : {$type : 2}})

#update操作

update() 方法用于更新已存在的文档,方法的第一个参数为“查找的条件”，第二个参数为“更新的值”。语法格式如下：
	
	db.collection.update(
	   <query>,
	   <update>,
	   {
	     upsert: <boolean>,
	     multi: <boolean>,
	     writeConcern: <document>
	   }
	)
参数说明：

	query : update的查询条件，类似sql update查询内where后面的。
	update : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的
	upsert : 可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
	multi : 可选，mongodb 默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。
	writeConcern :可选，抛出异常的级别。

整体更新，示例：
	
	db.person.update({"name":"jack"},{"age",26})

局部更新提供2个修改器：$inc、$set，示例:
	
	 $inc也就是increase的缩写，每次修改会在原有的基础上自增$inc指定的值，如果“文档”中没有此key，则会创建key。
	/* jack 的age从20变为30 */
	db.user.update({"name":"jack"},{$inc:{"age":10}})
	/* jack 的age从30变为40 */
	db.user.update({"name":"jack"},{$set:{"age":40}})

upsert操作：新增或更新，将update的第三个参数设置为true即可。示例：

	db.user.update({"name":"jackson"},{$inc:{"age":1}},true)

批量操作，update默认只更新第一条，批量更新指定第4个参数为true即可
	
	db.user.update({'name':'jackson'},{$set:{'name':'jack'}},{multi:true})
更多实例

只更新第一条记录：

	db.col.update( { "count" : { $gt : 1 } } , { $set : { "test2" : "OK"} } );
全部更新：

	db.col.update( { "count" : { $gt : 3 } } , { $set : { "test2" : "OK"} },false,true );
只添加第一条：

	db.col.update( { "count" : { $gt : 4 } } , { $set : { "test5" : "OK"} },true,false );
全部添加加进去:

	db.col.update( { "count" : { $gt : 5 } } , { $set : { "test5" : "OK"} },true,true );
全部更新：

	db.col.update( { "count" : { $gt : 15 } } , { $inc : { "count" : 1} },false,true );
只更新第一条记录：

	db.col.update( { "count" : { $gt : 10 } } , { $inc : { "count" : 1} },false,false );

#remove操作

方法的基本语法格式如下所示：
	
	db.collection.remove(
	   <query>,
	   <justOne>
	)
如果是 2.6 版本以后的，语法格式如下：

	db.collection.remove(
	   <query>,
	   {
	     justOne: <boolean>,
	     writeConcern: <document>
	   }
	)
参数说明：
	
	query :（可选）删除的文档的条件。
	justOne : （可选）如果设为 true 或 1，则只删除一个文档。
	writeConcern :（可选）抛出异常的级别。

remove中如果不带参数将删除所有数据，在mongodb中是一个不可撤回的操作，需谨慎操作，示例：
	
	db.person.remove({"name":"jack"})
	db.person.find()
只想删除第一条找到的记录可以设置 justOne 为 1，如下所示：

	db.person.remove({"name":"jack"},1)
删除所有数据
 	
	db.person.remove()
	db.person.find()
	db.person.count()

#MongoDB Limit方法

读取指定数量的数据记录，可以使用MongoDB的Limit方法，limit()方法接受一个数字参数，该参数指定从MongoDB中读取的记录条数。
语法
limit()方法基本语法如下所示：

	>db.COLLECTION_NAME.find().limit(NUMBER)
显示查询文档中的两条记录：

	db.col.find().limit(2)
#MongoDB Skip() 方法

我们除了可以使用limit()方法来读取指定数量的数据外，还可以使用skip()方法来跳过指定数量的数据，skip方法同样接受一个数字参数作为跳过的记录条数。

skip() 方法脚本语法格式如下：


	db.COLLECTION_NAME.find().limit(NUMBER).skip(NUMBER)
示例，查询第二条数据：
	
	db.col.find().limit(1).skip(1)

#MongoDB sort()方法
在MongoDB中使用使用sort()方法对数据进行排序，sort()方法可以通过参数指定排序的字段，并使用 1 和 -1 来指定排序的方式，其中 1 为升序排列，而-1是用于降序排列。

如果没有指定sort()方法的排序方式，默认按照文档的升序排列。


sort()方法基本语法如下所示：

	>db.COLLECTION_NAME.find().sort({KEY:1})
按likes字段降序排序：
	
	db.col.find({},{"title":1,_id:0}).sort({"likes":-1})

#MongoDB 索引
MongoDB 从 2.4 版本开始支持全文检索，目前支持15种语言(暂时不支持中文)的全文索引。

MongoDB 在 2.6 版本以后是默认开启全文检索的，如果使用之前的版本，你需要使用以下代码来启用全文检索:

	db.adminCommand({setParameter:true,textSearchEnabled:true})
或者使用命令：

	mongod --setParameter textSearchEnabled=true

索引通常能够极大的提高查询的效率，如果没有索引，MongoDB在读取数据时必须扫描集合中的每个文件并选取那些符合查询条件的记录。

这种扫描全集合的查询效率是非常低的，特别在处理大量的数据时，查询可以要花费几十秒甚至几分钟，这对网站的性能是非常致命的。
索引是特殊的数据结构，索引存储在一个易于遍历读取的数据集合中，索引是对数据库表中一列或多列的值进行排序的一种结构


MongoDB使用 ensureIndex() 方法来创建索引。

ensureIndex()方法基本语法格式如下所示：

	db.COLLECTION_NAME.ensureIndex({KEY:1})
语法中 Key 值为你要创建的索引字段，1为指定按升序创建索引，如果你想按降序来创建索引指定为-1即可。

示例：

	db.col.ensureIndex({"title":1})
ensureIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）。

	db.col.ensureIndex({"title":1,"description":-1})

ensureIndex() 接收可选参数，可选参数列表如下：
	
	Parameter	Type	Description
	background	Boolean	建索引过程会阻塞其它数据库操作，background可指定以后台方式创建索引，即增加 "background" 可选参数。 "background" 默认值为false。
	unique	Boolean	建立的索引是否唯一。指定为true创建唯一索引。默认值为false.
	name	string	索引的名称。如果未指定，MongoDB的通过连接索引的字段名和排序顺序生成一个索引名称。
	dropDups	Boolean	在建立唯一索引时是否删除重复记录,指定 true 创建唯一索引。默认值为 false.
	sparse	Boolean	对文档中不存在的字段数据不启用索引；这个参数需要特别注意，如果设置为true的话，在索引字段中不会查询出不包含对应字段的文档.。默认值为 false.
	expireAfterSeconds	integer	指定一个以秒为单位的数值，完成 TTL设定，设定集合的生存时间。
	v	index version	索引的版本号。默认的索引版本取决于mongod创建索引时运行的版本。
	weights	document	索引权重值，数值在 1 到 99,999 之间，表示该索引相对于其他索引字段的得分权重。
	default_language	string	对于文本索引，该参数决定了停用词及词干和词器的规则的列表。 默认为英语
	language_override	string	对于文本索引，该参数指定了包含在文档中的字段名，语言覆盖默认的language，默认值为 language.

在后台创建索引：

	db.values.ensureIndex({open: 1, close: 1}, {background: true})
通过在创建索引时加background:true 的选项，让创建工作在后台执行

删除已存在的全文索引，可以使用 find 命令查找索引名：
	
	db.col.getIndexes()
通过以上命令获取索引名，本例的索引名为post_text_text，执行以下命令来删除索引：

	db.col.dropIndex("post_text_text")

#聚合

MongoDB中聚合(aggregate)主要用于处理数据(诸如统计平均值,求和等)，并返回计算后的数据结果。常见的聚合操作跟sql server类似，有：count，distinct，group，mapReduce。。

MongoDB中聚合的方法使用aggregate()。

aggregate() 方法的基本语法格式如下所示：

	db.COLLECTION_NAME.aggregate(AGGREGATE_OPERATION)
 
示例：
	
	/*  select by_user, count(*) from mycol group by by_user */
	db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$sum : 1}}}])
聚合的表达式:

	表达式			描述										实例
	$sum		计算总和。								  db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$sum : "$likes"}}}])
	$avg		计算平均值								  db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$avg : "$likes"}}}])
	$min		获取集合中所有文档对应值得最小值。			 db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$min : "$likes"}}}])
	$max		获取集合中所有文档对应值得最大值。			 db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$max : "$likes"}}}])
	$push		在结果文档中插入值到一个数组中。		 	  db.mycol.aggregate([{$group : {_id : "$by_user", url : {$push: "$url"}}}])
	$addToSet	在结果文档中插入值到一个数组中，但不创建副本。  db.mycol.aggregate([{$group : {_id : "$by_user", url : {$addToSet : "$url"}}}])
	$first		根据资源文档的排序获取第一个文档数据。			db.mycol.aggregate([{$group : {_id : "$by_user", first_url : {$first : "$url"}}}])
	$last		根据资源文档的排序获取最后一个文档数据			db.mycol.aggregate([{$group : {_id : "$by_user", last_url : {$last : "$url"}}}])

<1> count

count是最简单，最容易，也是最常用的聚合工具，示例：

	db.person.count()

<2> distinct
	
	db.person.distinct("age")

<3> group

	db.person.group({
		"key":{"age":true},
		"initial":{"person":[]},
		"$reduce":function(cur,prev){
			prev.person.push(cur.name);
		}
	})

以下示例按照age进行group操作，value为对应age的姓名。下面对这些参数介绍一下：

       key：  这个就是分组的key，我们这里是对年龄分组。

       initial: 每组都分享一个”初始化函数“，特别注意：是每一组，比如这个的age=20的value的list分享一个initial函数，age=22同样也分享一个initial函数。

       $reduce: 这个函数的第一个参数是当前的文档对象，第二个参数是上一次function操作的累计对象，第一次为initial中的{”perosn“：[]}。有多少个文档， $reduce就会调用多少次。

对以上示例增加以下功能：
	
	 ①：想过滤掉age>25一些人员。

     ②：有时person数组里面的人员太多，我想加上一个count属性标明一下。

 针对上面的需求，在group里面还是很好办到的，因为group有这么两个可选参数: condition 和 finalize。

     condition:  这个就是过滤条件。

     finalize:这是个函数，每一组文档执行完后，多会触发此方法，那么在每组集合里面加上count可以用此函数。
示例：

	db.person.group({
		"key":{"age":true},
		"initial":{"person":[]},
		"reduce":function(doc,out){
			out.person.push(doc.name);
		},
		"finalize":function(out){
			out.count=out.person.length;
		},
		"condition":{"age":{$lt:25}}
	})

<4> mapReduce
	
mapReduce其实是一种编程模型，用在分布式计算中，其中有一个“map”函数，一个”reduce“函数。

	① map：

          这个称为映射函数，里面会调用emit(key,value)，集合会按照你指定的key进行映射分组。

	② reduce：

         这个称为简化函数，会对map分组后的数据进行分组简化，注意：在reduce(key,value)中的key就是
		 emit中的key，vlaue为emit分组后的emit(value)的集合，这里也就是很多{"count":1}的数组。

	③ mapReduce:

          这个就是最后执行的函数了，参数为map，reduce和一些可选参数。
示例：

	var map=function (){
	 emit(this.name,{count:1}); 
	}
	
	var reduce=function(key,value){
		var result={count:0};
		for (var i=0;i<value.length;i++){
			result.count +=value[i].count;
		}
		return result;
	}
	
	db.person.mapReduce(map,reduce,{"out":"collection"}) 
	执行结果参数：
		result: "存放的集合名“；
		input:传入文档的个数。
       	emit：此函数被调用的次数。
	    reduce：此函数被调用的次数。
	    output:最后返回文档的个数。
	db.collection.find()

#管道的概念
管道在Unix和Linux中一般用于将当前命令的输出结果作为下一个命令的参数。

MongoDB的聚合管道将MongoDB文档在一个管道处理完毕后将结果传递给下一个管道处理。管道操作是可以重复的。

表达式：处理输入文档并输出。表达式是无状态的，只能用于计算当前聚合管道的文档，不能处理其它的文档。

这里我们介绍一下聚合框架中常用的几个操作：

- $project：修改输入文档的结构。可以用来重命名、增加或删除域，也可以用于创建计算结果以及嵌套文档。
- $match：用于过滤数据，只输出符合条件的文档。$match使用MongoDB的标准查询操作。
- $limit：用来限制MongoDB聚合管道返回的文档数。
- $skip：在聚合管道中跳过指定数量的文档，并返回余下的文档。
- $unwind：将文档中的某一个数组类型字段拆分成多条，每条包含数组中的一个值。
- $group：将集合中的文档分组，可用于统计结果。
- $sort：将输入文档排序后输出。
- $geoNear：输出接近某一地理位置的有序文档。

管道操作符实例

$project实例

	db.article.aggregate(
	    { $project : {
	        title : 1 ,
	        author : 1 ,
	    }}
	 );
这样的话结果中就只还有_id,tilte和author三个字段了，默认情况下_id字段是被包含的，如果要想不包含_id话可以这样:

	db.article.aggregate(
    { $project : {
        _id : 0 ,
        title : 1 ,
        author : 1
    }});
$match实例
	
	db.articles.aggregate( [
	                        { $match : { score : { $gt : 70, $lte : 90 } } },
	                        { $group: { _id: null, count: { $sum: 1 } } }
	                       ] );
$match用于获取分数大于70小于或等于90记录，然后将符合条件的记录送到下一阶段$group管道操作符进行处理。

$skip实例

	db.article.aggregate(
	    { $skip : 5 });
经过$skip管道操作符处理后，前五个文档被"过滤"掉。


二、游标

示例：

	var list=db.person.find();
说明：list其实并没有获取到person中的文档，而是申明一个“查询结构”，等我们需要的时候通过
for或者next()一次性加载过来，然后让游标逐行读取，当我们枚举完了之后，游标销毁，
之后我们在通过list获取时，发现没有数据返回了。	
	
	list.forEach(function(x){
		print(x.name);
	})
	
	var single=db.person.find().sort({"name":1}).skip(2).limit(2);
	single


中文手册：

http://docs.mongoing.com/manual-zh/


