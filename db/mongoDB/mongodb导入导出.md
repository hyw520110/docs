mongodb数据备份和还原主要分为二种，一种是针对于库的备份(mongodump)和还原(mongorestore)，文件格式是json和bson的.一种是针对库中表的mongoexport和mongoimport。

mongodump备份数据库

	mongodump -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 -o 文件存放路径 

说明：如果没有用户可以去掉-u和-p。如果导出本机的数据库，可以去掉-h。如果是默认端口，可以去掉--port。如果想导出所有数据库，可以去掉-d。

	导出所有数据库:mongodump -h 127.0.0.1 -o /home/mongodb-data/

	导出指定数据库:mongodump -h 192.168.1.108 -d admin -o /home/mongodb-data/


mongorestore还原数据库

	mongorestore -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 --drop 文件存在路径

说明：--drop是先删除所有的记录，然后恢复。

	恢复所有数据库:mongorestore /home/mongodb-data/
	还原指定的数据库:mongorestore -d admin /home/mongodb-data/  




mongoexport导出表，或者表中部分字段:
	
	mongoexport -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 -c 表名 -f 字段 -q 条件导出 --csv -o 文件名

参数说明：

	-f    导出指字段，以字号分割，-f name,email,age导出name,email,age这三个字段
	-q    可以根查询条件导出，-q '{ "uid" : "100" }' 导出uid为100的数据
	--csv 表示导出的文件格式为csv的

还原整表导出的非csv文件
	
	mongoimport -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 -c 表名 --upsert --drop 文件名  
说明：

	--upsert 插入或者更新现有数据
	--upsertFields还原部分字段
	--drop是先删除所有的记录，然后恢复。

 

	导出/备份整表：mongoexport -d admin -c sys -o /home/mongodb/admin/sys.dat
	导入/还原整表:mongoimport -d admin -c sys --upsert /home/mongodb/admin/sys.dat

	导出表中部分字段:	mongoexport -d admin -c sys --csv -f sysId,name -o /home/mongodb/admin/sys.csv
 	导入表部分字段：mongoimport -d admin -c sys  --upsertFields sysId,name /home/mongodb/admin/sys.dat
	
	根据条件导出数据:	mongoexport -d admin -c sys -q '{uid:{$gt:1}}' -o /home/mongodb/admin/sys.json 
	mongoexport  -d admin -c sys --csv -o sys.csv
	还原csv文件:mongoimport -d admin -c sys --type csv --headerline --file sys.csv





