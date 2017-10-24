<p>&nbsp;&nbsp;&nbsp;&nbsp;前几天换工作，到新公司用到了阿里的Dubbo，花了两天的时间去学习，在网上找了很多教程，感觉都不是太详细，所以动手搭了下环境，写了这篇XX。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;有关dubbo的介绍就不多说了，请查阅官方文档：<a href="http://dubbo.io/" target="_blank">http://dubbo.io/</a> </p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<strong>本次环境搭建用到的工具</strong>：IDEA，maven，zookeeper<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<strong>首先介绍下项目的大概情况</strong>，首先是一个maven父工程DubboTest，下面有三个子工程DubboConsumer，DubboProvider，DubboCommon。<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DubboTest：总的项目，父工程，需要的依赖都在这里配置。<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DubboConsumer：非web项目，dubbo的消费方。<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DubboProvider：非web项目，dubbo服务提供方。<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DubboCommon：非web项目，打成Jar包，是DubboConsumer和DubboProvider共享的包，里面定义的是公用的接口。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;以上相关的概念就不多做解释了。<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<strong>项目代码：https://git.oschina.net/dachengxi/DubboTest.git</strong><br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<strong>搭建项目：</strong></p>
<p><strong>&nbsp;&nbsp;&nbsp;&nbsp;</strong>1.打开IDEA，New Project，选中Maven项目，不要勾选Create from archetype，点击next，填写GroupId等信息，然后再填写其他的相关信息，这个工程命名DubboTest，是父项目。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;2.进入项目之后，选择新建模块，分别简历三个子项目，过程与上面类似。分别命名为DubboConsumer，DubboProvider，DubboCommon。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;下面分别列出上面的pom文件<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;DubboTest pom.xml：</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;?xml&nbsp;version="1.0"&nbsp;encoding="UTF-8"?&gt;
&lt;project&nbsp;xmlns="http://maven.apache.org/POM/4.0.0"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xsi:schemaLocation="http://maven.apache.org/POM/4.0.0&nbsp;http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;cheng.xi&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;test.dubbo&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;packaging&gt;pom&lt;/packaging&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;1.0-SNAPSHOT&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;modules&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;module&gt;DubboConsumer&lt;/module&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;module&gt;DubboProvider&lt;/module&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;module&gt;DubboCommon&lt;/module&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/modules&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependencies&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;junit&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;junit&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;4.9&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;org.springframework&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;spring-core&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;4.1.3.RELEASE&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;org.springframework&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;spring-test&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;4.1.3.RELEASE&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;com.alibaba&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;dubbo&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;2.5.3&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;com.github.sgroschupf&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;zkclient&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;0.1&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependencies&gt;


&lt;/project&gt;</pre>
<p><br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;DubboConsumer pom.xml:</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;?xml&nbsp;version="1.0"&nbsp;encoding="UTF-8"?&gt;
&lt;project&nbsp;xmlns="http://maven.apache.org/POM/4.0.0"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xsi:schemaLocation="http://maven.apache.org/POM/4.0.0&nbsp;http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;parent&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;test.dubbo&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;cheng.xi&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;1.0-SNAPSHOT&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/parent&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;dubbo.consumer&lt;/artifactId&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependencies&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;cheng.xi&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;dubbo.common&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;1.0-SNAPSHOT&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependencies&gt;

&lt;/project&gt;</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;DubboProvider pom.xml:</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;?xml&nbsp;version="1.0"&nbsp;encoding="UTF-8"?&gt;
&lt;project&nbsp;xmlns="http://maven.apache.org/POM/4.0.0"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xsi:schemaLocation="http://maven.apache.org/POM/4.0.0&nbsp;http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;parent&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;test.dubbo&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;cheng.xi&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;1.0-SNAPSHOT&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/parent&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;dubbo.provider&lt;/artifactId&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependencies&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;cheng.xi&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;dubbo.common&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;1.0-SNAPSHOT&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/dependencies&gt;

&lt;/project&gt;</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;DubboCommon pom.xml:</p>
<pre class="brush:xml;toolbar:false">&lt;?xml&nbsp;version="1.0"&nbsp;encoding="UTF-8"?&gt;
&lt;project&nbsp;xmlns="http://maven.apache.org/POM/4.0.0"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xsi:schemaLocation="http://maven.apache.org/POM/4.0.0&nbsp;http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;parent&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;test.dubbo&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;cheng.xi&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;1.0-SNAPSHOT&lt;/version&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/parent&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;dubbo.common&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;packaging&gt;jar&lt;/packaging&gt;


&lt;/project&gt;</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;3.项目搭建完成之后，就可以开始写代码了。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;首先在DubboCommon项目中编写公共的接口，代码如下：<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;dubbo.common.hello.service;

/**
&nbsp;*&nbsp;Created&nbsp;by&nbsp;cheng.xi&nbsp;on&nbsp;15/4/12.
&nbsp;*/
public&nbsp;interface&nbsp;HelloService&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;sayHello();
}</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;接着写DubboProvider项目的接口实现，代码如下：<br></p>
<p><br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;dubbo.provider.hello.service.impl;

