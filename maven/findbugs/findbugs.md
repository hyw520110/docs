首先修改工程的pom.xml文件，添加findbugs-maven-plugin插件，如下：

	<build>  
       <plugins>  
           <plugin>  
              <groupId>org.codehaus.mojo</groupId>  
              <artifactId>findbugs-maven-plugin</artifactId>  
              <version>2.5.1</version>  
              <configuration>  
                  <!-- <configLocation>${basedir}/springside-findbugs.xml</configLocation> -->  
                  <threshold>High</threshold>  
                  <effort>Default</effort>  
                  <findbugsXmlOutput>true</findbugsXmlOutput>  
                   <!-- findbugs xml输出路径-->         <findbugsXmlOutputDirectory>target/site</findbugsXmlOutputDirectory>  
              </configuration>  
           </plugin>  
       </plugins>  
    </build>  
运行findbugs任务前请先运行“mvn package”编译打包工程

	mvn findbugs:help       查看findbugs插件的帮助  
	mvn findbugs:check      检查代码是否通过findbugs检查，如果没有通过检查，检查会失败，但检查不会生成结果报表  
	mvn findbugs:findbugs   检查代码是否通过findbugs检查，如果没有通过检查，检查不会失败，会生成结果报表保存在target/findbugsXml.xml文件中  
	mvn findbugs:gui        检查代码并启动gui界面来查看结果  
可以添加findbugs检查规则文件来使用用户自己的规则

	<configuration>  
	  <excludeFilterFile>findbugs-exclude.xml</excludeFilterFile>  
	  <includeFilterFile>findbugs-include.xml</includeFilterFile>  
	</configuration>  

具体fndbugs插件的配置项可以参考

http://mojo.codehaus.org/findbugs-maven-plugin/findbugs-mojo.html