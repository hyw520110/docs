##创建版本库: 	

	git init
##添加受控文件到暂存区:	

	git add readme.md
##提交文件到版本库: 		

	git commit -m "添加说明"

##查看状态:		

	git status 
##查看修改内容:	

	git diff readme.md
查看工作区和版本库最新版本的区别：

	git diff HEAD -- readme.md 
##查看历史记录:	
	git log 
命令显示从近到远的提交日志

##查看精简历史记录：

	git log --pretty=oneline

##强制更新
	
	git fetch --all
	git reset --hard origin/master
	git fetch 
git fetch 只是下载远程的库的内容，不做任何的合并 
git reset 把HEAD指向刚刚下载的最新的版本

也可以使用

	git checkout . #本地所有修改的。没有的提交的，都返回到原来的状态
	git stash #把所有没有提交的修改暂存到stash里面。可用git stash pop回复。
	git reset --hard HASH #返回到某个节点，不保留修改。
	git reset --soft HASH #返回到某个节点。保留修改
	
	git clean -df #返回到某个节点
	git clean 参数
	    -n 显示 将要 删除的 文件 和  目录
	    -f 删除 文件
	    -df 删除 文件 和 目录

	git checkout . && git clean -xdf

##版本回退

在Git中，用HEAD表示当前版本,上一个版本就是HEAD^，上上一个版本就是HEAD^^，往上N个版本写N个^比较容易数不过来，所以写成HEAD~N,

恢复至上个版本：

	git reset --hard HEAD^
查看历史记录：

	git log
发现最新版本的日志已经看不到了，如果想撤销恢复操作，获取最新版本

如命令窗口没有关闭，可以找到最新版本的版本号(比如3628164)，则可以根据历史记录显示的版本号(十六进制的加密字符串)恢复到指定版本：

	git rest --hard 3628164
版本号没必要写全，前几位就可以了，Git会自动去找


如命令窗口已经关闭，找不到最新版本的版本号,Git提供了一个命令git reflog用来记录你的每一次命令：

	git reflog

##撤销修改

###丢弃工作区的修改:

	git checkout -- readme.md

命令git checkout -- readme.txt意思就是，把readme.txt文件在工作区的修改全部撤销，这里有两种情况：

一种是readme.txt自修改后还没有被放到暂存区，现在，撤销修改就回到和版本库一模一样的状态；

一种是readme.txt已经添加到暂存区后，又作了修改，现在，撤销修改就回到添加到暂存区后的状态。

总之，就是让这个文件回到最近一次git commit或git add时的状态。

git checkout -- file命令中的--很重要，没有--，就变成了“切换到另一个分支”的命令

###撤销暂存区的修改

对于已经添加到暂存区(git add),还没有提交(git commit),用命令git reset HEAD file可以把暂存区的修改撤销掉（unstage），重新放回工作区：

	git reset HEAD readme.md

git reset命令既可以回退版本，也可以把暂存区的修改回退到工作区。当我们用HEAD时，表示最新的版本。

##删除文件

工作区文件删除

	rm readme.md
如确定删除版本库文件执行：

	git rm readme.md
如是误操作删除了工作区文件，把误删除的文件恢复到最新版本:

	git checkout -- readme.md

删除远程保留本地

	git rm --cached *.log
	git rm --cached -r dirname
	
	git commit -m "del"
	git push

##创建SSH Key

	ssh-keygen -t rsa -C "youremail@example.com"
把邮件地址换成你自己的邮件地址，然后一路回车，使用默认值即可，执行成功后,可以在用户主目录里找到.ssh目录，里面有id_rsa和id_rsa.pub两个文件，这两个就是SSH Key的秘钥对，id_rsa是私钥，不能泄露出去，id_rsa.pub是公钥

把公钥文件的内容，配置到github或gitblit用户key相关的配置中

##添加远程仓库

