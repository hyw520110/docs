# GitLab基本介绍

GitLab是利用Ruby on Rails一个开源的版本管理系统，实现一个自托管的Git项目仓库，可通过Web界面进行访问公开的或者私人项目。
与Github类似，GitLab能够浏览源代码，管理缺陷和注释。可以管理团队对仓库的访问，它非常易于浏览提交过的版本并提供一个文件历史库。团队成员可以利用内置的简单聊天程序(Wall)进行交流。

它还提供一个代码片段收集功能可以轻松实现代码复用，便于日后有需要的时候进行查找。
本篇教程将教你如何安装部署及使用GitLab。
# Git的家族成员
Git：是一种版本控制系统，是一个命令，是一种工具。
Gitlib：是用于实现Git功能的开发库。
Github：是一个基于Git实现的在线代码托管仓库，包含一个网站界面，向互联网开放。
GitLab：是一个基于Git实现的在线代码仓库托管软件，你可以用gitlab自己搭建一个类似于Github一样的系统，一般用于在企业、学校等内部网络搭建git私服。
# Gitlab的服务构成
Nginx：静态web服务器。
gitlab-shell：用于处理Git命令和修改authorized keys列表。
gitlab-workhorse: 轻量级的反向代理服务器。
logrotate：日志文件管理工具。
postgresql：数据库。
redis：缓存数据库。
sidekiq：用于在后台执行队列任务（异步执行）。
unicorn：An HTTP server for Rack applications，GitLab Rails应用是托管在这个服务器上面的。

# GitLab Shell
GitLab Shell有两个作用：为GitLab处理Git命令、修改authorized keys列表。
当通过SSH访问GitLab Server时，GitLab Shell会：
限制执行预定义好的Git命令（git push, git pull, git annex）
调用GitLab Rails API 检查权限
执行pre-receive钩子（在GitLab企业版中叫做Git钩子）
执行你请求的动作 处理GitLab的post-receive动作
处理自定义的post-receive动作
当通过http(s)访问GitLab Server时，工作流程取决于你是从Git仓库拉取(pull)代码还是向git仓库推送(push)代码。
如果你是从Git仓库拉取(pull)代码，GitLab Rails应用会全权负责处理用户鉴权和执行Git命令的工作；
如果你是向Git仓库推送(push)代码，GitLab Rails应用既不会进行用户鉴权也不会执行Git命令，它会把以下工作交由GitLab Shell进行处理：
调用GitLab Rails API 检查权限
执行pre-receive钩子（在GitLab企业版中叫做Git钩子）
执行你请求的动作
处理GitLab的post-receive动作
处理自定义的post-receive动作
# GitLab Workhorse
GitLab Workhorse是一个敏捷的反向代理。它会处理一些大的HTTP请求，比如文件上传、文件下载、Git push/pull和Git包下载。其它请求会反向代理到GitLab Rails应用，即反向代理给后端的unicorn。

依赖组件：ruby 1.9.3+，MySQL，git，redis， Sidekiq。 
最低配置CPU 1G，RAM 1G+swap可以支持100用户。

