从算法上来说有5种经典的查找,首先索引查找。

插入10w测试数据：
	
	db.person.remove({})
	db.person.count()

	for(var i=0;i<100000;i++){
		db.person.insert({"name":"jack"+i,"age":i})
	}

一、性能分析函数（explain）

首先借助mongodb提供的分析工具，关键字“explain"

这里的name字段没有建立任何索引，这里我就查询一个“name10000”的姓名。	
	
	db.person.find({"name":"jack10000"})
	db.person.find({"name":"jack10000"}).explain()
	执行结果的参数含义参考：
	http://docs.mongodb.org/manual/reference/method/cursor.explain/#explain-cursor-method-verbosity
	http://docs.mongodb.org/manual/reference/explain-results/#explain.queryPlanner

二、建立索引（ensureIndex）
	
	db.person.ensureIndex({"name":1})
	在name上建立索引,其中1表示按照name进行升序;-1表示降序
	db.person.find({"name":"jack10000"}).explain()

三、唯一索引

建立唯一索引，重复的键值自然就不能插入，在mongodb中的使用方法是：

	/* 查看集合上已有的索引 */
	db.person.getIndexes()
	/* 删除集合上已有的name索引 */
	db.person.dropIndex({"name":1})
	/* 在name上建立唯一索引,name有重复数据时会创建异常需删除重复数据或清空数据 */
	db.person.ensureIndex({"name":1},{"unique":true})	

四：组合索引

	/* 建立name 、age和age、name组合索引，如有已存在同名索引需先删除索引 在建立 */
	db.person.ensureIndex({"name":1,"age":1})
	db.person.ensureIndex({"age":1,"name":1})
	/* name、age的顺序不同建立的索引会不同，升序和降序的顺序不同也会产生不同的索引 */
	/* 查看生成的索引 */
	db.person.getIndexes()
	/*查询时mongodb查询优化器会做出最优选择，会使用创建的索引创建查询方案，如果某一个先执行完则其他的查询方案会被close掉，这种方案会被mongodb保存起来。如需强制指定查询方案,可用hint方法暴力执行 */
	db.person.find({"age":22,"name":"jack"}).hint({"age":1,"name":1}).explain()

五： 删除索引

随着业务需求的变化，原先建立的索引可能没有存在的必要了，可能有的人想说没必要就没必要呗，但是请记住，索引会降低CUD这三种操作的性能，因为这玩意需要实时维护，所以啥问题都要综合考虑一下，这里就把刚才建立的索引清空掉来演示一下:dropIndexes的使用。
	
	/* 查看索引  */
	db.person.getIndexes()
	/* 根据以上查询显示的索引名称删除指定索引 */
	db.person.dropIndex("age_1_name_1")
	/* 删除全部索引 */
	db.person.dropIndexes()
	