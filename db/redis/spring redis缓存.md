

缓存概念 

缓存简介

缓存，我的理解是：让数据更接近于使用者；工作机制是：先从缓存中读取数据，如果没有再从慢速设备上读取实际数据（数据也会存入缓存）；缓存什么：那些经常读取且不经常修改的数据/那些昂贵（CPU/IO）的且对于相同的请求有相同的计算结果的数据。如CPU—L1/L2—内存—磁盘就是一个典型的例子，CPU需要数据时先从 L1/L2中读取，如果没有到内存中找，如果还没有会到磁盘上找。还有如用过Maven的朋友都应该知道，我们找依赖的时候，先从本机仓库找，再从本地服务器仓库找，最后到远程仓库服务器找；还有如京东的物流为什么那么快？他们在各个地都有分仓库，如果该仓库有货物那么送货的速度是非常快的。
缓存命中率

即从缓存中读取数据的次数 与 总读取次数的比率，命中率越高越好：
命中率 = 从缓存中读取次数 / (总读取次数[从缓存中读取次数 + 从慢速设备上读取的次数])
Miss率 = 没有从缓存中读取的次数 / (总读取次数[从缓存中读取次数 + 从慢速设备上读取的次数])

这是一个非常重要的监控指标，如果做缓存一定要健康这个指标来看缓存是否工作良好；
缓存策略
Eviction policy

移除策略，即如果缓存满了，从缓存中移除数据的策略；常见的有LFU、LRU、FIFO：

    FIFO（First In First Out）：先进先出算法，即先放入缓存的先被移除；
    LRU（Least Recently Used）：最久未使用算法，使用时间距离现在最久的那个被移除；
    LFU（Least Frequently Used）：最近最少使用算法，一定时间段内使用次数（频率）最少的那个被移除；

TTL（Time To Live ）

存活期，即从缓存中创建时间点开始直到它到期的一个时间段（不管在这个时间段内有没有访问都将过期）
TTI（Time To Idle）

空闲期，即一个数据多久没被访问将从缓存中移除的时间。

到此，基本了解了缓存的知识，在Java中，我们一般对调用方法进行缓存控制，比如我调用”findUserById(Long id)”，那么我应该在调用这个方法之前先从缓存中查找有没有，如果没有再掉该方法如从数据库加载用户，然后添加到缓存中，下次调用时将会从缓存中获取到数据。

自Spring 3.1起，提供了类似于@Transactional注解事务的注解Cache支持，且提供了Cache抽象；在此之前一般通过AOP实现；使用Spring Cache的好处：

    提供基本的Cache抽象，方便切换各种底层Cache；
    通过注解Cache可以实现类似于事务一样，缓存逻辑透明的应用到我们的业务代码上，且只需要更少的代码就可以完成；
    提供事务回滚时也自动回滚缓存；
    支持比较复杂的缓存逻辑；

对于Spring Cache抽象，主要从以下几个方面学习：

    Cache API及默认提供的实现
    Cache注解
    实现复杂的Cache逻辑

Spring Cache简介 

Spring3.1开始引入了激动人心的基于注释（annotation）的缓存（cache）技术，它本质上不是一个具体的缓存实现方案（例如EHCache 或者 OSCache），而是一个对缓存使用的抽象，通过在既有代码中添加少量它定义的各种 annotation，即能够达到缓存方法的返回对象的效果。

Spring的缓存技术还具备相当的灵活性，不仅能够使用 SpEL（Spring Expression Language）来定义缓存的key和各种condition，还提供开箱即用的缓存临时存储方案，也支持和主流的专业缓存例如EHCache、 memcached集成。

其特点总结如下：

    通过少量的配置 annotation 注释即可使得既有代码支持缓存
    支持开箱即用 Out-Of-The-Box，即不用安装和部署额外第三方组件即可使用缓存
    支持 Spring Express Language，能使用对象的任何属性或者方法来定义缓存的 key 和 condition
    支持 AspectJ，并通过其实现任何方法的缓存支持
    支持自定义 key 和自定义缓存管理者，具有相当的灵活性和扩展性

Cache接口 默认实现

默认已经实现了几个常用的cache
位于spring-context-x.RELEASE.jar和spring-context-support-x.RELEASE.jar的cache目录下

    ConcurrentMapCache：基于java.util.concurrent.ConcurrentHashMap
    GuavaCache：基于Google的Guava工具
    EhCacheCache：基于Ehcache
    JCacheCache：基于javax.cache.Cache（不常用）

