<p>首先需安装zookeeper的php扩展：<a href="http://pecl.php.net/package/zookeeper" target="_blank">http://pecl.php.net/package/zookeeper</a>&nbsp;</p>
<p>这是我最先写的demo，都符合zookeeper的api定义及行为定义。</p>
<pre class="brush:php;toolbar:false">#!/usr/bin/env&nbsp;php
&lt;?php
if&nbsp;(!extension_loaded('zookeeper'))&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;die('zookeeper&nbsp;is&nbsp;required');
}

$host&nbsp;=&nbsp;'localhost:2181';
$zk&nbsp;=&nbsp;new&nbsp;Zookeeper($host);

$zk-&gt;get('/bar',&nbsp;'cb');

while(&nbsp;true&nbsp;)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;echo&nbsp;'.';
&nbsp;&nbsp;&nbsp;&nbsp;sleep(2);
}

function&nbsp;cb($event,&nbsp;$stat,&nbsp;$path)
{
&nbsp;&nbsp;&nbsp;&nbsp;echo&nbsp;"in&nbsp;watch&nbsp;callback\n";
}</pre>
<p>但当接收到服务器端的数据时，会报如下错误：</p>
<pre class="brush:plain;toolbar:false">PHP&nbsp;Warning:&nbsp;&nbsp;sleep():&nbsp;could&nbsp;not&nbsp;invoke&nbsp;watcher&nbsp;callback&nbsp;in&nbsp;/Users/x/src/zoo-php/watch2.php&nbsp;on&nbsp;line&nbsp;14
PHP&nbsp;Stack&nbsp;trace:
PHP&nbsp;&nbsp;&nbsp;1.&nbsp;{main}()&nbsp;/Users/x/src/zoo-php/watch2.php:0
PHP&nbsp;&nbsp;&nbsp;2.&nbsp;sleep()&nbsp;/Users/x/src/zoo-php/watch2.php:14

Warning:&nbsp;sleep():&nbsp;could&nbsp;not&nbsp;invoke&nbsp;watcher&nbsp;callback&nbsp;in&nbsp;/Users/x/src/zoo-php/watch2.php&nbsp;on&nbsp;line&nbsp;14

Call&nbsp;Stack:
&nbsp;&nbsp;&nbsp;&nbsp;0.0012&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;227664&nbsp;&nbsp;&nbsp;1.&nbsp;{main}()&nbsp;/Users/x/src/zoo-php/watch2.php:0
&nbsp;&nbsp;754.5150&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;228272&nbsp;&nbsp;&nbsp;2.&nbsp;sleep()&nbsp;/Users/x/src/zoo-php/watch2.php:14</pre>
<p>这样的运行结果给我带来苦恼，代码应该是极简单的，然后在网上找了很多资料及官方的文档。找到一个可以正确运行的用例 &nbsp;<span style="font-family:'宋体', 'sans serif', tahoma, verdana, helvetica;line-height:24px;"><a href="https://github.com/andreiz/php-zookeeper/issues/34" target="_blank">https://github.com/andreiz/php-zookeeper/issues/34</a>&nbsp;，这个用例和我的demo的差别仅是watch函数一个是简单的函数，一个是对象的方法。</span></p>
<p><span style="font-family:'宋体', 'sans serif', tahoma, verdana, helvetica;line-height:24px;"><br></span></p>
<p><span style="font-family:'宋体', 'sans serif', tahoma, verdana, helvetica;line-height:24px;">我咨询过有经验人士，反馈说这可能是由于zookeeper的php扩展存在BUG，建议不要去浪费时间探究。</span><br></p>
<p><span style="font-family:'宋体', 'sans serif', tahoma, verdana, helvetica;line-height:24px;"></span></p>
<p><br></p>
<p>小结一下：进程在sleep系统调用上阻塞。曾经我以为进程在设置watcher的zookeeper的api上阻塞，如get、exists等，事实上不是。<span style="line-height:1.5;">php-zookeeper扩展是使用C api封装的，其使用的多线程模型，至于线程在何处阻塞，不了解。有网友反馈用于watch的进程运行完了进程就结束了，而没有表现出在等待服务器端事件，应该就是这个原因。</span></p>
<p><span style="line-height:1.5;"><br></span></p>
<p><br></p>
