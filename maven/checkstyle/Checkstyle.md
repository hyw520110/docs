首先是介绍Checkstyle插件的集成，要添加Checkstyle插件，需要修改工程的pom.xml文件，添加以下插件配置

	<project>  
    ...  
	    <properties>  
	        <checkstyle.config.location>config/maven_checks.xml</checkstyle.config.location>  
	    </properties>  
	    ...  
	    <reporting>  
	        <plugins>  
	            <plugin>  
	                <groupId>org.apache.maven.plugins</groupId>  
	                <artifactId>maven-checkstyle-plugin</artifactId>  
	                <version>2.9.1</version>  
	            </plugin>  
	  
	            <plugin>  
	                <groupId>org.apache.maven.plugins</groupId>  
	                <artifactId>maven-jxr-plugin</artifactId>  
	                <version>2.3</version>  
	            </plugin>  
	        </plugins>  
	    </reporting>  
	    ...  
	</project>  
其中可以修改使用的检查规则文件路径，插件默认提供了四个规则文件可以直接使用，不要手动下载，它们分别是：

	config/sun_checks.xml - Sun Microsystems Definition (default).  
	config/maven_checks.xml - Maven Development Definitions.  
	config/turbine_checks.xml - Turbine Development Definitions.  
	config/avalon_checks.xml - Avalon Development Definitions.
  
也可以使用自定义的规则文件，比如自定义一个文件名为my_checks.xml，并放在工程根目录下，然后修改配置为如下：

	<properties>  
	    <checkstyle.config.location>my_checks.xml</checkstyle.config.location>  
	</properties>  
另外，这里也添加了jxr插件，用来在生成的结果中可以通过link找到代码对应的行。
 checkstyle插件的可执行任务如下：

	mvn checkstyle:help           查看checkstyle-plugin的帮助：   
	mvn checkstyle:check          检查工程是否满足checkstyle的检查，如果没有满足，检查会失败，可以通过target/site/checkstyle.html查看。  
	mvn checkstyle:checkstyle     检查工程是否满足checkstyle的检查，如果没有满足，检查不会失败，可以通过target/site/checkstyle.html查看。  
	mvn checkstyle:checkstyle-aggregate     检查工程是否满足checkstyle的检查，如果没有满足，检查不会失败，可以通过target/site/checkstyle.html查看。  

在运行完“mvn checkstyle:checkstyle”命令后，可以运行"mvn jxr:jxr"来使checkstyle的结果可以直接跳转到代码行位置。