MapReduce是一个编程模型，封装了并行计算、容错、数据分布、负载均衡等细节问题。
输入是一个key-value对的集合，中间输出也是key-value对的集合，用户使用两个函数：Map和Reduce
	
MongoDb是通过解析“Javascript”代码来计算的
	
	db.runCommand(  
	{  
	    mapreduce : <collection>,  
	    map : <mapfunction>,  
	    reduce : <reducefunction>  
	    [, query : <query filter object>]  
	    [, sort : <sort the query.  useful   optimization>] for  
	    [, limit : <number of objects to   from collection>] return  
	    [, out : <output-collection name>]  
	    [, keeptemp: < | >] true false  
	    [, finalize : <finalizefunction>]  
	    [, scope : <object where fields go into javascript global scope >]  
	    [, verbose :  ] true  
	});  
参数说明:
 
- mapreduce: 要操作的目标集合。
- map: 映射函数 (生成键值对序列，作为 reduce 函数参数)。
- reduce: 统计函数。
- query: 目标记录过滤。
- sort: 目标记录排序。
- limit: 限制目标记录数量。
- out: 统计结果存放集合 (不指定则使用临时集合，在客户端断开后自动删除)。
- keeptemp: 是否保留临时集合。
- finalize: 最终处理函数 (对 reduce 返回结果进行最终整理后存入结果集合)。
- scope: 向 map、reduce、finalize 导入外部变量。
- verbose: 显示详细的时间统计信息

实例：

user集合:

 	name
	age	
	accounts 
按照名字name统计记录个数：
	
	 map = function() {  
	  	emit(this.name, {count:1});  
	 };  
	
	 reduce = function(key, values) {  
	  var total = 0;  
	  var index =0;  
	  for(var i=0;i<values.length;i++){  
	   total += values[i].count;  
	   index = i;  
	 	}  
	   return {count:total};  
	 }; 

	db.user.mapReduce(map, reduce, {out : "resultCollection"});  
	db.resultCollection.find();

其中：

	map = function() {   
    	emit(this.name, {count:1});  
	};  
此函数是形成下面的key-values结构的，emit就是指定key和value的，也是结果的数据结构  

如有三个同名的用户(jack)

	jack [{count:1},{count:1},{count:1}]
会有三个{count:1}数组
	
	reduce = function(key, values) {  
	    var total = 0;  
	    for(var i=0;i<values.length;i++){  
	         total += values[i].count;  
	    }  
	    return {count:total};  
	};  
reduce函数中参数key和map函数的emit指定的key（this.name）是同一个key（name），values就是map函数形成的values（ [{count:1},{count:1},{count:1}]）

经过reduce函数处理就形成了key和一个最终的 {count:3}数据结构。定义好的函数，需要MongoDB执
	
	db.user.mapReduce(map, reduce, {out : "resultCollection"});  
	db.resultCollection.find();  
 db代表当前的数据库，user当前的文档集合，mapReduce调用函数，out：是指定输出的文档名称。