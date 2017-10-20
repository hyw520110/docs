Dex 是一个开源的MongoDB优化工具，它通过对查询日志和当前数据库索引进行分析，向管理员提出高效的索引优化策略

一、环境：
	
	1、python2.7.3（经测试2.4不支持）
    2、pip
    3、dex0.4，会包含pymongo模块
    4、mongodb 2.0.2（本文写的时候，2.2不支持）
    5、centos5.6

二、步骤：

A、由于在centos5.6中自带的python是2.4.3版本，需要升级到python2.7.3	

	1、下载python2.7.3
    2、tar -zxf Python-2.7.3.tgz
    3、cd Python-2.7.3
    4、./configure --prefix=/usr/local/python2.7/
    5、make && make install
    6、将/usr/local/python2.7/lib/bin中的python替换/usr/bin/python

B、安装pip，pip是python的easy-install工具

	1、安装pip首先要安装setiptools工具，因为在安装pip时会引用setuptools的类，下载地址
    2、sh setuptools-0.6c11-py2.7.egg
    3、下载pip包，下载地址
    4、tar -zxf pip-1.1.tar.gz
    5、cd pip-1.1
    6、python setup.py install

C、安装dex,安装好pip之后，dex就很好装了

	pip install dex
三、dex使用方法，转自http://blog.nosqlfan.com/html/4061.html

    dex -f mongodb.log mongodb://localhost

在监控过程中，dex会通过stderr输出推荐的结果

	    {
    "index": "{'simpleIndexedField': 1, 'simpleUnindexedFieldThree': 1}",
    "namespace": "dex_test.test_collection"
    "shellCommand": "db.test_collection.ensureIndex(
    {'simpleIndexedField': 1, 'simpleUnindexedFieldThree': 1}, {'background': true})"
    }

还会输出一些统计信息：