在github或gitblit上创建新的空仓库,可以从这个仓库克隆出新的仓库，也可以把一个已有的本地仓库与之关联，然后，把本地仓库的内容推送到GitHub仓库



将本地仓库添加到远程仓库:

github

	git remote add origin git@github.com:heyw/test.git

gitblit 

	git remote add origin ssh://heyw@localhost:29418/test.git

origin是远程仓库的默认名，当然也可以改成别的

把本地库的所有内容推送到远程库上：

	git push -u origin master

把本地库的内容推送到远程，用git push命令，实际上是把当前分支master推送到远程。

由于远程库是空的，我们第一次推送master分支时，加上了-u参数，Git不但会把本地的master分支内容推送的远程新的master分支，还会把本地的master分支和远程的master分支关联起来，在以后的推送或者拉取时就可以简化命令。

推送成功后，可以在GitHub或gitblit页面中看到远程库的内容已经和本地一模一样 

只要本地仓库作了提交，就可以通过命令：

	git push origin master

把本地master分支的最新修改推送至远程仓库

SSH警告

当你第一次使用Git的clone或者push命令连接GitHub时，会得到一个警告：

	The authenticity of host 'github.com (xx.xx.xx.xx)' can't be established.
	RSA key fingerprint is xx.xx.xx.xx.xx.
	Are you sure you want to continue connecting (yes/no)?
这是因为Git使用SSH连接，而SSH连接在第一次验证GitHub服务器的Key时，需要你确认远程仓库的Key的指纹信息是否真的来自远程仓库服务器，输入yes回车即可。

Git会输出一个警告，告诉你已经把Key添加到本机的一个信任列表里了：

	Warning: Permanently added 'github.com' (RSA) to the list of known hosts.
这个警告只会出现一次，后面的操作就不会有任何警告了。

##从远程仓库克隆

github:

	git clone git@github.com:heyw/test.git	

gitblit:

	git clone ssh://admin@localhost:29418/test.git

##分支管理
	
查看分支：git branch

创建分支：git branch <name>

切换分支：git checkout <name>

创建+切换分支：git checkout -b <name>

合并某分支到当前分支：git merge <name>

合并指定分支(dev)的指定版本到指定分支（master）

	git checkout dev
	git log 
	拷贝id
	git checkout master
	git cherry-pick $id

	或
	拿最后一个版本
	git cherry-pick dev
	拿最新的三个版本
	git cherry-pick dev~3..dev

删除分支：git branch -d <name>

###创建与合并分支

每次提交，Git都把它们串成一条时间线，这条时间线就是一个分支。截止到目前，只有一条时间线，在Git里，这个分支叫主分支，即master分支。HEAD严格来说不是指向提交，而是指向master，master才是指向提交的，所以，HEAD指向的就是当前分支。

