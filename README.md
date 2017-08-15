# dockerPipeWork
    脚本作用：
      1、用于本地管理容器，同时指定容器IP
      2、适用场景,容器内容需要经常修改的且持久存储。
    ＃说明
    0、本脚本依赖于pipework,自行安装,参考（https://github.com/jetlwx/pipework）
     1、TOMCAT运用环境，目录主要有三个 tomcat ,tomcat工程目录，自定义目录jjshome-dir
     2、目录创建规则
       /data/os/app/${app_name}/${tomcatDir}
       /data/os/app/${app_name}/${projectDir}
        /data/os/app/${app_name}/${jjshome-dir}
    	redis, nginx 都类似操作
     3、TOMCAT工程启动命令写到${jjshome-dir}/start-my-app.sh
     如：

 ```bash
#!/bin/sh
source /etc/profile
export  JAVA_HOME=/usr/local/jdk1.7
export  JAVA_BIN=/usr/local/jdk1.7/bin
export  JRE_HOME=/usr/local/jdk1.7/jre 
export  CLASSPATH=/usr/local/jdk1.7/jre/lib:/usr/local/jdk1.7/lib:/usr/local/jdk1.7/jre/lib/charsets.jar
export  PATH=$PATH:/usr/local/jdk1.7/bin:/usr/local/jdk1.7/jre/bin

cd /usr/local/tomcat/bin && ./startup.sh

##add your custome applicatin start porgram here 
#---------------start   -------------------------

#eg:
echo 'docker is a good softwrare!!'

#-------------- stop  ----------------------------
/usr/sbin/sshd -D
```