CacheManager用来管理多个cache 

默认实现,对应Cache接口的默认实现

    ConcurrentMapCacheManager / ConcurrentMapCacheFactoryBean
    GuavaCacheManager
    EhCacheCacheManager / EhCacheManagerFactoryBean
    JCacheCacheManager / JCacheManagerFactoryBean
CompositeCacheManager用于组合CacheManager，可以从多个CacheManager中轮询得到相应的Cache

	<bean id="cacheManager" class="org.springframework.cache.support.CompositeCacheManager">
	    <property name="cacheManagers">
	        <list>
	            <ref bean="concurrentMapCacheManager"/>
	            <ref bean="guavaCacheManager"/>
	        </list>
	    </property>
	    <!-- 都找不到时，不返回null，而是返回NOP的Cache -->
	    <property name="fallbackToNoOpCache" value="true"/>
	</bean>

事务

除GuavaCacheManager外，其他Cache都支持Spring事务，如果注解方法出现事务回滚，对应缓存操作也会回滚

缓存策略

都是Cache自行维护，Spring只提供对外抽象API 

Cache注解：
 
启用注解

	<cache:annotation-driven cache-manager="cacheManager"/>
- cache-manager属性用来指定当前所使用的CacheManager对应的bean的名称，默认是cacheManager，所以当我们的CacheManager的id为cacheManager时我们可以不指定该参数，否则就需要我们指定了。 
- mode属性，可选值有proxy和aspectj。默认是使用proxy。当mode为proxy时，只有缓存方法在外部被调用的时候Spring Cache才会发生作用，这也就意味着如果一个缓存方法在其声明对象内部被调用时Spring Cache是不会发生作用的。而mode为aspectj时就不会有这种问题。另外使用proxy时，只有public方法上的@Cacheable等标注才会起作用，如果需要非public方法上的方法也可以使用Spring Cache时把mode设置为aspectj。
- proxy-target-class属性，表示是否要代理class，默认为false。我们前面提到的@Cacheable、@cacheEvict等也可以标注在接口上，这对于基于接口的代理来说是没有什么问题的，但是需要注意的是当我们设置proxy-target-class为true或者mode为aspectj时，是直接基于class进行操作的，定义在接口上的@Cacheable等Cache注解不会被识别到，那对应的Spring Cache也不会起作用了。
- KeyGenerator属性

@Cacheable 用在查询方法上，先从缓存中读取，如果没有再调用方法获取数据，然后把数据添加到缓存中

- @Cacheable可以标记在一个方法上，也可以标记在一个类上。当标记在一个方法上时表示该方法是支持缓存的，当标记在一个类上时则表示该类所有的方法都是支持缓存的。对于一个支持缓存的方法，Spring会在其被调用后将其返回值缓存起来，以保证下次利用同样的参数来执行该方法时可以直接从缓存中获取结果，而不需要再次执行该方法。Spring在缓存方法的返回值时是以键值对进行缓存的，值就是方法的返回结果，至于键的话，Spring又支持两种策略，默认策略和自定义策略，这个稍后会进行说明。需要注意的是当一个支持缓存的方法在对象内部被调用时是不会触发缓存功能的。@Cacheable可以指定三个属性，value、key和condition
		
	-   value属性指定Cache名称，value属性是必须指定的，其表示当前方法的返回值是会被缓存在哪个Cache上的，对应Cache的名称。其可以是一个Cache也可以是多个Cache，当需要指定多个Cache时其是一个数组
			
			@Cacheable("cache1")//Cache是发生在cache1上的
		   	public User find(Integer id) {		
		      return null;		
		   	}		 
		
		   	@Cacheable({"cache1", "cache2"})//Cache是发生在cache1和cache2上的		
		   	public User find(Integer id) {		
		      return null;		
		   	}
	- 使用key属性自定义key，key属性是用来指定Spring缓存方法的返回结果时对应的key的。该属性支持SpringEL表达式。当我们没有指定该属性时，Spring将使用默认策略生成key。自定义策略是指我们可以通过Spring的EL表达式来指定我们的key。这里的EL表达式可以使用方法参数及它们对应的属性。使用方法参数时我们可以直接使用“#参数名”或者“#p参数index”。下面是几个使用参数作为key的示例
	
		 	@Cacheable(value="users", key="#id")		
		   	public User find(Integer id) {
			      return null;
		    }		 
		
		   	@Cacheable(value="users", key="#p0")		
		    public User find(Integer id) {		
		      return null;		
		    }
				
		    @Cacheable(value="users", key="#user.id")		
		    public User find(User user) {		
		      return null;		
		    }		 
		
		    @Cacheable(value="users", key="#p0.id")		
		    public User find(User user) {		
		      return null;		
		    }
	-   condition属性指定发生的条件：有时候可能并不希望缓存一个方法所有的返回结果。通过condition属性可以实现这一功能。condition属性默认为空，表示将缓存所有的调用情形。其值是通过SpringEL表达式来指定的，当为true时表示进行缓存处理；当为false时表示不进行缓存处理，即每次调用该方法时该方法都会执行一次。如下示例表示只有当user的id为偶数时才会进行缓存。

			   @Cacheable(value={"users"}, key="#user.id", condition="#user.id%2==0")		
			   public User find(User user) {		
			      System.out.println("find user by user " + user);		
			      return user;		
			   }