##安装
官方有[安装包](https://about.gitlab.com/downloads/)与脚本下载，[官方安装指南](https://about.gitlab.com/installation/)。同样GITHUB上有个社区非官方的[安装指南](https://github.com/gitlabhq/gitlab-recipes)。

但这儿里推荐bitnami下载打包安装版本 https://bitnami.com/stack/gitlab/installer ,省去很多时间。他们也提供相关[WIKI](http://wiki.bitnami.com/Applications/BitNami_GitLab)

centos7安装指南：https://www.gitlab.com.cn/installation/#centos-7

	
	sudo yum install curl policycoreutils openssh-server openssh-clients 
	sudo systemctl enable sshd
	sudo systemctl start sshd
	sudo yum install postfix
	sudo systemctl enable postfix
	sudo systemctl start postfix
	sudo firewall-cmd --permanent --add-service=http
	sudo systemctl reload firewalld
	
添加 GitLab 镜像源并安装
	
	curl -sS http://packages.gitlab.com.cn/install/gitlab-ce/script.rpm.sh | sudo bash
	sudo yum install gitlab-ce

或者如果你不太习惯使用命令管道的方式安装镜像仓库，你可以在这里找到[完整的安装脚本](https://packages.gitlab.com.cn/install/gitlab-ce) 或者[选择系统对应的安装包](https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/)使用下面的命令手动安装。

	curl -LJO https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-8.0.0-ce.0.el7.x86_64.rpm
	rpm -i gitlab-ce-8.0.0-ce.0.el7.x86_64.rpm

修改gitlab配置文件指定服务器ip和自定义端口：

	vim  /etc/gitlab/gitlab.rb
	external_url 'http://dev.git.com'
修改端口

	unicorn['port'] = 8090 	

配置并启动 GitLab

	sudo gitlab-ctl reconfigure
	gitlab-ctl restart

启动报错：

	Error executing action `create` on resource 'user[GitLab user and group]'
修改用户

	vim  /etc/gitlab/gitlab.rb
	user['username'] = "gitlab"
	user['group'] = "gitlab"

	sudo gitlab-ctl reconfigure

GitLab常用命令

	sudo gitlab-ctl start    # 启动所有 gitlab 组件；
	sudo gitlab-ctl stop        # 停止所有 gitlab 组件；
	sudo gitlab-ctl restart        # 重启所有 gitlab 组件；
	sudo gitlab-ctl status        # 查看服务状态；
	sudo gitlab-ctl reconfigure        # 启动服务；
	sudo vim /etc/gitlab/gitlab.rb        # 修改默认的配置文件；
	gitlab-rake gitlab:check SANITIZE=true --trace    # 检查gitlab；
	gitlab-ctl tail unicorn       # 查看日志；
	gitlab-ctl tail nginx 
	cd /var/log/gitlab/nginx


打开浏览器登录GitLab

	Username: root 
	Password: 5iveL!fe
首次登录会强制用户修改密码。密码修改成功后，输入新密码进行登录。

忘记密码

	gitlab-rails console production
	u = User.where(id:1).first
	u.password = 'asdf123456'
	u.password_confirmation = 'asdf123456'
	u.save!
	
	sudo gitlab-ctl restart



打开浏览器报502错误

- 端口占用
- 检查系统的虚拟内存是否随机启动了，如果系统无虚拟内存，则增加虚拟内存，再重新启动系统。


安装中文语言包（汉化）

查看当前版本：

	cat /opt/gitlab/embedded/service/gitlab-rails/VERSION

克隆 GitLab.com 仓库

	
	git clone https://gitlab.com/xhang/gitlab.git

	git  branch -r 
	git diff origin/9-5-stable origin/9-5-zh > /tmp/9.5.diff
	# 停止 gitlab
	sudo gitlab-ctl stop
	# 应用汉化补丁
	cd /opt/gitlab/embedded/service/gitlab-rails
	git apply /tmp/9.5.diff  
	# 启动gitlab
	sudo gitlab-ctl start 

# 配置过程

修改GitLab配置文件，停用GitLab内置Nginx

	vim  /etc/gitlab/gitlab.rb
	nginx['enable'] = false
使用系统已经安装的Nginx给gitlab-workhorse作反向代理


修改GitLab邮件服务配置，使用腾讯企业邮箱的SMTP服务器

	vim  /etc/gitlab/gitlab.rb
	gitlab_rails['smtp_enable'] = true
	gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
	gitlab_rails['smtp_port'] = 25
	gitlab_rails['smtp_user_name'] = "heyiwu@ycd360.com"
	gitlab_rails['smtp_password'] = "Hyw2017"
	gitlab_rails['smtp_domain'] = "smtp.qq.com"
	gitlab_rails['smtp_authentication'] = "plain"
	gitlab_rails['smtp_enable_starttls_auto'] = true

设置gitlab发信功能

发信系统用的默认的postfix，smtp是默认开启的，两个都启用了，两个都不会工作。

我这里设置关闭smtp，开启postfix

关闭smtp方法：vim /etc/gitlab/gitlab.rb

找到#gitlab_rails['smtp_enable'] = true 改为 gitlab_rails['smtp_enable'] = false

修改后执行gitlab-ctl reconfigure

另一种是关闭postfix，设置开启smtp，相关教程请参考官网https://doc.gitlab.cc/omnibus/settings/smtp.html


一般是权限问题，解决方法：chmod -R 755 /var/log/gitlab

如果还不行，请检查你的内存，安装使用GitLab需要至少4GB可用内存(RAM + Swap)! 由于操作系统和其他正在运行的应用也会使用内存, 所以安装GitLab前一定要注意当前服务器至少有4GB的可用内存. 少于4GB内存会出现各种诡异的问题, 而且在使用过程中也经常会出现500错误.


##管理

管理员帐号登录后，有一个管理区，如下图：
![](http://images.cnitblog.com/blog/15172/201408/231230580342064.jpg)

在这里可以管理用户，项目，组，日志，消息，Hooks，后台job。 界面清晰，功能明确，在这儿不再详细描述。

##使用
1 . 服务端 启动Gitlab

	./ctlscript.sh start

也可以查看GUI管理控制台 

	./manager-linux-x64.run

上面列出各个组件状态。

2 . 创建与Git项目初始化工作

我们的Apache webserver 之间安装于81端口，从客户端访问：

	http://192.168.169.129:81/

登录后，可创建三种级别的Projects:

![](http://images.cnitblog.com/blog/15172/201408/231231068314084.jpg)

增加项目参加成员：
![](http://images.cnitblog.com/blog/15172/201408/231231098937087.jpg)


对新建Git项目，初始化，第一个commit:

Git global setup（Git全局设置）:

	git config --global user.name "testman"
	git config --global user.email "testman@hotmail.com"

Create Repository（创建仓库）

	mkdir common-util
	cd common-util
	git init
	touch README
	git add README
	git commit -m 'first commit'
	git remote add origin git@127.0.0.1:devteam/common-util.git
	git push -u origin master
对于已存在Git项目：

	cd existing_git_repo 
	git remote add origin git@127.0.0.1:devteam/common-util.git 
	git push -u origin master

 

进入本地git shell, 生成自己的ssh-key, 联系三个回车

	ssh-keygen -t rsa

 
登录Gitlab http://10.1.98.251 ，在profile中填写自己ssh-key,记事本打开C:\Users\Administrator\.ssh \id_rsa.pub内容,copy到下面Key

![](http://images.cnitblog.com/blog/15172/201408/231231120185703.jpg)

使用相关用户名登录，可以看到Dashborad:

![](http://images.cnitblog.com/blog/15172/201408/231231151439491.png)

 显示项目动态：

![](http://images.cnitblog.com/blog/15172/201408/231231182992523.jpg)

项目Commit明细：

![](http://images.cnitblog.com/blog/15172/201408/231231216281138.jpg)

GitLab CI
使用gitlab管理员账户登录后：

![](http://images.cnitblog.com/blog/15172/201408/231231330651333.jpg)
提供了基于持续集成的功能，有于[API的访问](https://gitlab.com/gitlab-org/gitlab-ci/blob/master/doc/api/api.md)。