import&nbsp;dubbo.common.hello.service.HelloService;

/**
&nbsp;*&nbsp;Created&nbsp;by&nbsp;cmcc&nbsp;on&nbsp;15/4/12.
&nbsp;*/
public&nbsp;class&nbsp;HelloServiceImpl&nbsp;implements&nbsp;HelloService&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;sayHello()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("这里是Provider");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("HelloWorld&nbsp;Provider！");
&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<br></p>
<p>下面是DubboProvider中启动服务的代码：</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;dubbo.provider.hello.main;

import&nbsp;org.springframework.context.support.ClassPathXmlApplicationContext;

import&nbsp;java.io.IOException;

/**
&nbsp;*&nbsp;Created&nbsp;by&nbsp;cheng.xi&nbsp;on&nbsp;15/4/12.
&nbsp;*/
public&nbsp;class&nbsp;StartProvider&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args){
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ClassPathXmlApplicationContext&nbsp;context&nbsp;=&nbsp;new&nbsp;ClassPathXmlApplicationContext(new&nbsp;String[]{"dubbo-provider.xml"});
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;context.start();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("这里是dubbo-provider服务，按任意键退出");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.in.read();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;catch&nbsp;(IOException&nbsp;e)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;}

}</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;最后编写DubboConsumer下的调用代码，此处使用单元测试的方式调用，代码如下：<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;dubbo.consumer.hello.main;

import&nbsp;dubbo.common.hello.service.HelloService;
import&nbsp;org.junit.Test;
import&nbsp;org.junit.runner.RunWith;
import&nbsp;org.springframework.beans.factory.annotation.Autowired;
import&nbsp;org.springframework.test.context.ContextConfiguration;
import&nbsp;org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
&nbsp;*&nbsp;Created&nbsp;by&nbsp;cheng.xi&nbsp;on&nbsp;15/4/12.
&nbsp;*/
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("/dubbo-consumer.xml")
public&nbsp;class&nbsp;StartConsumer&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;@Autowired
&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;HelloService&nbsp;helloService;

&nbsp;&nbsp;&nbsp;&nbsp;@Test
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;test(){
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("dubbo-consumer服务启动，调用！");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;helloService.sayHello();

&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;4.上面代码已经写好，其中需要用的几个配置文件如下所示：<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;dubbo-consumer.xml:</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;?xml&nbsp;version="1.0"&nbsp;encoding="UTF-8"?&gt;
&lt;beans&nbsp;xmlns="http://www.springframework.org/schema/beans"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xsi:schemaLocation="http://www.springframework.org/schema/beans
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://www.springframework.org/schema/beans/spring-beans.xsd
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://code.alibabatech.com/schema/dubbo
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://code.alibabatech.com/schema/dubbo/dubbo.xsd"&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:application&nbsp;name="dubbo-consumer"&nbsp;/&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:registry&nbsp;&nbsp;protocol="zookeeper"&nbsp;address="127.0.0.1:2181"&nbsp;/&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:reference&nbsp;id="helloService"&nbsp;interface="dubbo.common.hello.service.HelloService"&nbsp;/&gt;

&lt;/beans&gt;</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;dubbo-provider.xml:</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;?xml&nbsp;version="1.0"&nbsp;encoding="UTF-8"?&gt;
&lt;beans&nbsp;xmlns="http://www.springframework.org/schema/beans"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;xsi:schemaLocation="http://www.springframework.org/schema/beans
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://www.springframework.org/schema/beans/spring-beans.xsd
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://code.alibabatech.com/schema/dubbo
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://code.alibabatech.com/schema/dubbo/dubbo.xsd"&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:application&nbsp;name="dubbo-provider"&nbsp;/&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:registry&nbsp;&nbsp;protocol="zookeeper"&nbsp;address="127.0.0.1:2181"&nbsp;/&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:protocol&nbsp;name="dubbo"&nbsp;port="20880"&nbsp;/&gt;

&nbsp;&nbsp;&nbsp;&nbsp;&lt;bean&nbsp;id="helloService"&nbsp;class="dubbo.provider.hello.service.impl.HelloServiceImpl"&nbsp;/&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;dubbo:service&nbsp;interface="dubbo.common.hello.service.HelloService"&nbsp;ref="helloService"&nbsp;/&gt;


&lt;/beans&gt;</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;5.至此项目中的代码编写已经完成，下一步是安装和启动zookeeper，有关过程请自己研究下。<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;6.启动好了zookeeper之后，首先运行DubboProvider中的那个main方法，然后运行DubboConsumer中的test()方法。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;这就ok了。</p>
<p>本文出自 “<a href="http://dachengxi.blog.51cto.com">大程熙的小角落</a>” 博客，请务必保留此出处<a href="http://dachengxi.blog.51cto.com/4658215/1631581">http://dachengxi.blog.51cto.com/4658215/1631581</a></p>