- 示例：

		@Cacheable(value = "kyAreaCache", key="targetClass + '.' + methodName + '.' + #areaId")
		public KyArea findById(String areaId) {
		    // 业务代码省略
		}
		
运行流程

    首先执行@CacheEvict（如果beforeInvocation=true且condition 通过），如果allEntries=true，则清空所有
    接着收集@Cacheable（如果condition 通过，且key对应的数据不在缓存），放入cachePutRequests（也就是说如果cachePutRequests为空，则数据在缓存中）
    如果cachePutRequests为空且没有@CachePut操作，那么将查找@Cacheable的缓存，否则result=缓存数据（也就是说只要当没有cache put请求时才会查找缓存）
    如果没有找到缓存，那么调用实际的API，把结果放入result
    如果有@CachePut操作(如果condition 通过)，那么放入cachePutRequests
    执行cachePutRequests，将数据写入缓存（unless为空或者unless解析结果为false）；
    执行@CacheEvict（如果beforeInvocation=false 且 condition 通过），如果allEntries=true，则清空所有

**SpEL上下文数据**

Spring默认使用的就是root对象的属性可以将“#root”省略,即#root.methodName等同于methodName

- methodName	：	root对象		被调用的方法名  		#root.methodName
- method:		root对象		被调用的方法    		#root.method.name
- target:		root对象		被调用的目标对象 		#root.target
- targetClass 	root对象		被调用的目标对象类		#root.targetClass
- args 			root对象	  	被调用的方法的参数列表	#root.args[0]
- caches			root对象	  	方法调用使用的缓存列表（如@Cacheable(value={“cache1”, “cache2”})），则有两个cache #root.caches[0].name
- argument name	执行上下文	被调用的方法的参数，如findById(Long id)，我们可以通过#id拿到参数 #user.id
- result			执行上下文	方法执行后的返回值（仅当方法执行之后的判断有效，如‘unless’，’cache evict’的beforeInvocation=false）		#result

**@CachePut 写数据**

- 在支持Spring Cache的环境下，对于使用@Cacheable标注的方法，Spring在每次执行前都会检查Cache中是否存在相同key的缓存元素，如果存在就不再执行该方法，而是直接从缓存中获取结果进行返回，否则才会执行并将返回结果存入指定的缓存中。@CachePut也可以声明一个方法支持缓存功能。与@Cacheable不同的是使用@CachePut标注的方法在执行前不会去检查缓存中是否存在之前执行过的结果，而是每次都会执行该方法，并将执行结果以键值对的形式存入指定的缓存中。
- @CachePut也可以标注在类上和方法上。使用@CachePut时我们可以指定的属性跟@Cacheable是一样的

		@CachePut("users")//每次都会执行方法，并将结果存入指定的缓存中
		public User find(Integer id) {	
	      return null;	
		}

		@CachePut(value = "addPotentialNoticeCache", key = "targetClass + '.' + #userCode")
		public List<PublicAutoAddPotentialJob.AutoAddPotentialNotice> put(int userCode, List<PublicAutoAddPotentialJob.AutoAddPotentialNotice> noticeList) {		
		    return noticeList;
		}

**@CacheEvict 失效数据** 

