<p><br></p>
<p>/opt/solr/bin/solr create -c mycol -d data_driven_schema_configs -s 3 -rf 2 -n myconf</p>
<p><br></p>
<p>http://172.17.11.135:8983/solr/admin/collections?action=CREATE&amp;name=mycol&amp;numShards=3&amp;replicationFactor=2&amp;maxShardsPerNode=6&amp;collection.configName=myconf</p>
<p><br></p>
<p>http://172.17.11.135:8983/solr/admin/collections?action=DELETE&amp;name=mycol</p>
<p>http://172.17.11.135:8983/solr/admin/collections?action=reload&amp;name=mycol</p>
<p><br></p>
<p>/opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost 172.17.11.135:2181 -cmd upconfig -c mycol -d /opt/solr-5.3.1/server/solr/configsets/data_driven_schema_configs/conf -n myconf</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>curl "http://172.17.10.13:8880/solr/collection1/update/json?commit=true" --data-binary @clear.json -H 'Content-type:text/json; charset=utf-8'</p>
<p>curl "http://172.17.10.13:8880/solr/collection1/update/json?commit=true" --data-binary @books.json -H 'Content-type:text/json; charset=utf-8'</p>
<p>curl "http://172.17.10.13:8880/solr/collection1/select?q=*:*&amp;wt=json"</p>
<p><br></p>
<p><br></p>
<p>cat clear.json&nbsp;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;{"delete": {</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"query": "*:*"</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;}</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;}</p>
<p><br></p>
<p><br></p>
<p>cat books.json</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;{"add":{"overwrite":true,"doc":{"id":1,"name":"\u6e56\u5357\u536b\u89c6","area":"\u6e56\u5357"}}}</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;{"add":{"overwrite":true,"doc":{"id":2,"name":"\u6e56\u5357\u7535\u89c6\u5267\u573a","area":"\u6e56\u5357"}}}</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;{"add":{"overwrite":true,"doc":{"id":3,"name":"\u6c5f\u82cf\u536b\u89c6","area":"\u6c5f\u82cf"}}}</p>
<p><br></p>
