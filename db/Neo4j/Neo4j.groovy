package test;

import org.apache.commons.io.FileUtils
import org.jsoup.Jsoup

public class Neo4j {
    public static void main(String[] args) {
        def url="http://neo4j.com.cn/public/docs/"
        def dir="E:/API/db/Neo4j"
        def name="index.html"
        def timeout=60000
        def file=new File(dir,name);
        if(!file.exists()){
            FileUtils.writeStringToFile(file, get(url+name,timeout).select(".toctree-wrapper").toString())
        }
        def doc=Jsoup.parse(file,"UTF-8")
        doc.select(".toctree-wrapper").select("a").each({
              write(url, it, timeout, file,null)
        })
    }

    def static  write(def url,def it, def timeout, def f,def content) {
        try {
            if(null==content)
                content=get(url+it.attr("href"),timeout).select(".section")
        } catch (Exception e) {
            content=get(url+it.attr("href"),2*timeout).select(".section")
        }
        if(null==content){
            return ;
        }
        content.select("a").each({ a->
            def href=a.attr("href");
            if(!href.startsWith("#")&&!href.startsWith("http")){
                if(it.attr("href").lastIndexOf("/")!=-1){
                    href=it.attr("href").substring(0, it.attr("href").lastIndexOf("/")+1)+a.attr("href");
                    a.attr("href",href)
                }
                def doc=get(url+href,timeout)
                if(null!=doc){
                    write(new File(f.getParent(),href),doc.select(".section").html(),false)
                }
            }
        })
        write(f,content.html(),true)
    }
    def static get(def url, def timeout){
        try{
             def con=Jsoup.connect(url).timeout(timeout);
             if(null==con){
                 return;
             }
             return con.get()
        }catch(Exception ignore){
        } 
    }
    
    def static write(def f,def content,def append){
        println content
        FileUtils.writeStringToFile(f,content,append)
    }
    
}