- @CacheEvict是用来标注在需要清除缓存元素的方法或类上的。当标记在一个类上时表示其中所有的方法的执行都会触发缓存的清除操作。@CacheEvict可以指定的属性有value、key、condition、allEntries和beforeInvocation。其中value、key和condition的语义与@Cacheable对应的属性类似。即value表示清除操作是发生在哪些Cache上的（对应Cache的名称）；key表示需要清除的是哪个key，如未指定则会使用默认策略生成的key；condition表示清除操作发生的条件。下面我们来介绍一下新出现的两个属性allEntries和beforeInvocation

		@CacheEvict(value = "addPotentialNoticeCache", key = "targetClass + '.' + #userCode")
		public void remove(int userCode) {
		    LOGGER.info("清除（{}）的公客自动添加潜在客的通知", userCode);
		}
	- allEntries属性：allEntries是boolean类型，表示是否需要清除缓存中的所有元素。默认为false，表示不需要。当指定了allEntries为true时，Spring Cache将忽略指定的key。有的时候我们需要Cache一下清除所有的元素，这比一个一个清除元素更有效率。

			   @CacheEvict(value="users", allEntries=true)	
			   public void delete(Integer id) {	
			      System.out.println("delete user by id: " + id);	
			   }
	- beforeInvocation属性：清除操作默认是在对应方法成功执行之后触发的，即方法如果因为抛出异常而未能成功返回时也不会触发清除操作。使用beforeInvocation可以改变触发清除操作的时间，当我们指定该属性值为true时，Spring会在调用该方法之前清除缓存中的指定元素。
			
			   @CacheEvict(value="users", beforeInvocation=true)
			   public void delete(Integer id) {
			      System.out.println("delete user by id: " + id);
			   }

**条件缓存**

主要是在注解内用condition和unless的表达式分别对参数和返回结果进行筛选后缓存

@Caching

-  @Caching注解可以让我们在一个方法或者类上同时指定多个Spring Cache相关的注解。其拥有三个属性：cacheable、put和evict，分别用于指定@Cacheable、@CachePut和@CacheEvict。

		@Caching(cacheable = @Cacheable("users"), evict = { @CacheEvict("cache2"),@CacheEvict(value = "cache3", allEntries = true) })
		public User find(Integer id) {	
			return null;	
		}
	
		@Caching(
			put = {
	                @CachePut(value = "user", key = "#user.id"),
	                @CachePut(value = "user", key = "#user.username"),
	                @CachePut(value = "user", key = "#user.email")
			}
		)
		public User save(User user) {
	
		}


自定义缓存注解

-  Spring允许我们在配置可缓存的方法时使用自定义的注解，前提是自定义的注解上必须使用对应的注解进行标注。如我们有如下这么一个使用@Cacheable进行标注的自定义注解。

		@Target({ElementType.TYPE, ElementType.METHOD})
		@Retention(RetentionPolicy.RUNTIME)	
		@Cacheable(value="users")	
		public @interface MyCacheable {
		
		}
		
		@MyCacheable
		public User findById(Integer id) {	
		}

- 把一些特殊场景的注解包装到一个独立的注解中，比如@Caching组合使用的注解
	
	@Caching(
	        put = {
	                @CachePut(value = "user", key = "#user.id"),
	                @CachePut(value = "user", key = "#user.username"),
	                @CachePut(value = "user", key = "#user.email")
	        }
	)

	@Target({ElementType.METHOD, ElementType.TYPE})
	@Retention(RetentionPolicy.RUNTIME)
	@Inherited
	public @interface UserSaveCache {
	
	}
	
	@UserSaveCache
	public User save(User user) {
	
	}

基于ConcurrentMapCache示例


自定义CacheManager

我需要使用有容量限制和缓存失效时间策略的Cache，默认的ConcurrentMapCacheManager没法满足
通过实现CacheManager接口定制出自己的CacheManager。
还是拷贝ConcurrentMapCacheManager，使用Guava的Cache做底层容器，因为Guava的Cache容器可以设置缓存策略

新增了exp、maximumSize两个策略变量
修改底层Cache容器的创建

