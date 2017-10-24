一般有两种方式	

第一种比较简单（create from project），具体步骤如下：

1、首先需要有一个maven模板工程

2、在项目目录下执行
	
	mvn archetype:create-from-project
3、在创建的target/generated-sources/archetype目录下,执行
	
	mvn install
	或mvn deploy 
安装本地库或发布到私服

4、创建新工程时执行：

	mvn archetype:generate -DarchetypeGroupId= 模板的groupid -DarchetypeArtifactId=模板的artifactId-archetype -DarchetypeVersion=模板的version 
	或
	mvn archetype:generate -DarchetypeCatalog=local     

第二种（archetype:generate）：

maven archetype插件就是创建项目的脚手架，你可以通过命令行或者IDE集成简化项目创建的工作。例如：

- org.apache.maven.archetypes:maven-archetype-quickstart
- org.apache.maven.archetypes:maven-archetype-site
- org.apache.maven.archetypes:maven-archetype-webapp

以及spring或者第三方提供了一些archetype plugin。  

同时maven archetype插件也是一个简单的maven artifact，它包含了创建项目所需要的所有资源。 主要分为几类原型信息：

- archetype描述文件(src/main/resources/META-INF/maven/archetype.xml),这为archetype 1.0, 包含所有创建项目的文件信息和路径信息。在(archetype 2.0)[http://maven.apache.org/archetype/maven-archetype-plugin/]增加了更灵活的archetype-metadata.xml(src/main/resources/META-INF/maven/下), archetype元数据信息，并且完全支持1.0.
- 项目的原型文件(src/main/resources/archetype-resources/之下)，将会被archetype插件 copy到项目目录结构去。
- 创建项目的pom文件(src/main/resources/archetype-resources下)
- archetype pom文件，在archetype项目根目录下。

在archetype项目根目录下创建pom文件

	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <groupId>com.github.greengerong</groupId>
      <artifactId>component</artifactId>
      <version>0.0.1-SNAPSHOT</version>
      <packaging>jar</packaging>

      <name>component</name>
      <url>http://maven.apache.org</url>

      <properties>
          <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      </properties>

      <dependencies>
      </dependencies>
	</project>

创建archetype-metadata.xml,位于src/main/resources/META-INF/maven/目录下

	<?xml version="1.0" encoding="UTF-8"?>
	<archetype-descriptor name="app-server">
	    <fileSets>
	        <fileSet filtered="true" encoding="UTF-8">
	            <directory>src/main/java</directory>
	            <includes>
	                <include>**/*.**</include>
	            </includes>
	        </fileSet>
	        <fileSet filtered="true" encoding="UTF-8">
	            <directory>src/test/java</directory>
	            <includes>
	                <include>**/*.**</include>
	            </includes>
	        </fileSet>
	    </fileSets>
	</archetype-descriptor>

为将创建的项目增加pom.xml文件（目录src/main/resources/archetype-resources）。以${artifactId} / ${groupId} 变量作为占位符


	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <groupId>${groupId}</groupId>
      <artifactId>${artifactId}</artifactId>
      <version>${version}</version>
      <packaging>jar</packaging>

      <name>${artifactId}</name>

      <properties>
          <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      </properties>

      <dependencies>
          <dependency>
              <groupId>junit</groupId>
              <artifactId>junit</artifactId>
              <version>4.11</version>
              <scope>test</scope>
          </dependency>
      </dependencies>

      <build>
          <pluginManagement>
              <plugins>
                  <plugin>
                      <artifactId>maven-compiler-plugin</artifactId>
                      <configuration>
                          <source>1.6</source>
                          <target>1.6</target>
                      </configuration>
                  </plugin>
              </plugins>
          </pluginManagement>
      </build>
  	</project>


接下来在archetype项目下install plugin：

	mvn clean install.

更新你的本地仓库的索引

	mvn archetype:update-local-catalog

利用已有acrchetype plugin创建项目：

	mvn archetype:generate -DarchetypeCatalog=local
或：

	mvn archetype:generate -DgroupId=<my.groupid> -DartifactId=<my-artifactId> -DarchetypeGroupId=<archetype-groupId>  -DarchetypeArtifactId=<archetype-artifactId> -DarchetypeVersion=<archetype-version> -DinteractiveMode=false -DarchetypeCatalog=local 

如：

	mvn archetype:generate -DarchetypeGroupId=com.tzg.archetypes -DarchetypeArtifactId=tzg-archetype-java -DarchetypeVersion=1.0.0-SNAPSHOT -DgroupId=com.tzg -DartifactId=tzg-test -DinteractiveMode=false -DarchetypeCatalog=local 


选择指定类型的模板，Archetype插件为模板提供了分类如下：

- remote，远程Maven库中提供的模板。mvn archetype:generate默认使用该类模板
- local，本地Maven库中提供的模板。mvn archetype:generate默认使用该类模板，作为remote的补充。Maven初始为空，执行mvn install时会将当前项目加入local模板库
- internal，Apache Maven项目默认提供的模板。mvn archetype:generate -DarchetypeCatalog=internal使用该类模板
- file://...，给出本地计算机上的一个路径，在该路径下有一个archetype-catalog.xml文件（如果是其他文件名则必须给出），其中配置了模板
- http://...，给出网络上的一个路径，在该路径下有一个archetype-catalog.xml文件（如果是其他文件名则必须给出），其中配置了模板

例如，对于mvn archetype:generate -DarchetypeCatalog=http://cocoon.apache.org，命令默认从http://cocoon.apache.org/archetype-catalog.xml中选择可以模板。

Archetype插件2.4默认提供的internal类型的模板（共10个）

	mvn archetype:generate -DarchetypeCatalog=internal 
通过这些模板就足以创建满足常见基本需求的的Maven项目框架。例如

	mvn archetype:generate -DarchetypeArtifactId=maven-archetype-webapp
命令就可以创建一个Web应用。



在eclipse里面配置你刚才发布到私服的自定义archetype 

1.打开你的开发工具，eclipse

2.选择Window->Preferences->Maven->Archetypes

3.点击Add Remote Catalog，输入你的nexus私服中archetype的地址，我这里是 http://127.0.0.1:8081/nexus/content/groups/public/archetype-catalog.xml 输入Description

4.点击Ok，点击Apply

5.重新启动你的开发工具eclipse

使用自定义的archetype生成自定义的项目骨架 

1.选择New->Maven Project->Next

2.选择你刚才配置好的那个archetype

3.输入对应的groupId，artifactId，package，点击Finish就会生成工程