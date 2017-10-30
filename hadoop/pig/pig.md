# 简介

是一个基于Hadoop的大规模数据分析工具，它提供的SQL-LIKE语言叫Pig Latin，该语言的编译器会把类SQL的数据分析请求转换为一系列经过优化处理的MapReduce运算。

Pig是yahoo捐献给apache的一个项目，使用SQL-like语言，是在MapReduce上构建的一种高级查询语言，把一些运算编译进MapReduce模型的Map和Reduce中。Pig 有两种运行模式： Local 模式和 MapReduce 模式

- 本地模式：Pig运行于本地模式，只涉及到单独的一台计算机
- MapReduce模式：Pig运行于MapReduce模式，需要能访问一个Hadoop集群，并且需要装上HDFS

Pig的调用方式：

- Grunt shell方式：通过交互的方式，输入命令执行任务；
- Pig script方式：通过script脚本的方式来运行任务；
- 嵌入式方式：嵌入java源代码中，通过java调用来运行任务。

# 安装

从http://hadoop.apache.org/pig/releases.html下载稳定版本

解压配置环境path

## 本地模式

Grunt是Pig的外壳程序（shell）。本地模式下，Pig运行在单个JVM中，访问本地文件系统，该模式用于测试或处理小规模数据集

	pig -x local
## MapReduce模式

在MapReduce模式下，Pig将查询翻译为MapReduce作业，然后在Hadoop集群上执行。Pig版本和Hadoop版本间，有要求
	
	Pig 0.12.1 Hadoop 2.2.0 
	pig 0.13.0 Hadoop 2.5.0

官方教程：

https://cwiki.apache.org/confluence/display/PIG/PigTutorial