下面只列出自定义的代码，其他的都是Spring的ConcurrentMapCacheManager的代码 

	import com.google.common.cache.CacheBuilder;
	import org.springframework.cache.Cache;
	import org.springframework.cache.CacheManager;
	import org.springframework.cache.concurrent.ConcurrentMapCache;
	
	import java.util.Arrays;
	import java.util.Collection;
	import java.util.Collections;
	import java.util.Map;
	import java.util.concurrent.ConcurrentHashMap;
	import java.util.concurrent.TimeUnit;
	
	/**
	 * 功能说明：自定义的ConcurrentMapCacheManager，新增超时时间和最大存储限制
	 * 作者：liuxing(2015-04-13 18:44)
	 */
	public class ConcurrentMapCacheManager implements CacheManager {
	
	    /**
	     * 过期时间，秒（自定义）
	     */
	    private long exp = 1800;
	    /**
	     * 最大存储数量 （自定义）
	     */
	    private long maximumSize = 1000;
	
	    public void setExp(long exp) {
	        this.exp = exp;
	    }
	
	    public void setMaximumSize(long maximumSize) {
	        this.maximumSize = maximumSize;
	    }
	
	    /**
	     * 创建一个缓存容器，这个方法改写为使用Guava的Cache
	     * @param name
	     * @return
	     */
	    protected Cache createConcurrentMapCache(String name) {
	        return new ConcurrentMapCache(name, CacheBuilder.newBuilder().expireAfterWrite(this.exp, TimeUnit.SECONDS)
	                                                                     .maximumSize(this.maximumSize)
	                                                                     .build()
	                                                                     .asMap(), isAllowNullValues());
	    }
	}

xml风格初始化

	<!-- 启用缓存注解功能，这个是必须的，否则注解不会生效，指定一个默认的Manager，否则需要在注解使用时指定Manager -->
	<cache:annotation-driven cache-manager="memoryCacheManager"/>
	
	<!-- 本地内存缓存 -->
	<bean id="memoryCacheManager" class="com.dooioo.ky.cache.ConcurrentMapCacheManager" p:maximumSize="2000" p:exp="1800">
	    <property name="cacheNames">
	        <list>
	            <value>kyMemoryCache</value>
	        </list>
	    </property>
	</bean>

使用
	
	@Cacheable(value = "kyMemoryCache", key="targetClass + '.' + methodName")
	public Map<String, String> queryMobiles(){
	    // 业务代码省略
	}

使用Memcached

一般常用的缓存当属memcached了，这个就需要自己实现CacheManager和Cache
注意我实现的Cache里面有做一些定制化操作，比如对key的处理 

