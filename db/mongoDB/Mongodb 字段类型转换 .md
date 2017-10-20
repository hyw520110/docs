 最近一些项目由于历史原因，字段类型存储混乱，比如一个collection里modifedDate列，有的存的是ISODate类型，有的是NumberLong时间戳，这在Mongodb中是严重不推荐的，需要转换成统一的。Mongodb并不提供Alter table这样的语句或者工具，只能写程序转。
     
 Mongodb的客户端是js写的，其实用js写脚本就可以实现。

以上面的例子来说，要将ISODate类型全都转换为NumberLong时间戳：

1、查询多少记录是ISODate类型

①、$type

    db.table_name.find({modifedDate:{$type:9}}).count()


其中的9是Mongodb定义的BSON Date类型对应的数字。下面这张表是BSON TYPE及他们对应的数字。
![image](http://blog.chinaunix.net/attachment/201308/29/15795819_1377755529DlLA.jpg)

②、forEach函数和instanceof

    count=0;
    db.table_name.find().forEach(function(x){if(x.modifedDate instanceof Date){count++}});
    print(count);


2、修改类型

使用forEach函数
      

    db.table_name.find({modifedDate:{$type:9}}).forEach(function(x){x.modifiedDate=NumberLong(x.modifiedDate.getTime()/1000);db.table_name.save(x)})

