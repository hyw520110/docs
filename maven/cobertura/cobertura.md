maven的测试覆盖率插件集成，首先修改工程的pom.xml文件，添加cobertura-maven-plugin插件，如下：

	<project>  
	    ...  
	    <reporting>  
	        <plugins>  
	            <plugin>  
	                <groupId>org.codehaus.mojo</groupId>  
	                <artifactId>cobertura-maven-plugin</artifactId>  
	                <version>2.5.1</version>  
	            </plugin>  
	        </plugins>  
	    </reporting>  
	    ...  
	</project>  
首先运行“mvn cobertura:help”， 如果不能运行，请添加以下仓库

	<project>  
	    ...  
	    <pluginRepositories>  
	        <pluginRepository>  
	            <id>Codehaus repository</id>  
	            <url>http://repository.codehaus.org/</url>  
	        </pluginRepository>  
	    </pluginRepositories>  
	    ...  
	</project>  		
下面是cobertura插件的命令

	mvn cobertura:help          查看cobertura插件的帮助  
	mvn cobertura:clean         清空cobertura插件运行结果  
	mvn cobertura:check         运行cobertura的检查任务  
	mvn cobertura:cobertura     运行cobertura的检查任务并生成报表，报表生成在target/site/cobertura目录下  
	cobertura:dump-datafile     Cobertura Datafile Dump Mojo  
	mvn cobertura:instrument    Instrument the compiled classes  	