创建MemcachedCache
	
	import com.dooioo.common.jstl.DyFunctions;
	import com.dooioo.commons.Strings;
	import com.google.common.base.Joiner;
	import net.rubyeye.xmemcached.MemcachedClient;
	import net.rubyeye.xmemcached.exception.MemcachedException;
	import org.slf4j.Logger;
	import org.slf4j.LoggerFactory;
	import org.springframework.cache.Cache;
	import org.springframework.cache.support.SimpleValueWrapper;
	
	import java.util.concurrent.TimeoutException;
	
	/**
	 * 功能说明：自定义spring的cache的实现，参考cache包实现
	 * 作者：liuxing(2015-04-12 13:57)
	 */
	public class MemcachedCache implements Cache {
	
	    private static final Logger LOGGER = LoggerFactory.getLogger(MemcachedCache.class);
	
	    /**
	     * 缓存的别名
	     */
	    private String name;
	    /**
	     * memcached客户端
	     */
	    private MemcachedClient client;
	    /**
	     * 缓存过期时间，默认是1小时
	     * 自定义的属性
	     */
	    private int exp = 3600;
	    /**
	     * 是否对key进行base64加密
	     */
	    private boolean base64Key = false;
	    /**
	     * 前缀名
	     */
	    private String prefix;
	
	    @Override
	    public String getName() {
	        return name;
	    }
	
	    @Override
	    public Object getNativeCache() {
	        return this.client;
	    }
	
	    @Override
	    public ValueWrapper get(Object key) {
	        Object object = null;
	        try {
	            object = this.client.get(handleKey(objectToString(key)));
	        } catch (TimeoutException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (InterruptedException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (MemcachedException e) {
	            LOGGER.error(e.getMessage(), e);
	        }
	
	        return (object != null ? new SimpleValueWrapper(object) : null);
	    }
	
	    @Override
	    public <T> T get(Object key, Class<T> type) {
	        try {
	            Object object = this.client.get(handleKey(objectToString(key)));
	            return (T) object;
	        } catch (TimeoutException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (InterruptedException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (MemcachedException e) {
	            LOGGER.error(e.getMessage(), e);
	        }
	
	        return null;
	    }
	
	    @Override
	    public void put(Object key, Object value) {
	        if (value == null) {
	//            this.evict(key);
	            return;
	        }
	
	        try {
	            this.client.set(handleKey(objectToString(key)), exp, value);
	        } catch (TimeoutException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (InterruptedException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (MemcachedException e) {
	            LOGGER.error(e.getMessage(), e);
	        }
	    }
	
	    @Override
	    public ValueWrapper putIfAbsent(Object key, Object value) {
	        this.put(key, value);
	        return this.get(key);
	    }
	
	    @Override
	    public void evict(Object key) {
	        try {
	            this.client.delete(handleKey(objectToString(key)));
	        } catch (TimeoutException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (InterruptedException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (MemcachedException e) {
	            LOGGER.error(e.getMessage(), e);
	        }
	    }
	
	    @Override
	    public void clear() {
	        try {
	            this.client.flushAll();
	        } catch (TimeoutException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (InterruptedException e) {
	            LOGGER.error(e.getMessage(), e);
	        } catch (MemcachedException e) {
	            LOGGER.error(e.getMessage(), e);
	        }
	    }
	
	    public void setName(String name) {
	        this.name = name;
	    }
	
	    public MemcachedClient getClient() {
	        return client;
	    }
	
	    public void setClient(MemcachedClient client) {
	        this.client = client;
	    }
	
	    public void setExp(int exp) {
	        this.exp = exp;
	    }
	
	    public void setBase64Key(boolean base64Key) {
	        this.base64Key = base64Key;
	    }
	
	    public void setPrefix(String prefix) {
	        this.prefix = prefix;
	    }
	
	    /**
	     * 处理key
	     * @param key
	     * @return
	     */
	    private String handleKey(final String key) {
	        if (base64Key) {
	            return Joiner.on(EMPTY_SEPARATOR).skipNulls().join(this.prefix, DyFunctions.base64Encode(key));
	        }
	
	        return Joiner.on(EMPTY_SEPARATOR).skipNulls().join(this.prefix, key);
	    }
	
	    /**
	     * 转换key，去掉空格
	     * @param object
	     * @return
	     */
	    private String objectToString(Object object) {
	        if (object == null) {
	            return null;
	        } else if (object instanceof String) {
	            return Strings.replace((String) object, " ", "_");
	        } else {
	            return object.toString();
	        }
	    }
	
	    private static final String EMPTY_SEPARATOR = "";
	
	}

创建MemcachedCacheManager

继承AbstractCacheManager 
	
	import org.springframework.cache.Cache;
	import org.springframework.cache.support.AbstractCacheManager;
	
	import java.util.Collection;
	
	/**
	 * 功能说明：memcachedCacheManager
	 * 作者：liuxing(2015-04-12 15:13)
	 */
	public class MemcachedCacheManager extends AbstractCacheManager {
	
	    private Collection<Cache> caches;
	
	    @Override
	    protected Collection<? extends Cache> loadCaches() {
	        return this.caches;
	    }
	
	    public void setCaches(Collection<Cache> caches) {
	        this.caches = caches;
	    }
	
	    public Cache getCache(String name) {
	        return super.getCache(name);
	    }
	
	}	

初始化
	
	<!-- 启用缓存注解功能，这个是必须的，否则注解不会生效，指定一个默认的Manager，否则需要在注解使用时指定Manager -->
	<cache:annotation-driven cache-manager="cacheManager"/>
	
	<!-- memcached缓存管理器 -->
	<bean id="cacheManager" class="com.dooioo.ky.cache.MemcachedCacheManager">
	    <property name="caches">
	        <set>
	            <bean class="com.dooioo.ky.cache.MemcachedCache" p:client-ref="ky.memcachedClient" p:name="kyAreaCache" p:exp="86400"/>
	            <bean class="com.dooioo.ky.cache.MemcachedCache" p:client-ref="ky.memcachedClient" p:name="kyOrganizationCache" p:exp="3600"/>
	        </set>
	    </property>
	</bean>

使用
	
	@Cacheable(value = "kyAreaCache", key="targetClass + '.' + methodName + '.' + #areaId")
	public KyArea findById(String areaId) {
	    // 业务代码省略
	}


参考：http://jinnianshilongnian.iteye.com/blog/2001040
