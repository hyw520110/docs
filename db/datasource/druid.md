配置_JNDI_Tomcat

com.alibaba.druid.pool.DruidDataSourceFactory实现了javax.naming.spi.ObjectFactory，可以作为JNDI数据源来配置。

Tomcat JNDI配置
在Tomcat使用JNDI配置DruidDataSource，在/conf/context.xml中，在中加入如下配置：

	 <Resource
      name="jdbc/druid-test"
      factory="com.alibaba.druid.pool.DruidDataSourceFactory"
      auth="Container"
      type="javax.sql.DataSource"

      maxActive="100"
      maxIdle="30"
      maxWait="10000"
      url="jdbc:derby:memory:tomcat-jndi;create=true"
      />

前半部分是基本信息，不能少的，后半部分是连接池的参数，具体参数看这里，大多数情况driverClassName可以自动识别的

添加Filter

	<Resource
      name="jdbc/druid-test"
      factory="com.alibaba.druid.pool.DruidDataSourceFactory"
      auth="Container"
      type="javax.sql.DataSource"

      maxActive="100"
      maxIdle="30"
      maxWait="10000"
      url="jdbc:derby:memory:tomcat-jndi;create=true"
      filters="stat"
      />