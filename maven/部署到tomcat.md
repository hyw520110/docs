Tomcat 7

	发布URL = http://localhost:8080/manager/text
	命令 = mvn tomcat7:deploy

Tomcat 6

	发布 URL = http://localhost:8080/manager/
	命令 = mvn tomcat6:deploy

Tomcat 认证

添加具有角色管理器GUI和管理脚本的用户。

	%TOMCAT7_PATH%/conf/tomcat-users.xml
	
	<?xml version='1.0' encoding='utf-8'?>
	<tomcat-users>
	
		<role rolename="manager-gui"/>
		<role rolename="manager-script"/>
		<user username="admin" password="password" roles="manager-gui,manager-script" />
	
	</tomcat-users>

Maven 认证

添加在上面Maven 设置文件的 Tomcat 用户，是之后Maven使用此用户来登录Tomcat服务器。

	%MAVEN_PATH%/conf/settings.xml	
	<?xml version="1.0" encoding="UTF-8"?>
	<settings ...>
		<servers>
		   
			<server>
				<id>TomcatServer</id>
				<username>admin</username>
				<password>password</password>
			</server>
	
		</servers>
	</settings>

Tomcat7 Maven 插件

声明一个Maven的Tomcat插件。

	
	
		<plugin>
			<groupId>org.apache.tomcat.maven</groupId>
			<artifactId>tomcat7-maven-plugin</artifactId>
			<version>2.2</version>
			<configuration>
				<url>http://localhost:8080/manager/text</url>
				<server>TomcatServer</server>
				<path>/yiibaiWebApp</path>
			</configuration>
		</plugin>

怎么运行的？

在部署过程中，它告诉 Maven 通过部署 WAR 文件Tomcat服务器， “http://localhost:8080/manager/text” , 在路径“/yiibaiWebApp“上, 使用 “TomcatServer” (settings.xml) 用户名和密码来进行认证。

发布到Tomcat

以下的命令是用来操纵Tomcat WAR文件。

	mvn tomcat7:deploy 
	mvn tomcat7:undeploy 
	mvn tomcat7:redeploy