一开始的时候，master分支是一条线，Git用master指向最新的提交，再用HEAD指向master，就能确定当前分支，以及当前分支的提交点：
![](http://www.liaoxuefeng.com/files/attachments/0013849087937492135fbf4bbd24dfcbc18349a8a59d36d000/0)

每次提交，master分支都会向前移动一步，这样，随着你不断提交，master分支的线也越来越长：

当我们创建新的分支，例如dev时，Git新建了一个指针叫dev，指向master相同的提交，再把HEAD指向dev，就表示当前分支在dev上：

![](http://www.liaoxuefeng.com/files/attachments/001384908811773187a597e2d844eefb11f5cf5d56135ca000/0)



你看，Git创建一个分支很快，因为除了增加一个dev指针，改改HEAD的指向，工作区的文件都没有任何变化！

不过，从现在开始，对工作区的修改和提交就是针对dev分支了，比如新提交一次后，dev指针往前移动一步，而master指针不变：

![](http://www.liaoxuefeng.com/files/attachments/0013849088235627813efe7649b4f008900e5365bb72323000/0)

假如我们在dev上的工作完成了，就可以把dev合并到master上。Git怎么合并呢？最简单的方法，就是直接把master指向dev的当前提交，就完成了合并：

![](http://www.liaoxuefeng.com/files/attachments/00138490883510324231a837e5d4aee844d3e4692ba50f5000/0)

所以Git合并分支也很快！就改改指针，工作区内容也不变！

合并完分支后，甚至可以删除dev分支。删除dev分支就是把dev指针给删掉，删掉后，我们就剩下了一条master分支：

![](http://www.liaoxuefeng.com/files/attachments/001384908867187c83ca970bf0f46efa19badad99c40235000/0)

首先，我们创建dev分支，然后切换到dev分支：

	git checkout -b dev
git checkout命令加上-b参数表示创建并切换，相当于以下两条命令：

	git branch dev
	git checkout dev
然后，用git branch命令查看当前分支：

	git branch

git branch命令会列出所有分支，当前分支前面会标一个*号。

然后，我们就可以在dev分支上正常提交，比如对readme.txt做个修改,然后提交：

	git add readme.txt
	git commit -m "branch test"
现在，dev分支的工作完成，我们就可以切换回master分支：

	git checkout master
切换回master分支后，再查看一个readme.txt文件，刚才添加的内容不见了！因为那个提交是在dev分支上，而master分支此刻的提交点并没有变：

![](http://www.liaoxuefeng.com/files/attachments/001384908892295909f96758654469cad60dc50edfa9abd000/0)

现在，我们把dev分支的工作成果合并到master分支上：

	git merge dev

git merge命令用于合并指定分支到当前分支。合并后，再查看readme.txt的内容，就可以看到，和dev分支的最新提交是完全一样的。

注意到上面的Fast-forward信息，Git告诉我们，这次合并是“快进模式”，也就是直接把master指向dev的当前提交，所以合并速度非常快。

当然，也不是每次合并都能Fast-forward，我们后面会讲其他方式的合并。

合并完成后，就可以放心地删除dev分支了：

	git branch -d dev
删除后，查看branch，就只剩下master分支了：

	git branch 


##解决冲突

准备新的dev分支，继续我们的新分支开发：

	git checkout -b dev

修改readme.txt最后一行.在dev分支上提交：

	git add readme.txt 
	git commit -m "AND simple"
切换到master分支：

	git checkout master

Git还会自动提示我们当前master分支比远程的master分支要超前1个提交。

在master分支上把readme.txt文件的最后一行进行修改提交：

	git add readme.txt 
	git commit -m "& simple"

现在，master分支和feature1分支各自都分别有新的提交，变成了这样：

![](http://www.liaoxuefeng.com/files/attachments/001384909115478645b93e2b5ae4dc78da049a0d1704a41000/0)

这种情况下，Git无法执行“快速合并”，只能试图把各自的修改合并起来，但这种合并就可能会有冲突，我们试试看：

	git merge dev

Git告诉我们，readme.txt文件存在冲突，必须手动解决冲突后再提交。git status也可以告诉我们冲突的文件：

	 git status

我们可以直接查看readme.txt的内容,Git用<<<<<<<，=======，>>>>>>>标记出不同分支的内容，解决冲突后提交：

	 git add readme.txt 
	 git commit -m "conflict fixed"

现在，master分支和feature1分支变成了下图所示：

![](http://www.liaoxuefeng.com/files/attachments/00138490913052149c4b2cd9702422aa387ac024943921b000/0)

用带参数的git log也可以看到分支的合并情况：

	git log --graph --pretty=oneline --abbrev-commit
最后，删除dev分支：

	git branch -d dev

##分支管理策略

通常，合并分支时，如果可能，Git会用Fast forward模式，但这种模式下，删除分支后，会丢掉分支信息。

如果要强制禁用Fast forward模式，Git就会在merge时生成一个新的commit，这样，从分支历史上就可以看出分支信息。

下面我们实战一下--no-ff方式的git merge：

首先，仍然创建并切换dev分支：
	
	git checkout -b dev

修改readme.txt文件，并提交一个新的commit：

	git add readme.txt 
	git commit -m "add merge"

现在，我们切换回master：

	git checkout master

准备合并dev分支，请注意--no-ff参数，表示禁用Fast forward：

	git merge --no-ff -m "merge with no-ff" dev

因为本次合并要创建一个新的commit，所以加上-m参数，把commit描述写进去。

合并后，我们用git log看看分支历史：

	git log --graph --pretty=oneline --abbrev-commit

可以看到，不使用Fast forward模式，merge后就像这样：

![](http://www.liaoxuefeng.com/files/attachments/001384909222841acf964ec9e6a4629a35a7a30588281bb000/0)
分支策略

在实际开发中，我们应该按照几个基本原则进行分支管理：

首先，master分支应该是非常稳定的，也就是仅用来发布新版本，平时不能在上面干活；

那在哪干活呢？干活都在dev分支上，也就是说，dev分支是不稳定的，到某个时候，比如1.0版本发布时，再把dev分支合并到master上，在master分支发布1.0版本；

你和你的小伙伴们每个人都在dev分支上干活，每个人都有自己的分支，时不时地往dev分支上合并就可以了。

所以，团队合作的分支看起来就像这样：

![](http://www.liaoxuefeng.com/files/attachments/001384909239390d355eb07d9d64305b6322aaf4edac1e3000/0)

Git分支十分强大，在团队开发中应该充分应用。

合并分支时，加上--no-ff参数就可以用普通模式合并，合并后的历史有分支，能看出来曾经做过合并，而fast forward合并就看不出来曾经做过合并。

##Bug分支

软件开发中，bug就像家常便饭一样。有了bug就需要修复，在Git中，由于分支是如此的强大，所以，每个bug都可以通过一个新的临时分支来修复，修复后，合并分支，然后将临时分支删除。

当你接到一个修复一个代号101的bug的任务时，很自然地，你想创建一个分支issue-101来修复它，但是，等等，当前正在dev上进行的工作还没有提交：

	git status

并不是你不想提交，而是工作只进行到一半，还没法提交，预计完成还需1天时间。但是，必须在两个小时内修复该bug，怎么办？

幸好，Git还提供了一个stash功能，可以把当前工作现场“储藏”起来，等以后恢复现场后继续工作：

	 git stash
现在，用git status查看工作区，就是干净的（除非有没有被Git管理的文件），因此可以放心地创建分支来修复bug。

首先确定要在哪个分支上修复bug，假定需要在master分支上修复，就从master创建临时分支：

 	git checkout master

现在修复bug，然后提交：

	git add readme.txt 
	git commit -m "fix bug 101"

修复完成后，切换到master分支，并完成合并，最后删除issue-101分支：

	git checkout master

现在，是时候接着回到dev分支干活了！

	git checkout dev
工作区是干净的，刚才的工作现场存到哪去了？用git stash list命令看看：

	 git stash list

工作现场还在，Git把stash内容存在某个地方了，但是需要恢复一下，有两个办法：

一是用git stash apply恢复，但是恢复后，stash内容并不删除，你需要用git stash drop来删除；

另一种方式是用git stash pop，恢复的同时把stash内容也删了：
	
	git stash pop

再用git stash list查看，就看不到任何stash内容了：

	git stash list

可以多次stash，恢复的时候，先用git stash list查看，然后恢复指定的stash，用命令：

	git stash apply stash@{0}

##Feature分支

软件开发中，总有无穷无尽的新的功能要不断添加进来。

添加一个新功能时，你肯定不希望因为一些实验性质的代码，把主分支搞乱了，所以，每添加一个新功能，最好新建一个feature分支，在上面开发，完成后，合并，最后，删除该feature分支。

现在，你终于接到了一个新任务：开发代号为Vulcan的新功能，该功能计划用于下一代星际飞船。

于是准备开发：

	git checkout -b feature-vulcan

5分钟后，开发完毕：

	git add vulcan.py
	git status
 	git commit -m "add feature vulcan"

切回dev，准备合并：

	git checkout dev
一切顺利的话，feature分支和bug分支是类似的，合并，然后删除。

但是，

就在此时，接到上级命令，因经费不足，新功能必须取消！

虽然白干了，但是这个分支还是必须就地销毁：

	git branch -d feature-vulcan
error: The branch 'feature-vulcan' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature-vulcan'.
销毁失败。Git友情提醒，feature-vulcan分支还没有被合并，如果删除，将丢失掉修改，如果要强行删除，需要使用命令git branch -D feature-vulcan。

现在我们强行删除：

	git branch -D feature-vulcan

终于删除成功！

小结

开发一个新feature，最好新建一个分支；

如果要丢弃一个没有被合并过的分支，可以通过git branch -D <name>强行删除。

##多人协作

当你从远程仓库克隆时，实际上Git自动把本地的master分支和远程的master分支对应起来了，并且，远程仓库的默认名称是origin。

要查看远程库的信息，用git remote：

	$ git remote
 
或者，用git remote -v显示更详细的信息：

	git remote -v

上面显示了可以抓取和推送的origin的地址。如果没有推送权限，就看不到push的地址。

###推送分支

推送分支，就是把该分支上的所有本地提交推送到远程库。推送时，要指定本地分支，这样，Git就会把该分支推送到远程库对应的远程分支上：

	git push origin master
如果要推送其他分支，比如dev，就改成：

	git push origin dev
但是，并不是一定要把本地分支往远程推送，那么，哪些分支需要推送，哪些不需要呢？

master分支是主分支，因此要时刻与远程同步；

dev分支是开发分支，团队所有成员都需要在上面工作，所以也需要与远程同步；

bug分支只用于在本地修复bug，就没必要推到远程了，除非老板要看看你每周到底修复了几个bug；

feature分支是否推到远程，取决于你是否和你的小伙伴合作在上面开发。

总之，就是在Git中，分支完全可以在本地自己藏着玩，是否推送，视你的心情而定！

##创建标签

在Git中打标签非常简单，首先，切换到需要打标签的分支上：

	git branch

然后，敲命令git tag <name>就可以打一个新标签：

	git tag v1.0
可以用命令git tag查看所有标签：

	git tag

默认标签是打在最新提交的commit上的。有时候，如果忘了打标签，比如，现在已经是周五了，但应该在周一打的标签没有打，怎么办？

方法是找到历史提交的commit id，然后打上就可以了：

	git log --pretty=oneline --abbrev-commit

比方说要对add merge这次提交打标签，它对应的commit id是6224937，敲入命令：

	git tag v0.9 6224937
再用命令git tag查看标签：

	git tag

注意，标签不是按时间顺序列出，而是按字母排序的。可以用git show <tagname>查看标签信息：

	git show v0.9

可以看到，v0.9确实打在add merge这次提交上。

还可以创建带有说明的标签，用-a指定标签名，-m指定说明文字：

	git tag -a v0.1 -m "version 0.1 released" 3628164
用命令git show <tagname>可以看到说明文字：

	git show v0.1

还可以通过-s用私钥签名一个标签：

	git tag -s v0.2 -m "signed version 0.2 released" fec145a
签名采用PGP签名，因此，必须首先安装gpg（GnuPG），如果没有找到gpg，或者没有gpg密钥对，就会报错：
	
	gpg: signing failed: secret key not available
	error: gpg failed to sign the data
	error: unable to sign the tag
如果报错，请参考GnuPG帮助文档配置Key。

用命令git show <tagname>可以看到PGP签名信息：

	git show v0.2

用PGP签名的标签是不可伪造的，因为可以验证PGP签名。验证签名的方法比较复杂，这里就不介绍了。

小结

命令git tag <name>用于新建一个标签，默认为HEAD，也可以指定一个commit id；

git tag -a <tagname> -m "blablabla..."可以指定标签信息；

git tag -s <tagname> -m "blablabla..."可以用PGP签名标签；

命令git tag可以查看所有标签

##操作标签

如果标签打错了，也可以删除：

	$ git tag -d v0.1

因为创建的标签都只存储在本地，不会自动推送到远程。所以，打错的标签可以在本地安全删除。

如果要推送某个标签到远程，使用命令git push origin <tagname>：

	git push origin v1.0

或者，一次性推送全部尚未推送到远程的本地标签：

	git push origin --tags

如果标签已经推送到远程，要删除远程标签就麻烦一点，先从本地删除：

	git tag -d v0.9

然后，从远程删除。删除命令也是push，但是格式如下：

	git push origin :refs/tags/v0.9

要看看是否真的从远程库删除了标签，可以登陆GitHub查看。

##使用GitHub

我们一直用GitHub作为免费的远程仓库，如果是个人的开源项目，放到GitHub上是完全没有问题的。其实GitHub还是一个开源协作社区，通过GitHub，既可以让别人参与你的开源项目，也可以参与别人的开源项目。

在GitHub出现以前，开源项目开源容易，但让广大人民群众参与进来比较困难，因为要参与，就要提交代码，而给每个想提交代码的群众都开一个账号那是不现实的，因此，群众也仅限于报个bug，即使能改掉bug，也只能把diff文件用邮件发过去，很不方便。

但是在GitHub上，利用Git极其强大的克隆和分支功能，广大人民群众真正可以第一次自由参与各种开源项目了。

如何参与一个开源项目呢？比如人气极高的bootstrap项目，这是一个非常强大的CSS框架，你可以访问它的项目主页https://github.com/twbs/bootstrap，点“Fork”就在自己的账号下克隆了一个bootstrap仓库，然后，从自己的账号下clone：

git clone git@github.com:michaelliao/bootstrap.git
一定要从自己的账号下clone仓库，这样你才能推送修改。如果从bootstrap的作者的仓库地址git@github.com:twbs/bootstrap.git克隆，因为没有权限，你将不能推送修改。

Bootstrap的官方仓库twbs/bootstrap、你在GitHub上克隆的仓库my/bootstrap，以及你自己克隆到本地电脑的仓库，他们的关系就像下图显示的那样：

![](http://www.liaoxuefeng.com/files/attachments/001384926554932eb5e65df912341c1a48045bc274ba4bf000/0)

如果你想修复bootstrap的一个bug，或者新增一个功能，立刻就可以开始干活，干完后，往自己的仓库推送。

如果你希望bootstrap的官方库能接受你的修改，你就可以在GitHub上发起一个pull request。当然，对方是否接受你的pull request就不一定了。

如果你没能力修改bootstrap，但又想要试一把pull request，那就Fork一下我的仓库：https://github.com/michaelliao/learngit，创建一个your-github-id.txt的文本文件，写点自己学习Git的心得，然后推送一个pull request给我，我会视心情而定是否接受。

小结

在GitHub上，可以任意Fork开源仓库；

自己拥有Fork后的仓库的读写权限；

可以推送pull request给官方仓库来贡献代码。


##自定义Git

让Git显示颜色，会让命令输出看起来更醒目：

	git config --global color.ui true
这样，Git会适当地显示不同的颜色，比如git status命令 

##忽略特殊文件

有些时候，你必须把某些文件放到Git工作目录中，但又不能提交它们，比如保存了数据库密码的配置文件啦，等等，每次git status都会显示Untracked files ...，有强迫症的童鞋心里肯定不爽。

好在Git考虑到了大家的感受，这个问题解决起来也很简单，在Git工作区的根目录下创建一个特殊的.gitignore文件，然后把要忽略的文件名填进去，Git就会自动忽略这些文件。

不需要从头写.gitignore文件，GitHub已经为我们准备了各种配置文件，只需要组合一下就可以使用了。所有配置文件可以直接在线浏览：https://github.com/github/gitignore

忽略文件的原则是：

1. 忽略操作系统自动生成的文件，比如缩略图等；
2. 忽略编译生成的中间文件、可执行文件等，也就是如果一个文件是通过另一个文件自动生成的，那自动生成的文件就没必要放进版本库，比如Java编译产生的.class文件；
3. 忽略你自己的带有敏感信息的配置文件，比如存放口令的配置文件。

举个例子：

假设你在Windows下进行Python开发，Windows会自动在有图片的目录下生成隐藏的缩略图文件，如果有自定义目录，目录下就会有Desktop.ini文件，因此你需要忽略Windows自动生成的垃圾文件：
	
	# Windows:
	Thumbs.db
	ehthumbs.db
	Desktop.ini
然后，继续忽略Python编译产生的.pyc、.pyo、dist等文件或目录：

	# Python:
	*.py[cod]
	*.so
	*.egg
	*.egg-info
	dist
	build
加上你自己定义的文件，最终得到一个完整的.gitignore文件，内容如下：

	# Windows:
	Thumbs.db
	ehthumbs.db
	Desktop.ini
	
	# Python:
	*.py[cod]
	*.so
	*.egg
	*.egg-info
	dist
	build
	
	# My configurations:
	db.ini
	deploy_key_rsa
最后一步就是把.gitignore也提交到Git，就完成了！当然检验.gitignore的标准是git status命令是不是说working directory clean。

使用Windows的童鞋注意了，如果你在资源管理器里新建一个.gitignore文件，它会非常弱智地提示你必须输入文件名，但是在文本编辑器里“保存”或者“另存为”就可以把文件保存为.gitignore了。

有些时候，你想添加一个文件到Git，但发现添加不了，原因是这个文件被.gitignore忽略了：

	git add App.class

如果你确实想添加该文件，可以用-f强制添加到Git：

	 git add -f App.class
或者你发现，可能是.gitignore写得有问题，需要找出来到底哪个规则写错了，可以用git check-ignore命令检查：

	git check-ignore -v App.class

Git会告诉我们，.gitignore的第3行规则忽略了该文件，于是我们就可以知道应该修订哪个规则。

小结

忽略某些文件时，需要编写.gitignore；

.gitignore文件本身要放到版本库里，并且可以对.gitignore做版本管理！


##配置别名

有没有经常敲错命令？比如git status？status这个单词真心不好记。

如果敲git st就表示git status那就简单多了，当然这种偷懒的办法我们是极力赞成的。

我们只需要敲一行命令，告诉Git，以后st就表示status：

	git config --global alias.st status
好了，现在敲git st看看效果。

当然还有别的命令可以简写，很多人都用co表示checkout，ci表示commit，br表示branch：
	
	$ git config --global alias.co checkout
	$ git config --global alias.ci commit
	$ git config --global alias.br branch
以后提交就可以简写成：

	$ git ci -m "bala bala bala..."
--global参数是全局参数，也就是这些命令在这台电脑的所有Git仓库下都有用。

在撤销修改一节中，我们知道，命令git reset HEAD file可以把暂存区的修改撤销掉（unstage），重新放回工作区。既然是一个unstage操作，就可以配置一个unstage别名：

	git config --global alias.unstage 'reset HEAD'
当你敲入命令：

	 git unstage test.py
实际上Git执行的是：

	git reset HEAD test.py
配置一个git last，让其显示最后一次提交信息：

	git config --global alias.last 'log -1'
这样，用git last就能显示最近一次的提交：

	git last
 
甚至还有人丧心病狂地把lg配置成了：

	git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
来看看git lg的效果：

	git-lg



配置文件

配置Git的时候，加上--global是针对当前用户起作用的，如果不加，那只针对当前的仓库起作用。

配置文件放哪了？每个仓库的Git配置文件都放在.git/config文件中：

	$ cat .git/config 
	[core]
	    repositoryformatversion = 0
	    filemode = true
	    bare = false
	    logallrefupdates = true
	    ignorecase = true
	    precomposeunicode = true
	[remote "origin"]
	    url = git@github.com:michaelliao/learngit.git
	    fetch = +refs/heads/*:refs/remotes/origin/*
	[branch "master"]
	    remote = origin
	    merge = refs/heads/master
	[alias]
	    last = log -1
别名就在[alias]后面，要删除别名，直接把对应的行删掉即可。

而当前用户的Git配置文件放在用户主目录下的一个隐藏文件.gitconfig中：
	
	$ cat .gitconfig
	[alias]
	    co = checkout
	    ci = commit
	    br = branch
	    st = status
	[user]
	    name = Your Name
	    email = your@email.com
配置别名也可以直接修改这个文件，如果改错了，可以删掉文件重新通过命令配置。

小结

给Git配置好别名，就可以输入命令时偷个懒。我们鼓励偷懒。

##搭建Git服务器



GitHub就是一个免费托管开源代码的远程仓库。但是对于某些视源代码如生命的商业公司来说，既不想公开源代码，又舍不得给GitHub交保护费，那就只能自己搭建一台Git服务器作为私有仓库使用。

搭建Git服务器需要准备一台运行Linux的机器，强烈推荐用Ubuntu或Debian，这样，通过几条简单的apt命令就可以完成安装。

假设你已经有sudo权限的用户账号，下面，正式开始安装。

第一步，安装git：

	sudo apt-get install git
第二步，创建一个git用户，用来运行git服务：

	sudo adduser git
第三步，创建证书登录：

收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。

第四步，初始化Git仓库：

先选定一个目录作为Git仓库，假定是/srv/sample.git，在/srv目录下输入命令：

	sudo git init --bare sample.git
Git就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的Git仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的Git仓库通常都以.git结尾。然后，把owner改为git：

	sudo chown -R git:git sample.git
第五步，禁用shell登录：

出于安全考虑，第二步创建的git用户不允许登录shell，这可以通过编辑/etc/passwd文件完成。找到类似下面的一行：

	git:x:1001:1001:,,,:/home/git:/bin/bash
改为：

	git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell
这样，git用户可以正常通过ssh使用git，但无法登录shell，因为我们为git用户指定的git-shell每次一登录就自动退出。

第六步，克隆远程仓库：

现在，可以通过git clone命令克隆远程仓库了，在各自的电脑上运行：

	git clone git@server:/srv/sample.git

剩下的推送就简单了。

管理公钥

如果团队很小，把每个人的公钥收集起来放到服务器的/home/git/.ssh/authorized_keys文件里就是可行的。如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。

这里我们不介绍怎么玩Gitosis了，几百号人的团队基本都在500强了，相信找个高水平的Linux管理员问题不大。

管理权限

有很多不但视源代码如生命，而且视员工为窃贼的公司，会在版本控制系统里设置一套完善的权限控制，每个人是否有读写权限会精确到每个分支甚至每个目录下。因为Git是为Linux源代码托管而开发的，所以Git也继承了开源社区的精神，不支持权限控制。不过，因为Git支持钩子（hook），所以，可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。

这里我们也不介绍Gitolite了，不要把有限的生命浪费到权限斗争中。

小结

搭建Git服务器非常简单，通常10分钟即可完成；

要方便管理公钥，用Gitosis；

要像SVN那样变态地控制权限，用Gitolite。

http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000


# 添加多个仓库

	#添加github
	git remote add origin https://github.com/xxx(仓库地址)
	#添加oschina
	git remote add oschina https://git.oschina.net/xxxx(仓库地址)
	#提交到oschina
	git push oschina master(分支名)
	#提交到github
	git push origin master(分支名)
	#从oschina更新
	git pull oschina master
	#从github更新
	git pull origin master