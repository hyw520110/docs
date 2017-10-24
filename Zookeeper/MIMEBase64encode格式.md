<p>&nbsp; &nbsp; 这个函数比较坑，用它生成Zookeeper的acl，末尾总会多个%0A，正确的应该是以等号结尾。</p>
<p>&nbsp; &nbsp;&nbsp;</p>
<p>&nbsp; &nbsp; 果断使用chomp把生成的串洗白白~~</p>
