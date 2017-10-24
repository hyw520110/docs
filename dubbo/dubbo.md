架构

![](http://dubbo.io/dubbo-architecture.jpg-version=1&modificationDate=1330892870000.jpg)

节点角色说明：

- Provider: 暴露服务的服务提供方。
- Consumer: 调用远程服务的服务消费方。
- Registry: 服务注册与发现的注册中心。
- Monitor: 统计服务的调用次调和调用时间的监控中心。
- Container: 服务运行容器。


Dubbo缺省依赖以下三方库：
	
	[INFO] +- com.alibaba:dubbo:jar:2.1.2:compile
	[INFO] |  +- log4j:log4j:jar:1.2.16:compile 
	[INFO] |  +- org.javassist:javassist:jar:3.15.0-GA:compile
	[INFO] |  +- org.springframework:spring:jar:2.5.6.SEC03:compile
	[INFO] |  +- commons-logging:commons-logging:jar:1.1.1:compile
	[INFO] |  \- org.jboss.netty:netty:jar:3.2.5.Final:compile
这里所有依赖都是换照Dubbo缺省配置选的，这些缺省值是基于稳定性和性能考虑的。

- log4j.jar和commons-logging.jar日志输出包。
	- 可以直接去掉，dubbo本身的日志会自动切换为JDK的java.util.logging输出。
	- 但如果其它三方库比如spring.jar间接依赖commons-logging，则不能去掉。
- javassist.jar 字节码生成。
	- 如果<dubbo:provider proxy="jdk" />或<dubbo:consumer proxy="jdk" />，以及<dubbo:application compiler="jdk" />，则不需要。
- spring.jar 配置解析。
	- 如果用ServiceConfig和ReferenceConfig的API调用，则不需要。
- netty.jar 网络传输。
	- 如果<dubbo:protocol server="mina"/>或<dubbo:protocol server="grizzly"/>，则换成mina.jar或grizzly.jar。
	- 如果<protocol name="rmi"/>，则不需要。

可选依赖,以下依赖，在主动配置使用相应实现策略时用到，需自行加入依赖。
	
	mina: 1.1.7
	grizzly: 2.1.4
	httpclient: 4.1.2
	hessian_lite: 3.2.1-fixed
	xstream: 1.4.1
	fastjson: 1.1.8
	zookeeper: 3.3.3
	jedis: 2.0.0
	xmemcached: 1.3.6
	jfreechart: 1.0.13
	hessian: 4.0.7
	jetty: 6.1.26
	hibernate-validator: 4.2.0.Final
	zkclient: 0.1
	curator: 1.1.10
	cxf: 2.6.1
	thrift: 0.8.0
JEE:
	
	servlet: 2.5
	bsf: 3.1
	validation-api: 1.0.0.GA
	jcache: 0.4

配置：

- <dubbo:service/>服务配置，用于暴露一个服务，定义服务的元信息，一个服务可以用多个协议暴露，一个服务也可以注册到多个注册中心。
- <dubbo:reference/> 引用配置，用于创建一个远程服务代理，一个引用可以指向多个注册中心。
- <dubbo:protocol/> 协议配置，用于配置提供服务的协议信息，协议由提供方指定，消费方被动接受。
- <dubbo:application/> 应用配置，用于配置当前应用信息，不管该应用是提供者还是消费者。
- <dubbo:module/> 模块配置，用于配置当前模块信息，可选。
- <dubbo:registry/> 注册中心配置，用于配置连接注册中心相关信息。
- <dubbo:monitor/> 监控中心配置，用于配置连接监控中心相关信息，可选。
- <dubbo:provider/> 提供方的缺省值，当ProtocolConfig和ServiceConfig某属性没有配置时，采用此缺省值，可选。
- <dubbo:consumer/> 消费方缺省配置，当ReferenceConfig某属性没有配置时，采用此缺省值，可选。
- <dubbo:method/> 方法配置，用于ServiceConfig和ReferenceConfig指定方法级的配置信息。
- <dubbo:argument/> 用于指定方法参数配置。

配置重载：

- 配置的查找顺序（其它retries, loadbalance, actives等类似）：
	- 方法级优先，接口级次之，全局配置再次之。
	- 如果级别一样，则消费方优先，提供方次之。
- 其中，服务提供方配置，通过URL经由注册中心传递给消费方。
- 建议由服务提供方设置超时，因为一个方法需要执行多长时间，服务提供方更清楚，如果一个消费方同时引用多个服务，就不需要关心每个服务的超时设置。
- 理论上ReferenceConfig的非服务标识配置，在ConsumerConfig，ServiceConfig, ProviderConfig均可以缺省配置


属性配置

- 如果公共配置很简单，没有多注册中心，多协议等情况，或者想多个Spring容器想共享配置，可以使用dubbo.properties作为缺省配置。
- Dubbo将自动加载classpath根目录下的dubbo.properties，可以通过JVM启动参数：-Ddubbo.properties.file=xxx.properties 改变缺省配置位置。
- 如果classpath根目录下存在多个dubbo.properties，比如多个jar包中有dubbo.properties，Dubbo会任意加载，并打印Error日志，后续可能改为抛异常。

映射规则：

- 将XML配置的标签名，加属性名，用点分隔，多个属性拆成多行：
	- 比如：dubbo.application.name=foo等价于<dubbo:application name="foo" />
	- 比如：dubbo.registry.address=10.20.153.10:9090等价于<dubbo:registry address="10.20.153.10:9090" />
- 如果XML有多行同名标签配置，可用id号区分，如果没有id号将对所有同名标签生效：
	- 比如：dubbo.protocol.rmi.port=1234等价于<dubbo:protocol id="rmi" name="rmi" port="1099" /> (协议的id没配时，缺省使用协议名作为id)
	- 比如：dubbo.registry.china.address=10.20.153.10:9090等价于<dubbo:registry id="china" address="10.20.153.10:9090" />
	
覆盖策略：

- JVM启动-D参数优先，这样可以使用户在部署和启动时进行参数重写，比如在启动时需改变协议的端口。
- XML次之，如果在XML中有配置，则dubbo.properties中的相应配置项无效。
- Properties最后，相当于缺省值，只有XML没有配置时，dubbo.properties的相应配置项才会生效，通常用于共享公共配置，比如应用名。

注解配置：

服务提供方注解：
	
	import com.alibaba.dubbo.config.annotation.Service;
	 
	@Service(version="1.0.0")
	public class FooServiceImpl implements FooService {
	 
	    // ......
	 
	}
服务提供方配置：
	
	<!-- 公共信息，也可以用dubbo.properties配置 -->
	<dubbo:application name="annotation-provider" />
	<dubbo:registry address="127.0.0.1:4548" />
	 
	<!-- 扫描注解包路径，多个包用逗号分隔，不填pacakge表示扫描当前ApplicationContext中所有的类 -->
	<dubbo:annotation package="com.foo.bar.service" />
服务消费方注解：
	
	import com.alibaba.dubbo.config.annotation.Reference;
	import org.springframework.stereotype.Component;
	 
	@Component
	public class BarAction {
	 
	    @Reference(version="1.0.0")
	    private FooService fooService;
	 
	}
服务消费方配置：
	
	<!-- 公共信息，也可以用dubbo.properties配置 -->
	<dubbo:application name="annotation-consumer" />
	<dubbo:registry address="127.0.0.1:4548" />
	 
	<!-- 扫描注解包路径，多个包用逗号分隔，不填pacakge表示扫描当前ApplicationContext中所有的类 -->
	<dubbo:annotation package="com.foo.bar.action" />
也可以使用：(等价于前面的：<dubbo:annotation package="com.foo.bar.service" />)
	
	<dubbo:annotation />
	<context:component-scan base-package="com.foo.bar.service">
	    <context:include-filter type="annotation" expression="com.alibaba.dubbo.config.annotation.Service" />
	</context:component-scan>
Spring2.5及以后版本支持component-scan，如果用的是Spring2.0及以前版本，需配置：
	
	<!-- Spring2.0支持@Service注解配置，但不支持package属性自动加载bean的实例，需人工定义bean的实例。-->
	<dubbo:annotation />
	<bean id="barService" class="com.foo.BarServiceImpl" />



启动时检查

- Dubbo缺省会在启动时检查依赖的服务是否可用，不可用时会抛出异常，阻止Spring初始化完成，以便上线时，能及早发现问题，默认check=true。
- 如果你的Spring容器是懒加载的，或者通过API编程延迟引用服务，请关闭check，否则服务临时不可用时，会抛出异常，拿到null引用，如果check=false，总是会返回引用，当服务恢复时，能自动连上。

可以通过check="false"关闭检查，比如，测试时，有些服务不关心，或者出现了循环依赖，必须有一方先启动。

关闭某个服务的启动时检查：(没有提供者时报错)

	<dubbo:reference interface="com.foo.BarService" check="false" />
关闭所有服务的启动时检查：(没有提供者时报错)

	<dubbo:consumer check="false" />
关闭注册中心启动时检查：(注册订阅失败时报错)

	<dubbo:registry check="false" />
也可以用dubbo.properties配置：

	dubbo.properties
	dubbo.reference.com.foo.BarService.check=false
	dubbo.reference.check=false
	dubbo.consumer.check=false
	dubbo.registry.check=false
也可以用-D参数：
	
	java -Ddubbo.reference.com.foo.BarService.check=false
	java -Ddubbo.reference.check=false
	java -Ddubbo.consumer.check=false 
	java -Ddubbo.registry.check=false

注意区别

- dubbo.reference.check=false，强制改变所有reference的check值，就算配置中有声明，也会被覆盖。
- dubbo.consumer.check=false，是设置check的缺省值，如果配置中有显式的声明，如：<dubbo:reference check="true"/>，不会受影响。
- dubbo.registry.check=false，前面两个都是指订阅成功，但提供者列表是否为空是否报错，如果注册订阅失败时，也允许启动，需使用此选项，将在后台定时重试。

引用缺省是延迟初始化的，只有引用被注入到其它Bean，或被getBean()获取，才会初始化。
如果需要饥饿加载，即没有人引用也立即生成动态代理，可以配置：

	<dubbo:reference interface="com.foo.BarService" init="true" />

集群容错

-	在集群调用失败时，Dubbo提供了多种容错方案，缺省为failover重试。
![](http://dubbo.io/cluster.jpg-version=1&modificationDate=1321028038000.jpg)

各节点关系：

- 这里的Invoker是Provider的一个可调用Service的抽象，Invoker封装了Provider地址及Service接口信息。
- Directory代表多个Invoker，可以把它看成List<Invoker>，但与List不同的是，它的值可能是动态变化的，比如注册中心推送变更。
- Cluster将Directory中的多个Invoker伪装成一个Invoker，对上层透明，伪装过程包含了容错逻辑，调用失败后，重试另一个。
- Router负责从多个Invoker中按路由规则选出子集，比如读写分离，应用隔离等。
- LoadBalance负责从多个Invoker中选出具体的一个用于本次调用，选的过程包含了负载均衡算法，调用失败后，需要重选。

集群容错模式：

可以自行扩展集群容错策略

- Failover Cluster
	- 失败自动切换，当出现失败，重试其它服务器。(缺省)
	- 通常用于读操作，但重试会带来更长延迟。
	- 可通过retries="2"来设置重试次数(不含第一次)。
- Failfast Cluster
	- 快速失败，只发起一次调用，失败立即报错。
	- 通常用于非幂等性的写操作，比如新增记录。
- Failsafe Cluster
	- 失败安全，出现异常时，直接忽略。
	- 通常用于写入审计日志等操作。
- Failback Cluster
	- 失败自动恢复，后台记录失败请求，定时重发。
	- 通常用于消息通知操作。
- Forking Cluster
	- 并行调用多个服务器，只要一个成功即返回。
	- 通常用于实时性要求较高的读操作，但需要浪费更多服务资源。
	- 可通过forks="2"来设置最大并行数。
- Broadcast Cluster
	- 广播调用所有提供者，逐个调用，任意一台报错则报错。(2.1.0开始支持)
	- 通常用于通知所有提供者更新缓存或日志等本地资源信息。

重试次数配置如：(failover集群模式生效)

	<dubbo:service retries="2" />
或：

	<dubbo:reference retries="2" />
或：

	<dubbo:reference>
	    <dubbo:method name="findFoo" retries="2" />
	</dubbo:reference>
集群模式配置如：

	<dubbo:service cluster="failsafe" />
或：

	<dubbo:reference cluster="failsafe" />


**负载均衡**

可以自行扩展负载均衡策略 

- Random LoadBalance
	- 随机，按权重设置随机概率。
	- 在一个截面上碰撞的概率高，但调用量越大分布越均匀，而且按概率使用权重后也比较均匀，有利于动态调整提供者权重。
- RoundRobin LoadBalance
	- 轮循，按公约后的权重设置轮循比率。
	- 存在慢的提供者累积请求问题，比如：第二台机器很慢，但没挂，当请求调到第二台时就卡在那，久而久之，所有请求都卡在调到第二台上。
- LeastActive LoadBalance
	- 最少活跃调用数，相同活跃数的随机，活跃数指调用前后计数差。
	- 使慢的提供者收到更少请求，因为越慢的提供者的调用前后计数差会越大。
- ConsistentHash LoadBalance
	- 一致性Hash，相同参数的请求总是发到同一提供者。
	- 当某一台提供者挂时，原本发往该提供者的请求，基于虚拟节点，平摊到其它提供者，不会引起剧烈变动。
	- 算法参见：http://en.wikipedia.org/wiki/Consistent_hashing。
	- 缺省只对第一个参数Hash，如果要修改，请配置<dubbo:parameter key="hash.arguments" value="0,1" />
	- 缺省用160份虚拟节点，如果要修改，请配置<dubbo:parameter key="hash.nodes" value="320" />

配置如：

	<dubbo:service interface="..." loadbalance="roundrobin" />
或：

	<dubbo:reference interface="..." loadbalance="roundrobin" />
或：

	<dubbo:service interface="...">
	    <dubbo:method name="..." loadbalance="roundrobin"/>
	</dubbo:service>
或：

	<dubbo:reference interface="...">
	    <dubbo:method name="..." loadbalance="roundrobin"/>
	</dubbo:reference>


**线程模型**
![](http://dubbo.io/dubbo-protocol.jpg-version=1&modificationDate=1331068241000.jpg)

事件处理线程说明
- 如果事件处理的逻辑能迅速完成，并且不会发起新的IO请求，比如只是在内存中记个标识，则直接在IO线程上处理更快，因为减少了线程池调度。
- 但如果事件处理逻辑较慢，或者需要发起新的IO请求，比如需要查询数据库，则必须派发到线程池，否则IO线程阻塞，将导致不能接收其它请求。
- 如果用IO线程处理事件，又在事件处理过程中发起新的IO请求，比如在连接事件中发起登录请求，会报“可能引发死锁”异常，但不会真死锁。

- Dispatcher
	- all 所有消息都派发到线程池，包括请求，响应，连接事件，断开事件，心跳等。
	- direct 所有消息都不派发到线程池，全部在IO线程上直接执行。
	- message 只有请求响应消息派发到线程池，其它连接断开事件，心跳等消息，直接在IO线程上执行。
	- execution 只请求消息派发到线程池，不含响应，响应和其它连接断开事件，心跳等消息，直接在IO线程上执行。
	- connection 在IO线程上，将连接断开事件放入队列，有序逐个执行，其它消息派发到线程池。
- ThreadPool
	- fixed 固定大小线程池，启动时建立线程，不关闭，一直持有。(缺省)
	- cached 缓存线程池，空闲一分钟自动删除，需要时重建。
	- limited 可伸缩线程池，但池中的线程数只会增长不会收缩。(为避免收缩时突然来了大流量引起的性能问题)。

配置如：
	
	<dubbo:protocol name="dubbo" dispatcher="all" threadpool="fixed" threads="100" />

直连提供者

- 在开发及测试环境下，经常需要绕过注册中心，只测试指定服务提供者，这时候可能需要点对点直连，
点对点直联方式，将以服务接口为单位，忽略注册中心的提供者列表，
A接口配置点对点，不影响B接口从注册中心获取列表。
![](http://dubbo.io/dubbo-directly.jpg-version=1&modificationDate=1326853485000.jpg)


(1) 如果是线上需求需要点对点，可在<dubbo:reference>中配置url指向提供者，将绕过注册中心，多个地址用分号隔开，配置如下：(1.0.6及以上版本支持)

	<dubbo:reference id="xxxService" interface="com.alibaba.xxx.XxxService" url="dubbo://localhost:20890" />
(2) 在JVM启动参数中加入-D参数映射服务地址，如：
(key为服务名，value为服务提供者url，此配置优先级最高，1.0.15及以上版本支持)

	java -Dcom.alibaba.xxx.XxxService=dubbo://localhost:20890
- 为了避免复杂化线上环境，不要在线上使用这个功能，只应在测试阶段使用。

(3) 如果服务比较多，也可以用文件映射，如：
(用-Ddubbo.resolve.file指定映射文件路径，此配置优先级高于<dubbo:reference>中的配置，1.0.15及以上版本支持)
(2.0以上版本自动加载${user.home}/dubbo-resolve.properties文件，不需要配置)

	java -Ddubbo.resolve.file=xxx.properties
然后在映射文件xxx.properties中加入：
(key为服务名，value为服务提供者url)

	com.alibaba.xxx.XxxService=dubbo://localhost:20890 


**只订阅**

- 为方便开发测试，经常会在线下共用一个所有服务可用的注册中心，这时，如果一个正在开发中的服务提供者注册，可能会影响消费者不能正常运行。
- 可以让服务提供者开发方，只订阅服务(开发的服务可能依赖其它服务)，而不注册正在开发的服务，通过直连测试正在开发的服务。
![](http://dubbo.io/subscribe-only.jpg-version=1&modificationDate=1326468174000.jpg)

禁用注册配置：

	<dubbo:registry address="10.20.153.10:9090" register="false" />
或者：

	<dubbo:registry address="10.20.153.10:9090?register=false" />

**只注册**

- 如果有两个镜像环境，两个注册中心，有一个服务只在其中一个注册中心有部署，另一个注册中心还没来得及部署，而两个注册中心的其它应用都需要依赖此服务，所以需要将服务同时注册到两个注册中心，但却不能让此服务同时依赖两个注册中心的其它服务。
- 可以让服务提供者方，只注册服务到另一注册中心，而不从另一注册中心订阅服务。

禁用订阅配置：

	<dubbo:registry id="hzRegistry" address="10.20.153.10:9090" />
	<dubbo:registry id="qdRegistry" address="10.20.141.150:9090" subscribe="false" />
或者：

	<dubbo:registry id="hzRegistry" address="10.20.153.10:9090" />
	<dubbo:registry id="qdRegistry" address="10.20.141.150:9090?subscribe=false" />

静态服务

- 有时候希望人工管理服务提供者的上线和下线，此时需将注册中心标识为非动态管理模式。


	<dubbo:registry address="10.20.141.150:9090" dynamic="false" />
或者：

	<dubbo:registry address="10.20.141.150:9090?dynamic=false" />
服务提供者初次注册时为禁用状态，需人工启用，断线时，将不会被自动删除，需人工禁用。

如果是一个第三方独立提供者，比如memcached等，可以直接向注册中心写入提供者地址信息，消费者正常使用：
(通常由脚本监控中心页面等调用)

	RegistryFactory registryFactory = ExtensionLoader.getExtensionLoader(RegistryFactory.class).getAdaptiveExtension();
	Registry registry = registryFactory.getRegistry(URL.valueOf("zookeeper://10.20.153.10:2181"));
	registry.register(URL.valueOf("memcached://10.20.153.11/com.foo.BarService?category=providers&dynamic=false&application=foo"));

**多协议**

可以自行扩展协议，参见：[协议扩展](http://dubbo.io/Developer+Guide-zh.htm#DeveloperGuide-zh-%E5%8D%8F%E8%AE%AE%E6%89%A9%E5%B1%95)

(1) 不同服务不同协议
比如：不同服务在性能上适用不同协议进行传输，比如大数据用短连接协议，小数据大并发用长连接协议。

consumer.xml
	
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	    xsi:schemaLocation="http://www.springframework.org/schema/beanshttp://www.springframework.org/schema/beans/spring-beans.xsdhttp://code.alibabatech.com/schema/dubbohttp://code.alibabatech.com/schema/dubbo/dubbo.xsd">
	 
	    <dubbo:application name="world"  />
	    <dubbo:registry id="registry" address="10.20.141.150:9090" username="admin" password="hello1234" />
	 
	    <!-- 多协议配置 -->
	    <dubbo:protocol name="dubbo" port="20880" />
	    <dubbo:protocol name="rmi" port="1099" />
	 
	    <!-- 使用dubbo协议暴露服务 -->
	    <dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService" protocol="dubbo" />
	    <!-- 使用rmi协议暴露服务 -->
	    <dubbo:service interface="com.alibaba.hello.api.DemoService" version="1.0.0" ref="demoService" protocol="rmi" />
	 
	</beans>
(2) 多协议暴露服务
比如：需要与http客户端互操作

consumer.xml
	
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	    xsi:schemaLocation="http://www.springframework.org/schema/beanshttp://www.springframework.org/schema/beans/spring-beans.xsdhttp://code.alibabatech.com/schema/dubbohttp://code.alibabatech.com/schema/dubbo/dubbo.xsd">
	 
	    <dubbo:application name="world"  />
	    <dubbo:registry id="registry" address="10.20.141.150:9090" username="admin" password="hello1234" />
	 
	    <!-- 多协议配置 -->
	    <dubbo:protocol name="dubbo" port="20880" />
	    <dubbo:protocol name="hessian" port="8080" />
	 
	    <!-- 使用多个协议暴露服务 -->
	    <dubbo:service id="helloService" interface="com.alibaba.hello.api.HelloService" version="1.0.0" protocol="dubbo,hessian" />
	 
	</beans>

**多注册中心**

可以自行扩展注册中心，参见：注册中心扩展

(1) 多注册中心注册,比如：中文站有些服务来不及在青岛部署，只在杭州部署，而青岛的其它应用需要引用此服务，就可以将服务同时注册到两个注册中心。

consumer.xml

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	    xsi:schemaLocation="http://www.springframework.org/schema/beanshttp://www.springframework.org/schema/beans/spring-beans.xsdhttp://code.alibabatech.com/schema/dubbohttp://code.alibabatech.com/schema/dubbo/dubbo.xsd">
	 
	    <dubbo:application name="world"  />
	 
	    <!-- 多注册中心配置 -->
	    <dubbo:registry id="hangzhouRegistry" address="10.20.141.150:9090" />
	    <dubbo:registry id="qingdaoRegistry" address="10.20.141.151:9010" default="false" />
	 
	    <!-- 向多个注册中心注册 -->
	    <dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService" registry="hangzhouRegistry,qingdaoRegistry" />
	 
	</beans>
(2) 不同服务使用不同注册中心,比如：CRM有些服务是专门为国际站设计的，有些服务是专门为中文站设计的。

consumer.xml

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	    xsi:schemaLocation="http://www.springframework.org/schema/beanshttp://www.springframework.org/schema/beans/spring-beans.xsdhttp://code.alibabatech.com/schema/dubbohttp://code.alibabatech.com/schema/dubbo/dubbo.xsd">
	 
	    <dubbo:application name="world"  />
	 
	    <!-- 多注册中心配置 -->
	    <dubbo:registry id="chinaRegistry" address="10.20.141.150:9090" />
	    <dubbo:registry id="intlRegistry" address="10.20.154.177:9010" default="false" />
	 
	    <!-- 向中文站注册中心注册 -->
	    <dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService" registry="chinaRegistry" />
	 
	    <!-- 向国际站注册中心注册 -->
	    <dubbo:service interface="com.alibaba.hello.api.DemoService" version="1.0.0" ref="demoService" registry="intlRegistry" />
	 
	</beans>
(3) 多注册中心引用
比如：CRM需同时调用中文站和国际站的PC2服务，PC2在中文站和国际站均有部署，接口及版本号都一样，但连的数据库不一样。

consumer.xml

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	    xsi:schemaLocation="http://www.springframework.org/schema/beanshttp://www.springframework.org/schema/beans/spring-beans.xsdhttp://code.alibabatech.com/schema/dubbohttp://code.alibabatech.com/schema/dubbo/dubbo.xsd">
	 
	    <dubbo:application name="world"  />
	 
	    <!-- 多注册中心配置 -->
	    <dubbo:registry id="chinaRegistry" address="10.20.141.150:9090" />
	    <dubbo:registry id="intlRegistry" address="10.20.154.177:9010" default="false" />
	 
	    <!-- 引用中文站服务 -->
	    <dubbo:reference id="chinaHelloService" interface="com.alibaba.hello.api.HelloService" version="1.0.0" registry="chinaRegistry" />
	 
	    <!-- 引用国际站站服务 -->
	    <dubbo:reference id="intlHelloService" interface="com.alibaba.hello.api.HelloService" version="1.0.0" registry="intlRegistry" />
	 
	</beans>
如果只是测试环境临时需要连接两个不同注册中心，使用竖号分隔多个不同注册中心地址：

consumer.xml

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	    xsi:schemaLocation="http://www.springframework.org/schema/beanshttp://www.springframework.org/schema/beans/spring-beans.xsdhttp://code.alibabatech.com/schema/dubbohttp://code.alibabatech.com/schema/dubbo/dubbo.xsd">
	 
	    <dubbo:application name="world"  />
	 
	    <!-- 多注册中心配置，竖号分隔表示同时连接多个不同注册中心，同一注册中心的多个集群地址用逗号分隔 -->
	    <dubbo:registry address="10.20.141.150:9090|10.20.154.177:9010" />
	 
	    <!-- 引用服务 -->
	    <dubbo:reference id="helloService" interface="com.alibaba.hello.api.HelloService" version="1.0.0" />
	 
	</beans>

服务分组

- 当一个接口有多种实现时，可以用group区分。
	
	<dubbo:service group="feedback" interface="com.xxx.IndexService" />
	<dubbo:service group="member" interface="com.xxx.IndexService" />
	<dubbo:reference id="feedbackIndexService" group="feedback" interface="com.xxx.IndexService" />
	<dubbo:reference id="memberIndexService" group="member" interface="com.xxx.IndexService" />
任意组：(2.2.0以上版本支持，总是只调一个可用组的实现)

	<dubbo:reference id="barService" interface="com.foo.BarService" group="*" />

**多版本**

- 当一个接口实现，出现不兼容升级时，可以用版本号过渡，版本号不同的服务相互间不引用。
	- 在低压力时间段，先升级一半提供者为新版本
	- 再将所有消费者升级为新版本
	- 然后将剩下的一半提供者升级为新版本
	
	<dubbo:service interface="com.foo.BarService" version="1.0.0" />
	<dubbo:service interface="com.foo.BarService" version="2.0.0" />
	<dubbo:reference id="barService" interface="com.foo.BarService" version="1.0.0" />
	<dubbo:reference id="barService" interface="com.foo.BarService" version="2.0.0" />
不区分版本：(2.2.0以上版本支持)

	<dubbo:reference id="barService" interface="com.foo.BarService" version="*" />

**分组聚合**

- 按组合并返回结果，比如菜单服务，接口一样，但有多种实现，用group区分，现在消费方需从每种group中调用一次返回结果，合并结果返回，这样就可以实现聚合菜单项。
- 从2.1.0版本开始支持

代码参见：https://github.com/alibaba/dubbo/tree/master/dubbo-test/dubbo-test-examples/src/main/java/com/alibaba/dubbo/examples/merge

配置如：(搜索所有分组)

	<dubbo:reference interface="com.xxx.MenuService" group="*" merger="true" />
或：(合并指定分组)

	<dubbo:reference interface="com.xxx.MenuService" group="aaa,bbb" merger="true" />
或：(指定方法合并结果，其它未指定的方法，将只调用一个Group)

	<dubbo:reference interface="com.xxx.MenuService" group="*">
	    <dubbo:method name="getMenuItems" merger="true" />
	</dubbo:service>
或：(某个方法不合并结果，其它都合并结果)

	<dubbo:reference interface="com.xxx.MenuService" group="*" merger="true">
	    <dubbo:method name="getMenuItems" merger="false" />
	</dubbo:service>
或：(指定合并策略，缺省根据返回值类型自动匹配，如果同一类型有两个合并器时，需指定合并器的名称)
参见：[合并结果扩展]

	<dubbo:reference interface="com.xxx.MenuService" group="*">
	    <dubbo:method name="getMenuItems" merger="mymerge" />
	</dubbo:service>
或：(指定合并方法，将调用返回结果的指定方法进行合并，合并方法的参数类型必须是返回结果类型本身)

	<dubbo:reference interface="com.xxx.MenuService" group="*">
	    <dubbo:method name="getMenuItems" merger=".addAll" />
	</dubbo:service>

**参数验证**

- 参数验证功能是基于JSR303实现的，用户只需标识JSR303标准的验证Annotation，并通过声明filter来实现验证。
- 2.1.0以上版本支持

完整示例代码参见：https://github.com/alibaba/dubbo/tree/master/dubbo-test/dubbo-test-examples/src/main/java/com/alibaba/dubbo/examples/validation

验证方式可扩展，参见：[Validation扩展点](http://dubbo.io/Developer+Guide-zh.htm#DeveloperGuide-zh-Validation)

参数标注示例：
	
	import java.io.Serializable;
	import java.util.Date;
	 
	import javax.validation.constraints.Future;
	import javax.validation.constraints.Max;
	import javax.validation.constraints.Min;
	import javax.validation.constraints.NotNull;
	import javax.validation.constraints.Past;
	import javax.validation.constraints.Pattern;
	import javax.validation.constraints.Size;
	 
	public class ValidationParameter implements Serializable {
	     
	    private static final long serialVersionUID = 7158911668568000392L;
	 
	    @NotNull // 不允许为空
	    @Size(min = 1, max = 20) // 长度或大小范围
	    private String name;
	 
	    @NotNull(groups = ValidationService.Save.class) // 保存时不允许为空，更新时允许为空 ，表示不更新该字段
	    @Pattern(regexp = "^\\s*\\w+(?:\\.{0,1}[\\w-]+)*@[a-zA-Z0-9]+(?:[-.][a-zA-Z0-9]+)*\\.[a-zA-Z]+\\s*$")
	    private String email;
	 
	    @Min(18) // 最小值
	    @Max(100) // 最大值
	    private int age;
	 
	    @Past // 必须为一个过去的时间
	    private Date loginDate;
	 
	    @Future // 必须为一个未来的时间
	    private Date expiryDate;
	 
	    public String getName() {
	        return name;
	    }
	 
	    public void setName(String name) {
	        this.name = name;
	    }
	 
	    public String getEmail() {
	        return email;
	    }
	 
	    public void setEmail(String email) {
	        this.email = email;
	    }
	 
	    public int getAge() {
	        return age;
	    }
	 
	    public void setAge(int age) {
	        this.age = age;
	    }
	 
	    public Date getLoginDate() {
	        return loginDate;
	    }
	 
	    public void setLoginDate(Date loginDate) {
	        this.loginDate = loginDate;
	    }
	 
	    public Date getExpiryDate() {
	        return expiryDate;
	    }
	 
	    public void setExpiryDate(Date expiryDate) {
	        this.expiryDate = expiryDate;
	    }
	 
	}
分组验证示例：
	
	public interface ValidationService { // 缺省可按服务接口区分验证场景，如：@NotNull(groups = ValidationService.class)
	     
	    @interface Save{} // 与方法同名接口，首字母大写，用于区分验证场景，如：@NotNull(groups = ValidationService.Save.class)，可选
	    void save(ValidationParameter parameter);
	 
	    void update(ValidationParameter parameter);
	 
	}
关联验证示例：
	
	import javax.validation.GroupSequence;
	 
	public interface ValidationService {
	     
	    @GroupSequence(Update.class) // 同时验证Update组规则
	    @interface Save{}
	    void save(ValidationParameter parameter);
	 
	    @interface Update{} 
	    void update(ValidationParameter parameter);
	 
	}
参数验证示例：
	
	import javax.validation.constraints.Min;
	import javax.validation.constraints.NotNull;
	 
	public interface ValidationService {
	 
	    void save(@NotNull ValidationParameter parameter); // 验证参数不为空
	 
	    void delete(@Min(1) int id); // 直接对基本类型参数验证
	 
	}
在客户端验证参数：

	<dubbo:reference id="validationService" interface="com.alibaba.dubbo.examples.validation.api.ValidationService" validation="true" />
在服务器端验证参数：

	<dubbo:service interface="com.alibaba.dubbo.examples.validation.api.ValidationService" ref="validationService" validation="true" />
验证异常信息：
	
	import javax.validation.ConstraintViolationException;
	import javax.validation.ConstraintViolationException;
	 
	import org.springframework.context.support.ClassPathXmlApplicationContext;
	 
	import com.alibaba.dubbo.examples.validation.api.ValidationParameter;
	import com.alibaba.dubbo.examples.validation.api.ValidationService;
	import com.alibaba.dubbo.rpc.RpcException;
	 
	public class ValidationConsumer {
	     
	    public static void main(String[] args) throws Exception {
	        String config = ValidationConsumer.class.getPackage().getName().replace('.', '/') + "/validation-consumer.xml";
	        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(config);
	        context.start();
	        ValidationService validationService = (ValidationService)context.getBean("validationService");
	        // Error
	        try {
	            parameter = new ValidationParameter();
	            validationService.save(parameter);
	            System.out.println("Validation ERROR");
	        } catch (RpcException e) { // 抛出的是RpcException
	            ConstraintViolationException ve = (ConstraintViolationException) e.getCause(); // 里面嵌了一个ConstraintViolationException
	            Set<ConstraintViolation<?>> violations = ve.getConstraintViolations(); // 可以拿到一个验证错误详细信息的集合
	            System.out.println(violations);
	        }
	    }
	 
	}
需要加入依赖：
	
	<dependency>
	    <groupId>javax.validation</groupId>
	    <artifactId>validation-api</artifactId>
	    <version>1.0.0.GA</version>
	</dependency>
	<dependency>
	    <groupId>org.hibernate</groupId>
	    <artifactId>hibernate-validator</artifactId>
	    <version>4.2.0.Final</version>
	</dependency>

**结果缓存**

- 结果缓存，用于加速热门数据的访问速度，Dubbo提供声明式缓存，以减少用户加缓存的工作量。

示例代码：https://github.com/alibaba/dubbo/tree/master/dubbo-test/dubbo-test-examples/src/main/java/com/alibaba/dubbo/examples/cache

- lru 基于最近最少使用原则删除多余缓存，保持最热的数据被缓存。
- threadlocal 当前线程缓存，比如一个页面渲染，用到很多portal，每个portal都要去查用户信息，通过线程缓存，可以减少这种多余访问。
- jcache 与JSR107集成，可以桥接各种缓存实现。

缓存类型可扩展，参见：[CacheFactory扩展点](http://dubbo.io/Developer+Guide-zh.htm#DeveloperGuide-zh-CacheFactory)

配置如：

	<dubbo:reference interface="com.foo.BarService" cache="lru" />
或：
	
	<dubbo:reference interface="com.foo.BarService">
	    <dubbo:method name="findBar" cache="lru" />
	</dubbo:reference>

**泛化引用**

- 泛接口调用方式主要用于客户端没有API接口及模型类元的情况，参数及返回值中的所有POJO均用Map表示，通常用于框架集成，比如：实现一个通用的服务测试框架，可通过GenericService调用所有服务实现。


	<dubbo:reference id="barService" interface="com.foo.BarService" generic="true" />

	GenericService barService = (GenericService) applicationContext.getBean("barService");
	Object result = barService.$invoke("sayHello", new String[] { "java.lang.String" }, new Object[] { "World" });


	import com.alibaba.dubbo.rpc.service.GenericService; 
	... 
 
	// 引用远程服务 
	ReferenceConfig<GenericService> reference = new ReferenceConfig<GenericService>(); // 该实例很重量，里面封装了所有与注册中心及服务提供方连接，请缓存
	reference.setInterface("com.xxx.XxxService"); // 弱类型接口名 
	reference.setVersion("1.0.0"); 
	reference.setGeneric(true); // 声明为泛化接口 
	 
	GenericService genericService = reference.get(); // 用com.alibaba.dubbo.rpc.service.GenericService可以替代所有接口引用 
	 
	// 基本类型以及Date,List,Map等不需要转换，直接调用 
	Object result = genericService.$invoke("sayHello", new String[] {"java.lang.String"}, new Object[] {"world"}); 
	 
	// 用Map表示POJO参数，如果返回值为POJO也将自动转成Map 
	Map<String, Object> person = new HashMap<String, Object>(); 
	person.put("name", "xxx"); 
	person.put("password", "yyy"); 
	Object result = genericService.$invoke("findPerson", new String[]{"com.xxx.Person"}, new Object[]{person}); // 如果返回POJO将自动转成Map 
	 
	...
假设存在POJO如：
	
	package com.xxx; 
	public class PersonImpl implements Person { 
	private String name; 
	private String password; 
	public String getName() { 
	return name; 
	} 
	public void setName(String name) { 
	this.name = name; 
	} 
	public String getPassword() { 
	return password; 
	} 
	public void setPassword(String password) { 
	this.password= password; 
	} 
	}
则POJO数据：
	
	Person person = new PersonImpl(); 
	person.setName("xxx"); 
	person.setPassword("yyy");
可用下面Map表示：
	
	Map<String, Object> map = new HashMap<String, Object>(); 
	map.put("class", "com.xxx.PersonImpl"); // 注意：如果参数类型是接口，或者List等丢失泛型，可通过class属性指定类型。
	map.put("name", "xxx"); 
	map.put("password", "yyy");

**泛化实现**

- 泛接口实现方式主要用于服务器端没有API接口及模型类元的情况，参数及返回值中的所有POJO均用Map表示，通常用于框架集成，比如：实现一个通用的远程服务Mock框架，可通过实现GenericService接口处理所有服务请求。

	<bean id="genericService" class="com.foo.MyGenericService" />
	<dubbo:service interface="com.foo.BarService" ref="genericService" />

	package com.foo;
	public class MyGenericService implements GenericService {
	 
	    public Object $invoke(String methodName, String[] parameterTypes, Object[] args) throws GenericException {
	        if ("sayHello".equals(methodName)) {
	            return "Welcome " + args[0];
	        }
	    }
	 
	}
	
		... 
	GenericService xxxService = new XxxGenericService(); // 用com.alibaba.dubbo.rpc.service.GenericService可以替代所有接口实现 
	 
	ServiceConfig<GenericService> service = new ServiceConfig<GenericService>(); // 该实例很重量，里面封装了所有与注册中心及服务提供方连接，请缓存
	service.setInterface("com.xxx.XxxService"); // 弱类型接口名 
	service.setVersion("1.0.0"); 
	service.setRef(xxxService); // 指向一个通用服务实现 
	 
	// 暴露及注册服务 
	service.export();

**回声测试**

-	回声测试用于检测服务是否可用，回声测试按照正常请求流程执行，能够测试整个调用是否通畅，可用于监控。
-	所有服务自动实现EchoService接口，只需将任意服务引用强制转型为EchoService，即可使用。

	
		<dubbo:reference id="memberService" interface="com.xxx.MemberService" />

		MemberService memberService = ctx.getBean("memberService"); // 远程服务引用		 
		EchoService echoService = (EchoService) memberService; // 强制转型为EchoService		 
		String status = echoService.$echo("OK"); // 回声测试可用性		 
		assert(status.equals("OK"))

**上下文信息**

-上下文中存放的是当前调用过程中所需的环境信息。
- 所有配置信息都将转换为URL的参数，参见[《配置项一览表》](http://dubbo.io/User+Guide.htm#UserGuide-ConfigurationReference)中的“对应URL参数”一列。
- RpcContext是一个ThreadLocal的临时状态记录器，当接收到RPC请求，或发起RPC请求时，RpcContext的状态都会变化。
比如：A调B，B再调C，则B机器上，在B调C之前，RpcContext记录的是A调B的信息，在B调C之后，RpcContext记录的是B调C的信息。

(1) 服务消费方
	
	xxxService.xxx(); // 远程调用
	boolean isConsumerSide = RpcContext.getContext().isConsumerSide(); // 本端是否为消费端，这里会返回true
	String serverIP = RpcContext.getContext().getRemoteHost(); // 获取最后一次调用的提供方IP地址
	String application = RpcContext.getContext().getUrl().getParameter("application"); // 获取当前服务配置信息，所有配置信息都将转换为URL的参数
	// ...
	yyyService.yyy(); // 注意：每发起RPC调用，上下文状态会变化
	// ...
(2) 服务提供方
	
	public class XxxServiceImpl implements XxxService {
	 
	    public void xxx() { // 服务方法实现
	        boolean isProviderSide = RpcContext.getContext().isProviderSide(); // 本端是否为提供端，这里会返回true
	        String clientIP = RpcContext.getContext().getRemoteHost(); // 获取调用方IP地址
	        String application = RpcContext.getContext().getUrl().getParameter("application"); // 获取当前服务配置信息，所有配置信息都将转换为URL的参数
	        // ...
	        yyyService.yyy(); // 注意：每发起RPC调用，上下文状态会变化
	        boolean isProviderSide = RpcContext.getContext().isProviderSide(); // 此时本端变成消费端，这里会返回false
	        // ...
	    }
	 
	}

**隐式传参**

- 注：path,group,version,dubbo,token,timeout几个key有特殊处理，请使用其它key值。
- ![](http://dubbo.io/context.png-version=1&modificationDate=1320941797000.png)

(1) 服务消费方
	
	RpcContext.getContext().setAttachment("index", "1"); // 隐式传参，后面的远程调用都会隐式将这些参数发送到服务器端，类似cookie，用于框架集成，不建议常规业务使用
	xxxService.xxx(); // 远程调用
	// ...
	【注】 setAttachment设置的KV，在完成下面一次远程调用会被清空。即多次远程调用要多次设置。

(2) 服务提供方
	
	public class XxxServiceImpl implements XxxService {
	 
	    public void xxx() { // 服务方法实现
	        String index = RpcContext.getContext().getAttachment("index"); // 获取客户端隐式传入的参数，用于框架集成，不建议常规业务使用
	        // ...
	    }
	 
	}

**异步调用**

- 基于NIO的非阻塞实现并行调用，客户端不需要启动多线程即可完成并行调用多个远程服务，相对多线程开销较小。
- 2.0.6及其以上版本支持

![](http://dubbo.io/future.jpg-version=1&modificationDate=1320417743000.jpg)

配置声明：
	
	consumer.xml
	<dubbo:reference id="fooService" interface="com.alibaba.foo.FooService">
	      <dubbo:method name="findFoo" async="true" />
	</dubbo:reference>
	<dubbo:reference id="barService" interface="com.alibaba.bar.BarService">
	      <dubbo:method name="findBar" async="true" />
	</dubbo:reference>
调用代码：
	
	fooService.findFoo(fooId); // 此调用会立即返回null
	Future<Foo> fooFuture = RpcContext.getContext().getFuture(); // 拿到调用的Future引用，当结果返回后，会被通知和设置到此Future。
	 
	barService.findBar(barId); // 此调用会立即返回null
	Future<Bar> barFuture = RpcContext.getContext().getFuture(); // 拿到调用的Future引用，当结果返回后，会被通知和设置到此Future。
	 
	// 此时findFoo和findBar的请求同时在执行，客户端不需要启动多线程来支持并行，而是借助NIO的非阻塞完成。
	 
	Foo foo = fooFuture.get(); // 如果foo已返回，直接拿到返回值，否则线程wait住，等待foo返回后，线程会被notify唤醒。
	Bar bar = barFuture.get(); // 同理等待bar返回。
 
	// 如果foo需要5秒返回，bar需要6秒返回，实际只需等6秒，即可获取到foo和bar，进行接下来的处理。
你也可以设置是否等待消息发出：(异步总是不等待返回)

- sent="true" 等待消息发出，消息发送失败将抛出异常。
- sent="false" 不等待消息发出，将消息放入IO队列，即刻返回。
	
		<dubbo:method name="findFoo" async="true" sent="true" />

如果你只是想异步，完全忽略返回值，可以配置return="false"，以减少Future对象的创建和管理成本：

	<dubbo:method name="findFoo" async="true" return="false" />



基于TCPCopy的Dubbo服务引流工具-DubboCopy: http://www.cnblogs.com/yuyijq/p/4541660.html



https://github.com/alibaba/druid/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98