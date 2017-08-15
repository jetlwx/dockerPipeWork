# dockerPipeWork
脚本作用：<br>
  1、用于本地管理容器，同时指定容器IP<br>
  2、适用场景,容器内容需要经常修改的且持久存储。<br>
＃说明<br>
 1、TOMCAT运用环境，目录主要有三个 tomcat ,tomcat工程目录，自定义目录jjshome-dir<br>
 2、目录创建规则<br>
   /data/os/app/${app_name}/${tomcatDir}<br>
   /data/os/app/${app_name}/${projectDir}<br>
    /data/os/app/${app_name}/${jjshome-dir}<br>
 3、TOMCAT工程启动命令写到${jjshome-dir}/start-my-app.sh<br>
 如：<br>
<br>
 #!/bin/sh<br>
source /etc/profile<br>
export  JAVA_HOME=/usr/local/jdk1.7<br>
export  JAVA_BIN=/usr/local/jdk1.7/bin<br>
export  JRE_HOME=/usr/local/jdk1.7/jre <br>
export  CLASSPATH=/usr/local/jdk1.7/jre/lib:/usr/local/jdk1.7/lib:/usr/local/jdk1.7/jre/lib/charsets.jar<br>
export  PATH=$PATH:/usr/local/jdk1.7/bin:/usr/local/jdk1.7/jre/bin<br>

cd /usr/local/tomcat/bin && ./startup.sh<br>

##add your custome applicatin start porgram here <br>
#---------------start   -------------------------<br>

#eg:<br>
echo 'docker is a good softwrare!!'<br>

#-------------- stop  ----------------------------<br>
/usr/sbin/sshd -D<br>

