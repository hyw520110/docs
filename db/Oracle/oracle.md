在Linux下启动Oracle

	su – oracle
	sqlplus "/as sysdba"
	startup

停止数据库:
	
	shutdown immediate


检查Oracle DB监听器是否正常:

	 lsnrctl status

如果监听没有启动，启动监听：

	lsnrctl start

以sysdba登陆数据库：

	conn sys@orcl as sysdba

启动emctl：
	
	emctl start dbconsole

emctl是否启动查看地址：http://localhost.localdomain:1158/em 

Oracle启动&停止脚本：
	
vi /etc/oratab

	orcl:/opt/oracle/102:Y
	# Entries are of the form:
	#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:

vi /etc/init.d/oracle

	#!/bin/sh
	# chkconfig: 35 80 10
	# description: Oracle auto start-stop script.

	#
	# Set ORA_HOME to be equivalent to the $ORACLE_HOME
	# from which you wish to execute dbstart and dbshut;
	#
	# Set ORA_OWNER to the user id of the owner of the
	# Oracle database in ORA_HOME.
	ORA_HOME=/opt/oracle/102
	ORA_OWNER=oracle
	if [ ! -f $ORA_HOME/bin/dbstart ]
	then
	    echo "Oracle startup: cannot start"
	    exit
	fi
	case "$1" in
	'start')
	# Start the Oracle databases:
	echo "Starting Oracle Databases ... "
	echo "-------------------------------------------------" >> /var/log/oracle
	date +" %T %a %D : Starting Oracle Databases as part of system up." >> /var/log/oracle
	echo "-------------------------------------------------" >> /var/log/oracle
	su - $ORA_OWNER -c "$ORA_HOME/bin/dbstart" >>/var/log/oracle
	echo "Done"
	
	# Start the Listener:
	echo "Starting Oracle Listeners ... "
	echo "-------------------------------------------------" >> /var/log/oracle
	date +" %T %a %D : Starting Oracle Listeners as part of system up." >> /var/log/oracle
	echo "-------------------------------------------------" >> /var/log/oracle
	su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl start" >>/var/log/oracle
	echo "Done."
	echo "-------------------------------------------------" >> /var/log/oracle
	date +" %T %a %D : Finished." >> /var/log/oracle
	echo "-------------------------------------------------" >> /var/log/oracle
	touch /var/lock/subsys/oracle
	;;
	
	'stop')
	# Stop the Oracle Listener:
	echo "Stoping Oracle Listeners ... "
	echo "-------------------------------------------------" >> /var/log/oracle
	date +" %T %a %D : Stoping Oracle Listener as part of system down." >> /var/log/oracle
	echo "-------------------------------------------------" >> /var/log/oracle
	su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl stop" >>/var/log/oracle
	echo "Done."
	rm -f /var/lock/subsys/oracle
	
	# Stop the Oracle Database:
	echo "Stoping Oracle Databases ... "
	echo "-------------------------------------------------" >> /var/log/oracle
	date +" %T %a %D : Stoping Oracle Databases as part of system down." >> /var/log/oracle
	echo "-------------------------------------------------" >> /var/log/oracle
	su - $ORA_OWNER -c "$ORA_HOME/bin/dbshut" >>/var/log/oracle
	echo "Done."
	echo ""
	echo "-------------------------------------------------" >> /var/log/oracle
	date +" %T %a %D : Finished." >> /var/log/oracle
	echo "-------------------------------------------------" >> /var/log/oracle
	;;
	
	'restart')
	$0 stop
	$0 start
	;;
	esac

更改启动脚本权限：

	chmod 755 /etc/init.d/oracle

添加服务：

	chkconfig --level 35 oracle on

需要在关机或重启机器之前停止数据库，做一下操作

关机：

	ln -s /etc/init.d/oracle /etc/rc0.d/K01oracle   

重启 

	ln -s /etc/init.d/oracle /etc/rc6.d/K01oracle    

使用方法(开启|关闭|重启)
 
	service oracle start|top|restart         
	 