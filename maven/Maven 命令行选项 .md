Maven 命令行选项

说明：

1、使用-选项时，和后面的参数之间可以不要空格。而使用--选项时，和后面的参数之间必须有空格。如下面的例子：

	$ mvn help:describe -Dcmd=compiler:compile
	$ mvn install --define maven.test.skip=true

2、有些命令行选项是从Maven2.1才有的。

 

定义属性

-D，--define<arg> 定义系统属性,这是最常用到的定制Maven插件行为的选项。

 

获得帮助

-h，--help  显示帮助信息

如果你要寻找特定插件的可用目标和参数信息，请参考Maven Help 插件。

 

使用构建剖面（profile）

要从命令行激活一个或多个构建剖面，使用下面的选项：

-P，--activate-profiles<arg> 被激活的，用逗号分隔的剖面列表

 

显示版本信息

要显示Maven版本信息，在命令行里，使用下面选项中的一个。

-V，--show-version 显示版本信息后继续执行Maven其他目标。

-v，--version 显示版本信息。

这两个选项输出相同的版本信息，但-v选项在打印版本信息后会中断Maven处理。如果你想让Maven版本信息出现在构建输出的开始处，你应该使用-V选项。如果你正在持续构建环境里运行Maven，并且你需要知道特定构建使用了哪个Maven版本，-V选项就可以派上用场。

 

离线模式运行

-o，--offline 离线模式工作

该参数可以阻止通过网络更新插件或依赖。

使用定制的POM或定制的Settings文件
如果你不喜欢pom.xml文件名、用户相关的Maven配置文件的位置或者全局配置文件的位置，你可以通过下面的选项定制这些参数。
-f， --file <file> 强制使用备用的POM文件
-s，--settings <arg> 用户配置文件的备用路径
-gs， --global-settings <file> 全局配置文件的备用路径

 

加密密码

下面的命令允许你使用Maven加密密码，然后存储到Maven settings文件里：
-emp，--encrypt-master-password <password> 加密主安全密码
-ep，--encrypt-password <password>  加密服务器密码

 

失败处理

下面的选项控制，在多模块项目构建的中间阶段，Maven如何应对构建失败。
-fae， --fail-at-end 仅影响构建结果，允许不受影响的构建继续
-ff， --fail-fast 遇到构建失败就停下来
-fn，--fail-never 无论项目结果如何，构建从不失败
-fn 和 -fae选项对于使用持续集成工具（例如Hunson）的多模块构建非常有用。 -ff 选项对于运行交互构建的开发者非常有用，因为开发者在开发周期中想得到快速的反馈。

 

控制Maven的日志级别

如果你想控制Maven的日志级别，你可以使用下面三个命令行选项：
-e， --errors 产生执行错误相关消息
-X， --debug 产生执行调试信息
-q， --quiet 仅仅显示错误
只有出现错误或问题，-q 选项才打印一条消息。-X 选项会打印大量的调试日志消息，这个选项主要被Maven开发者和Maven插件开发者用来诊断在开发过程中碰到的Maven代码问题。如果你想诊断依赖或路径问题，-X 选项也非常有用。如果你是Maven开发者，或者你需要诊断Maven插件的一个错误，那么-e选项就会派上用场。如果你想报告Maven或Maven插件的一个未预料到的问题，你应该传递-X 和 -e命令行选项。

用批处理方式运行Maven

要在批处理模式下运行Maven，使用下面的选项：
-B， --batch-mode 在非交互（批处理）模式下运行
如果你需要在非交互、持续集成环境下运行Manve，必须要使用批处理模式。在非交互模式下运行，当Mven需要输入时，它不会停下来接受用户的输入，而是使用合理的默认值。

 

下载和验证依赖

下面的命令行选项会影响Maven和远程仓库的交互以及Maven如何验证下载的构件：
-C， --strict-checksums 如果校验码不匹配的话，构建失败
-c， --lax-checksums 如果校验码不匹配的话，产生告警
-U， --update-snapshots 在远程仓管更新发布版本或快照版本时，强制更新。
如果你关注安全，你就想带 -C选项运行Maven。Maven仓库为每个存储在仓库里的构件维护一个MD5 和 SHA1 校验码。如果构件的校验码不匹配下载的构件，Maven默认被配置成告警终端用户。如果传递-C 选项，当遇到带着错误校验码的构件，会引起Maven构建失败。如果你想确保Maven检查所有快照依赖的最新版本，-U选项非常有用。

 

控制插件更新

下面的命令行选项告诉Maven，它将如何从远程仓库更新（或不更新）Maven插件：
-npu，--no-plugin-updates 对任何相关的注册插件，不进行最新检查。使用该选项使Maven表现出稳定行为，该稳定行为基于本地仓库当前可用的所有插件版本。
-cpu， --check-plugin-updates 对任何相关的注册插件，强制进行最新检查。强制Maven检查Maven插件的最新发布版本，即使在你的项目POM里明确规定了Maven插件版本，还是会强制更新。
-up， --update-plugins cpu的同义词.

下面的命令行选项影响Maven从远处仓库下载插件的方式：

-npr， --no-plugin-registry 对插件版本不使用~/.m2/plugin-registry.xml  里的配置。
-npr 命令行选项告诉Maven不要参考插件注册表。欲了解关于插件注册表的更多信息

 
非递归构建

有时，你只想运行Maven构建，而不陷入项目子模块的构建。通过使用下面的命令行选项，你可以做到这点：
-N， --non-recursive 阻止Maven构建子模块。仅仅构建当前目录包含的项目。
运行该命令行选项使Maven只为当前目录下的项目执行生命周期中的目标或步骤