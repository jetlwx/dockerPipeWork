#!/bin/bash
basedir='/data/os/app'
img1='localhub.local/public/centos-v21:7.3.1611'
img2='localhub.local/public/centos-jdk18-v2:7.3.1611'
img3='localhub.local/public/centos-for-nginx-v2:7.3.1611'
mount2='-v /etc/hosts:/etc/hosts'
dns='--dns=172.16.4.52 --dns=202.96.134.133'
comm_startapp='/home/jjshome-dir/start-my-app.sh'
ContainerGateway='172.16.16.1'
networkMask=24
#about pipework see https://github.com/jetlwx/pipework
pipworkpath='/usr/bin/pipework'
attachDevice=br0 
#cpu: 100m 200m,mem:4G
comm_OPTS='--oom-kill-disable --rm  --memory=4294967296 --cpu-period=100000 --cpu-quota=200000'

 [ "$1" == "" ] && {
 showmsg=`cat start_leyoujia.sh  | grep function | awk '{print $2}' | awk -F'(' '{print $1}' | grep -v 'Run' | grep -v main`
   echo '$1 may be one of  '  ${showmsg}
   exit 1
}

function dockerRun(){
  ContainHostname=$1
  ContainerIP=$2
  Cmd=$3
  imgage=$4
  shift;shift;shift;shift
  OPTS=$@
  ContainerID=`docker run -d ${dns} ${mount2} ${OPTS} --hostname ${ContainHostname} --name ${ContainHostname} ${imgage} ${Cmd} `
 
 ${pipworkpath} ${attachDevice} ${ContainerID} ${ContainerIP}'/'${networkMask}'@'${ContainerGateway}
echo ${ContainerIP}  ${ContainHostname}  ${ContainerID}
}

function redisRun() {
  app_name=$1
  redis_dir=$2
  ContainHostname=$3
  ContainerIP=$5
  img=$4
  OPTS='-v /data/os/app/'${app_name}'/jjshome-dir:/home/jjshome-dir -v /data/os/app/'${app_name}'/'${redis_dir}':/usr/local/redis '${comm_OPTS}
  cmd=${comm_startapp}
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}


# has project dir
function tomcatRun() {
  app_name=$1
  tomcatDir=$2
  projectDir=$3
  ContainHostname=$4
  ContainerIP=$5
  img=$6
  cmd=${comm_startapp}
  OPTS='-v /data/os/app/'${app_name}'/'${tomcatDir}':/usr/local/tomcat -v /data/os/app/'${app_name}'/'${projectDir}':/home/admin/'${projectDir}' -v /data/os/app/'${app_name}'/jjshome-dir:/home/jjshome-dir '${comm_OPTS}
  cmd=${comm_startapp}
  
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}

function tomcatRun_noproject(){
  app_name=$1
  tomcatDir=$2
  ContainHostname=$3
  ContainerIP=$4
  img=$5
  OPTS='-v /data/os/app/'${app_name}'/'${tomcatDir}':/usr/local/tomcat -v /data/os/app/'${app_name}'/jjshome-dir:/home/jjshome-dir '${comm_OPTS}
  cmd=${comm_startapp}
  
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}
#no has project dir
function javaAppRun() {
  app_name=$1
  appDir=$2
  ContainHostname=$3
  ContainerIP=$4
  img=$5
  cmd=${comm_startapp}
  OPTS='-v /data/os/app/'${app_name}'/'${appDir}':/home/admin/'${appDir}'  -v /data/os/app/'${app_name}'/jjshome-dir:/home/jjshome-dir '${comm_OPTS}
  
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}
#NGINX RPM INSTALL 
function ngxinRPMRun() {
  app_name=$1
  ContainHostname=$2
  ContainerIP=$3
  img=$4
  cmd=${comm_startapp}
  OPTS='-v /data/os/app/'${app_name}'/:/home '${comm_OPTS}
  
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}

function nginxIRun() {
  ContainHostname=$1
  ContainerIP=$2
  img=$3
  cmd='/usr/local/nginx/start-my-app.sh'
  OPTS='-v /usr/local/nginx:/usr/local/nginx -v /web:/web '${comm_OPTS}
  
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}

function memcachedRun() {
  app_name=$1
  ContainHostname=$2
  ContainerIP=$3
  img=$4
  cmd=${comm_startapp}
  OPTS='-v /data/os/app/'${app_name}':/home '${comm_OPTS}
  
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}
function mycatRun() {
  app_name=$1
  ContainHostname=$2
  ContainerIP=$3
  img=$4
  cmd=${comm_startapp}
  OPTS='-v /data/os/app/'${app_name}'/mycat:/usr/local/mycat -v /data/os/app/'${app_name}'/jjshome-dir:/home/jjshome-dir '${comm_OPTS}
 
  dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}



function fang-esf-mycat() {
  #/data/os/app/fang-esf-mycat
  app_name='fang-esf-mycat'
  ContainHostname='fang-esf-mycat.dev.jjshome.local'
  ContainerIP='172.16.16.11'
  img=${img1}
 mycatRun ${app_name} ${ContainHostname} ${ContainerIP} ${img}
}

function bigdata-nginx() {
  app_name='bigdata-nginx'
  ContainHostname='bigdata-nginx.dev.jjshome.local'
  ContainerIP='172.16.16.10'
  img=${img1}
  ngxinRPMRun ${app_name} ${ContainHostname} ${ContainerIP} ${img1}
}

function platform-mycat() {
  #/data/os/app/platform-mycat
  app_name='platform-mycat'
  ContainHostname='platform-mycat.dev.jjshome.local'
  ContainerIP='172.16.16.12'
  img=${img1}
 mycatRun ${app_name} ${ContainHostname} ${ContainerIP} ${img}
}

function public-memcached() {
  app_name="public-memcached"
  ContainHostname="public-memcached.dev.jjshome.local"
  ContainerIP='172.16.16.13'
  img=${img1}
  memcachedRun ${app_name} ${ContainHostname} ${ContainerIP} ${img}
}


function dubbo() {
 OPTS='-v /data/os/app/platform-dubbo/zookeeper-3.4.6:/usr/local/zookeeper -v /data/os/app/platform-dubbo/start-dubbo.sh:/start-dubbo.sh '${comm_OPTS}
 ContainHostname='dubbo.dev.jjshome.local'
 ContainerIP='172.16.16.14'
 cmd='/start-dubbo.sh'
  img=${img1}
 dockerRun ${ContainHostname} ${ContainerIP} ${cmd} ${img} ${OPTS} 
}

function dubbo_admin(){
  #/data/os/app/platform-dubbo/dubbo_admin_tomcat
  app_name='platform-dubbo'
  tomcatDir='dubbo_admin_tomcat'
  ContainHostname='dubbo-admin.dev.jjshome.local'
  ContainerIP='172.16.16.15'
  img=${img1}
  tomcatRun_noproject ${app_name} ${tomcatDir} ${ContainHostname} ${ContainerIP} ${img}
}

function fang-community(){
  #/data/os/app/fang-community/tomcat-community
  #/data/os/app/fang-community/community
  app_name=fang-community
  tomcatDir=tomcat-community
  projectDir=community
  ContainHostname='fang-community.dev.jjshome.local'
  ContainerIP='172.16.16.16'
  img=${img1}
  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function platform-xdiamond(){
  #/data/os/app/platform-xdiamond/xdiamond
  #/data/os/app/platform-xdiamond/tomcat-xdiamond
  app_name=platform-xdiamond
  tomcatDir=tomcat-xdiamond
  projectDir=xdiamond
  ContainHostname='platform-xdiamond.dev.jjshome.local'
  ContainerIP='172.16.16.17'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}  
}

function app_redis() {
 #/data/os/app/app-redis/redis-3.0.7
  app_name='app-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='app-redis.dev.jjshome.local'
  ContainerIP='172.16.16.18'
  img=${img1}
  
 redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}

function platform-redis() {
 #/data/os/app/platform-redis/redis-3.0.7
  app_name='platform-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='platform-redis.dev.jjshome.local'
  ContainerIP='172.16.16.19'
  img=${img1}

 redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}

function share-session-redis(){
  #/data/os/app/share-session-redis/redis-3.0.7
  app_name='share-session-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='share-session-redis.dev.jjshome.local'
  ContainerIP='172.16.16.20'
  img=${img1}

 redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}

function bigdata-redis() {
  #/data/os/app/bigdata-redis/redis-3.0.7
  app_name='bigdata-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='bigdata-redis.dev.jjshome.local'
  ContainerIP='172.16.16.21'
  img=${img1}

  redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}
function coa-redis() {
  #/data/os/app/coa-redis/redis-3.0.7
  app_name='coa-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='coa-redis.dev.jjshome.local'
  ContainerIP='172.16.16.22'
  img=${img1}

  redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}

function fang-esf-redis() {
  #/data/os/app/fang-esf-redis/redis-3.0.7
  app_name='fang-esf-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='fang-esf-redis.dev.jjshome.local'
  ContainerIP='172.16.16.23'
  img=${img1}

  redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}
function fang-web-redis() {
  #/data/os/app/fang-web-redis/redis-3.0.7
  app_name='fang-web-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='fang-web-redis.dev.jjshome.local'
  ContainerIP='172.16.16.24'
  img=${img1}

 redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}
function fang-xinfang-redis() {
  #/data/os/app/fang-xinfang-redis/redis-3.0.7
  app_name='fang-xinfang-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='fang-xinfang-redis.dev.jjshome.local'
  ContainerIP='172.16.16.25'
  img=${img1}

 redisRun ${app_name} ${redis_dir} ${ContainHostname}  ${img} ${ContainerIP}
}
function jinrong-redis() {
  #/data/os/app/jinrong-redis/redis-3.0.7
  app_name='jinrong-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='jinrong-redis.dev.jjshome.local'
  ContainerIP='172.16.16.26'
  img=${img1}

  redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}
function key-redis() {
  #/data/os/app/key-redis/redis-3.0.7
  app_name='key-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='key-redis.dev.jjshome.local'
  ContainerIP='172.16.16.27'
  img=${img1}
 redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}
function oa-redis() {
  #/data/os/app/oa-redis/redis-3.0.7
  app_name='oa-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='oa-redis.dev.jjshome.local'
  ContainerIP='172.16.16.28'
  img=${img1}

  redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}
function umc-redis() {
  #/data/os/app/umc-redis/redis-3.0.7
  app_name='umc-redis'
  redis_dir='redis-3.0.7'
  ContainHostname='umc-redis.dev.jjshome.local'
  ContainerIP='172.16.16.29'
  img=${img1}

 redisRun ${app_name} ${redis_dir} ${ContainHostname} ${img} ${ContainerIP}
}

function bigdata-api(){
  #/data/os/app/bigdata-api/tomcat
  #/data/os/app/bigdata-api/api
  app_name=bigdata-api
  tomcatDir=tomcat
  projectDir=api
  ContainHostname='bigdata-api.dev.jjshome.local'
  ContainerIP='172.16.16.30'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function bigdata-biadmin(){
  #/data/os/app/bigdata-biadmin/tomcat
  #/data/os/app/bigdata-biadmin/app
  app_name=bigdata-biadmin
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-biadmin.dev.jjshome.local'
  ContainerIP='172.16.16.31'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-dpf(){
  #/data/os/app/bigdata-dpf/tomcat
  #/data/os/app/bigdata-dpf/app
  app_name=bigdata-dpf
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-dpf.dev.jjshome.local'
  ContainerIP='172.16.16.32'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-engin1(){
  #/data/os/app/bigdata-engin1/tomcat
  #/data/os/app/bigdata-engin1/app
  app_name=bigdata-engin1
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-engin1.dev.jjshome.local'
  ContainerIP='172.16.16.33'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-engine1(){
  #/data/os/app/bigdata-engine1/tomcat
  #/data/os/app/bigdata-engine1/app
  app_name=bigdata-engine1
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-engine1.dev.jjshome.local'
  ContainerIP='172.16.16.34'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-fkp-core(){
  #/data/os/app/bigdata-api/tomcat
  #/data/os/app/bigdata-api/app
  app_name=bigdata-fkp-core
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-fkp-core.dev.jjshome.local'
  ContainerIP='172.16.16.35'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-fkp-view(){
  #/data/os/app/bigdata-fkp-view/tomcat
  #/data/os/app/bigdata-fkp-view/app
  app_name=bigdata-fkp-view
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-fkp-view.dev.jjshome.local'
  ContainerIP='172.16.16.36'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-logs-for-bigdata(){
  #/data/os/app/bigdata-logs-for-bigdata/tomcat
  #/data/os/app/bigdata-logs-for-bigdata/app
  app_name=bigdata-logs-for-bigdata
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-logs-for-bigdata.dev.jjshome.local'
  ContainerIP='172.16.16.37'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-mongodb-api(){
  #/data/os/app/bigdata-mongodb-api/tomcat
  #/data/os/app/bigdata-mongodb-api/app
  app_name=bigdata-mongodb-api
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-mongodb-api.dev.jjshome.local'
  ContainerIP='172.16.16.38'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-mysql-api(){
  #/data/os/app/bigdata-mysql-api/tomcat
  #/data/os/app/bigdata-mysql-api/app
  app_name=bigdata-mysql-api
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-mysql-api.dev.jjshome.local'
  ContainerIP='172.16.16.39'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-spagobi1(){
  #/data/os/app/bigdata-spagobi1/tomcat
  #/data/os/app/bigdata-spagobi1/app
  app_name=bigdata-spagobi1
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-spagobi1.dev.jjshome.local'
  ContainerIP='172.16.16.40'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function bigdata-web(){
  #/data/os/app/bigdata-web/tomcat
  #/data/os/app/bigdata-web/app
  app_name=bigdata-web
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='bigdata-web.dev.jjshome.local'
  ContainerIP='172.16.16.41'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-api(){
  #/data/os/app/coa-api/tomcat
  #/data/os/app/coa-api/coa_jjshome_com
  app_name=coa-api
  tomcatDir=tomcat
  projectDir=coa_jjshome_com
  ContainHostname='coa-api.dev.jjshome.local'
  ContainerIP='172.16.16.42'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-api-manager(){
  #/data/os/app/coa-api-manager/tomcat
  #/data/os/app/coa-api-manager/aicp_jjshome_com
  app_name=coa-api-manager
  tomcatDir=tomcat
  projectDir=aicp_jjshome_com
  ContainHostname='coa-api-manager.dev.jjshome.local'
  ContainerIP='172.16.16.43'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-app-api-admin(){
  #/data/os/app/coa-app-api-admin/tomcat
  #/data/os/app/coa-app-api-admin/aicp_jjshome_com
  app_name=coa-app-api-admin
  tomcatDir=tomcat
  projectDir=aicp_jjshome_com
  ContainHostname='coa-app-api-admin.dev.jjshome.local'
  ContainerIP='172.16.16.44'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-gaizhang(){
  #/data/os/app/coa-gaizhang/tomcat
  #/data/os/app/coa-gaizhang/gz_jjshome_com
  app_name=coa-gaizhang
  tomcatDir=tomcat
  projectDir=gz_jjshome_com
  ContainHostname='coa-gaizhang.dev.jjshome.local'
  ContainerIP='172.16.16.45'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-im-api(){
  #/data/os/app/coa-im-api/tomcat_im_api
  #/data/os/app/coa-im-api/im_jjshome_com_api
  app_name=coa-im-api
  tomcatDir=tomcat_im_api
  projectDir=im_jjshome_com_api
  ContainHostname='coa-im-api.dev.jjshome.local'
  ContainerIP='172.16.16.46'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-im-im(){
  #/data/os/app/coa-im-im/tomcat_im
  #/data/os/app/coa-im-im/im_jjshome_com
  app_name=coa-im-im
  tomcatDir=tomcat_im
  projectDir=im_jjshome_com
  ContainHostname='coa-im-im.dev.jjshome.local'
  ContainerIP='172.16.16.47'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-kaipu-backend(){
  #/data/os/app/coa-kaipu-backend/tomcat
  #/data/os/app/coa-kaipu-backend/kp_jjshome_com
  app_name=coa-kaipu-backend
  tomcatDir=tomcat
  projectDir=kp_jjshome_com
  ContainHostname='coa-kaipu-backend.dev.jjshome.local'
  ContainerIP='172.16.16.48'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-kaipu-portal(){
  #/data/os/app/coa-kaipu-portal/tomcat_portal
  #/data/os/app/coa-kaipu-portal/kp_portal_jjshome_com
  app_name=coa-kaipu-portal
  tomcatDir=tomcat_portal
  projectDir=kp_portal_jjshome_com
  ContainHostname='coa-kaipu-portal.dev.jjshome.local'
  ContainerIP='172.16.16.49'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function coa-organizational-structure(){
  #/data/os/app/coa-organizational-structure/tomcat_nhr
  #/data/os/app/coa-organizational-structure/nhr_jjshome_com
  app_name=coa-organizational-structure
  tomcatDir=tomcat_nhr
  projectDir=nhr_jjshome_com
  ContainHostname='coa-organizational-structure.dev.jjshome.local'
  ContainerIP='172.16.16.50'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function coa-ssk(){
  #/data/os/app/coa-ssk/tomcat
  #/data/os/app/coa-ssk/ssk_jjshome_com
  app_name=coa-ssk
  tomcatDir=tomcat
  projectDir=ssk_jjshome_com
  ContainHostname='coa-ssk.dev.jjshome.local'
  ContainerIP='172.16.16.51'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-xd(){
  #/data/os/app/coa-xd/tomcat
  #/data/os/app/coa-xd/xd_jjshome_com
  app_name=coa-xd
  tomcatDir=tomcat
  projectDir=xd_jjshome_com
  ContainHostname='coa-xd.dev.jjshome.local'
  ContainerIP='172.16.16.52'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function coa-zhifu-payment(){
  #/data/os/app/coa-zhifu-payment/tomcat
  #/data/os/app/coa-zhifu-payment/app
  app_name=coa-zhifu-payment
  tomcatDir=tomcat
  projectDir=pay_jjshome_com
  ContainHostname='coa-zhifu-payment.dev.jjshome.local'
  ContainerIP='172.16.16.53'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-daiguanfang(){
  #/data/os/app/fang-daiguanfang/tomcat
  #/data/os/app/fang-daiguanfang/jjsdgf
  app_name=fang-daiguanfang
  tomcatDir=tomcat
  projectDir=jjsdgf
  ContainHostname='fang-daiguanfang.dev.jjshome.local'
  ContainerIP='172.16.16.54'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-dispatcher(){
  #/data/os/app/fang-dispatcher/tomcat
  #/data/os/app/fang-dispatcher/app
  app_name=fang-dispatcher
  tomcatDir=tomcat
  projectDir=app
  ContainHostname='fang-dispatcher.dev.jjshome.local'
  ContainerIP='172.16.16.55'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function fang-esf-fangyuan(){
  #/data/os/app/fang-esf-fangyuan/tomcat
  #/data/os/app/fang-esf-fangyuan/hsl-main
  app_name=fang-esf-fangyuan
  tomcatDir=tomcat
  projectDir=hsl-main
  ContainHostname='fang-esf-fangyuan.dev.jjshome.local'
  ContainerIP='172.16.16.56'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-jjrplus-api(){
  #/data/os/app/fang-jjrplus-api/tomcat
  #/data/os/app/fang-jjrplus-api/jjs-jjrplus
  app_name=fang-jjrplus-api
  tomcatDir=tomcat
  projectDir=jjs-jjrplus
  ContainHostname='fang-jjrplus-api.dev.jjshome.local'
  ContainerIP='172.16.16.57'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-kanfang(){
  #/data/os/app/fang-kanfang/tomcat
  #/data/os/app/fang-kanfang/jjs-kfang
  app_name=fang-kanfang
  tomcatDir=tomcat
  projectDir=jjs-kfang
  ContainHostname='fang-kanfang.dev.jjshome.local'
  ContainerIP='172.16.16.58'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-shcool-house-manager(){
  #/data/os/app/fangdispatcher/tomcat-school
  #/data/os/app/fangdispatcher/app
  app_name=fang-shcool-house-manager
  tomcatDir=tomcat-school
  projectDir=school-main
  ContainHostname='fang-shcool-house-manager.dev.jjshome.local'
  ContainerIP='172.16.16.59'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-wap(){
  #/data/os/app/fang-wap/tomcat_wap
  #/data/os/app/fang-wap/wap
  app_name=fang-wap
  tomcatDir=tomcat_wap
  projectDir=wap
  ContainHostname='fang-wap.dev.jjshome.local'
  ContainerIP='172.16.16.60'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-steward(){
  #/data/os/app/fang-steward/tomcat-steward
  #/data/os/app/fang-steward/com-steward
  app_name=fang-steward
  tomcatDir=tomcat-steward
  projectDir=com-steward
  ContainHostname='fang-steward.dev.jjshome.local'
  ContainerIP='172.16.16.61'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-agent(){
  #/data/os/app/fang-web-agent/tomcat
  #/data/os/app/fang-web-agent/fang-agent
  app_name=fang-web-agent
  tomcatDir=tomcat
  projectDir=fang-agent
  ContainHostname='fang-web-agent.dev.jjshome.local'
  ContainerIP='172.16.16.62'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-cj-hangqing(){
  #/data/os/app/fang-web-cj-hangqing/tomcat
  #/data/os/app/fang-web-cj-hangqing/fang-cjhq
  app_name=fang-web-cj-hangqing
  tomcatDir=tomcat
  projectDir=fang-cjhq
  ContainHostname='fang-web-cj-hangqing.dev.jjshome.local'
  ContainerIP='172.16.16.63'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-esf(){
  #/data/os/app/fang-web-esf/tomcat
  #/data/os/app/fang-web-esf/esf
  app_name=fang-web-esf
  tomcatDir=tomcat
  projectDir=esf
  ContainHostname='fang-web-esf.dev.jjshome.local'
  ContainerIP='172.16.16.64'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-index-page(){
  #/data/os/app/fang-web-index-page/tomcat_home
  #/data/os/app/fang-web-index-page/home
  app_name=fang-web-index-page
  tomcatDir=tomcat_home
  projectDir=home
  ContainHostname='fang-web-index-page.dev.jjshome.local'
  ContainerIP='172.16.16.65'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-manager(){
  #/data/os/app/fang-web-manager/tomcat
  #/data/os/app/fang-web-manager/fang-manager
  app_name=fang-web-manager
  tomcatDir=tomcat
  projectDir=fang-manager
  ContainHostname='fang-web-manager.dev.jjshome.local'
  ContainerIP='172.16.16.66'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-map(){
  #/data/os/app/fang-web-map/tomcat-map
  #/data/os/app/fang-web-map/app
  app_name=fang-web-map
  tomcatDir=tomcat-map
  projectDir=map
  ContainHostname='fang-web-map.dev.jjshome.local'
  ContainerIP='172.16.16.67'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-timer(){
  #/data/os/app/fang-web-timer/tomcat-timer
  #/data/os/app/fang-web-timer/app
  app_name=fang-web-timer
  tomcatDir=tomcat-timer
  projectDir=timer
  ContainHostname='fang-web-timer.dev.jjshome.local'
  ContainerIP='172.16.16.68'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-user-center(){
  #/data/os/app/fang-web-user-center/tomcat
  #/data/os/app/fang-web-user-center/jjs-fang-umc-web
  app_name=fang-web-user-center
  tomcatDir=tomcat
  projectDir=jjs-fang-umc-web
  ContainHostname='fang-web-user-center.dev.jjshome.local'
  ContainerIP='172.16.16.69'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-xiaoqu(){
  #/data/os/app/fang-web-xiaoqu/tomcat
  #/data/os/app/fang-web-xiaoqu/xq
  app_name=fang-web-xiaoqu
  tomcatDir=tomcat
  projectDir=xq
  ContainHostname='fang-web-xiaoqu.dev.jjshome.local'
  ContainerIP='172.16.16.70'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-xinfang(){
  #/data/os/app/fang-web-xinfang/tomcat
  #/data/os/app/fang-web-xinfang/jjs-fang-xf
  app_name=fang-web-xinfang
  tomcatDir=tomcat
  projectDir=jjs-fang-xf
  ContainHostname='fang-web-xinfang.dev.jjshome.local'
  ContainerIP='172.16.16.71'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function fang-web-xinfang-api(){
  #/data/os/app/fang-web-xinfang-api/tomcat
  #/data/os/app/fang-web-xinfang-api/fang-xf-main
  app_name=fang-web-xinfang-api
  tomcatDir=tomcat
  projectDir=fang-xf-main
  ContainHostname='fang-web-xinfang-api.dev.jjshome.local'
  ContainerIP='172.16.16.72'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-web-zufang(){
  #/data/os/app/fang-web-zufang/tomcat
  #/data/os/app/fang-web-zufang/zf
  app_name=fang-web-zufang
  tomcatDir=tomcat
  projectDir=zf
  ContainHostname='fang-web-zufang.dev.jjshome.local'
  ContainerIP='172.16.16.73'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-xinfang-api(){
  #/data/os/app/fang-xinfang-api/tomcat
  #/data/os/app/fang-xinfang-api/xf-api
  app_name='fang-xinfang-api'
  tomcatDir='tomcat'
  projectDir='xf-api'
  ContainHostname='fang-xinfang-api.dev.jjshome.local'
  ContainerIP='172.16.16.74'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-xinfang-core(){
  #/data/os/app/fang-xinfang-core/tomcat
  #/data/os/app/fang-xinfang-core/xf-core
  app_name='fang-xinfang-core'
  tomcatDir='tomcat'
  projectDir='xf-core'
  ContainHostname='fang-xinfang-core.dev.jjshome.local'
  ContainerIP='172.16.16.75'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-xinfang-pm-api-main(){
  #/data/os/app/fang-xinfang-pm-api-main/tomcat
  #/data/os/app/fang-xinfang-pm-api-main/xf-api-main
  app_name='fang-xinfang-pm-api-main'
  tomcatDir='tomcat'
  projectDir='xf-api-main'
  ContainHostname='fang-xinfang-pm-api-main.dev.jjshome.local'
  ContainerIP='172.16.16.76'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-xinfang-pm-system(){
  #/data/os/app/fang-xinfang-pm-system/tomcat
  #/data/os/app/fang-xinfang-pm-system/jjsxm
  app_name='fang-xinfang-pm-system'
  tomcatDir='tomcat'
  projectDir='jjsxm'
  ContainHostname='fang-xinfang-pm-system.dev.jjshome.local'
  ContainerIP='172.16.16.77'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function fang-xinfang-ysl-core(){
  #/data/os/app/fang-xinfang-ysl-core/tomcat
  #/data/os/app/fang-xinfang-ysl-core/ysl-core
  app_name='fang-xinfang-ysl-core'
  tomcatDir='tomcat'
  projectDir='ysl-core'
  ContainHostname='fang-xinfang-ysl-core.dev.jjshome.local'
  ContainerIP='172.16.16.78'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function fang-zhuchang-api(){
  #/data/os/app/fang-zhuchang-api/tomcat
  #/data/os/app/fang-zhuchang-api/zhuchang
  app_name='fang-zhuchang-api'
  tomcatDir='tomcat'
  projectDir='zhuchang'
  ContainHostname='fang-zhuchang-api.dev.jjshome.local'
  ContainerIP='172.16.16.79'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function jinrong-chengjiao(){
  #/data/os/app/jinrong-chengjiao/tomcat
  #/data/os/app/jinrong-chengjiao/jjscj_jjshome_com
  app_name='jinrong-chengjiao'
  tomcatDir='tomcat'
  projectDir='jjscj_jjshome_com'
  ContainHostname='jinrong-chengjiao.dev.jjshome.local'
  ContainerIP='172.16.16.80'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function jinrong-dangan(){
  #/data/os/app/jinrong-dangan/tomcat_dangan
  #/data/os/app/jinrong-dangan/webapp
  app_name='jinrong-dangan'
  tomcatDir='tomcat_dangan'
  projectDir='webapp'
  ContainHostname='jinrong-dangan.dev.jjshome.local'
  ContainerIP='172.16.16.81'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-dangan-new(){
  #/data/os/app/jinrong-dangan-new/tomcat_dangan
  #/data/os/app/jinrong-dangan-new/webapp
  app_name='jinrong-dangan-new'
  tomcatDir='tomcat_dangan'
  projectDir'=webapp'
  ContainHostname='jinrong-dangan-new.dev.jjshome.local'
  ContainerIP='172.16.16.82'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function jinrong-gongdan-api(){
  #/data/os/app/jinrong-gongdan-api/tomcat_api
  #/data/os/app/jinrong-gongdan-api/jjsgd_api_jjshome_com
  app_name='jinrong-gongdan-api'
  tomcatDir='tomcat_api'
  projectDir='jjsgd_api_jjshome_com'
  ContainHostname='jinrong-gongdan-api.dev.jjshome.local'
  ContainerIP='172.16.16.83'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-gongdan-timer(){
  #/data/os/app/jinrong-gongdan-timer/tomcat
  #/data/os/app/jinrong-gongdan-timer/jjsgd_timer_jjshome_com
  app_name='jinrong-gongdan-timer'
  tomcatDir='tomcat'
  projectDir='jjsgd_timer_jjshome_com'
  ContainHostname='jinrong-gongdan-timer.dev.jjshome.local'
  ContainerIP='172.16.16.84'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-gongdan-web(){
  #/data/os/app/jinrong-gongdan-web/tomcat
  #/data/os/app/jinrong-gongdan-web/jjsgd_jjshome_com
  app_name='jinrong-gongdan-web'
  tomcatDir='tomcat'
  projectDir='jjsgd_jjshome_com'
  ContainHostname='jinrong-gongdan-web.dev.jjshome.local'
  ContainerIP='172.16.16.85'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-hetong(){
  #/data/os/app/jinrong-hetong/tomcat
  #/data/os/app/jinrong-hetong/jjsht_jjshome_com
  app_name='jinrong-hetong'
  tomcatDir='tomcat'
  projectDir='jjsht_jjshome_com'
  ContainHostname='jinrong-hetong.dev.jjshome.local'
  ContainerIP='172.16.16.86'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-hezuojigou(){
  #/data/os/app/jinrong-hezuojigou/tomcat
  #/data/os/app/jinrong-hezuojigou/hzjg_jjshome_com
  app_name='jinrong-hezuojigou'
  tomcatDir='tomcat'
  projectDir='hzjg_jjshome_com'
  ContainHostname='jinrong-hezuojigou.dev.jjshome.local'
  ContainerIP='172.16.16.87'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-tax-api(){
  #/data/os/app/jinrong-tax-api/tomcat_api
  #/data/os/app/jinrong-tax-api/jjstax_api_jjshome_com
  app_name='jinrong-tax-api'
  tomcatDir='tomcat_api'
  projectDir='jjstax_api_jjshome_com'
  ContainHostname='jinrong-tax-api.dev.jjshome.local'
  ContainerIP='172.16.16.88'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function jinrong-tax-backend(){
  #/data/os/app/jinrong-tax-backend/tomcat
  #/data/os/app/jinrong-tax-backend/jjstax_jjshome_com
  app_name='jinrong-tax-backend'
  tomcatDir='tomcat'
  projectDir='jjstax_jjshome_com'
  ContainHostname='jinrong-tax-backend.dev.jjshome.local'
  ContainerIP='172.16.16.89'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function key-keyuan(){
  #/data/os/app/key-keyuan/tomcat
  #/data/os/app/key-keyuan/ky_jjshome_com4_ky4
  app_name='key-keyuan'
  tomcatDir='tomcat'
  projectDir='ky_jjshome_com4_ky4'
  ContainHostname='key-keyuan.dev.jjshome.local'
  ContainerIP='172.16.16.90'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-ask-and-answer(){
  #/data/os/app/oa-ask-and-answer/tomcat
  #/data/os/app/oa-ask-and-answer/qa_jjshome_com
  app_name='oa-ask-and-answer'
  tomcatDir='tomcat'
  projectDir='qa_jjshome_com'
  ContainHostname='oa-ask-and-answer.dev.jjshome.local'
  ContainerIP='172.16.16.91'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-funds(){
  #/data/os/app/oa-funds/tomcat
  #/data/os/app/oa-funds/funds
  app_name='oa-funds'
  tomcatDir='tomcat'
  projectDir='funds'
  ContainHostname='oa-funds.dev.jjshome.local'
  ContainerIP='172.16.16.92'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-home-and-hr-web(){
  #/data/os/app/oa-home-and-hr-web/tomcat_home
  #/data/os/app/oa-home-and-hr-web/home_jjshome_com
  app_name='oa-home-and-hr-web'
  tomcatDir='tomcat_home'
  projectDir='home_jjshome_com'
  ContainHostname='oa-home-and-hr-web.dev.jjshome.local'
  ContainerIP='172.16.16.93'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-hr(){
  #/data/os/app/oa-hr/tomcat
  #/data/os/app/oa-hr/hr_jjshome_com
  app_name='oa-hr'
  tomcatDir='tomcat'
  projectDir='hr_jjshome_com'
  ContainHostname='oa-hr.dev.jjshome.local'
  ContainerIP='172.16.16.94'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-hr-portal(){
  #/data/os/app/oa-hr-portal/tomcat_portal
  #/data/os/app/oa-hr-portal/hr_portal_jjshome_com
  app_name='oa-hr-portal'
  tomcatDir='tomcat_portal'
  projectDir='hr_portal_jjshome_com'
  ContainHostname='oa-hr-portal.dev.jjshome.local'
  ContainerIP='172.16.16.95'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-hrworker(){
  #/data/os/app/oa-hrworker/tomcat_worker
  #/data/os/app/oa-hrworker/worker_jjshome_com
  app_name='oa-hrworker'
  tomcatDir='tomcat_worker'
  projectDir='worker_jjshome_com'
  ContainHostname='oa-hrworker.dev.jjshome.local'
  ContainerIP='172.16.16.96'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-lianghua(){
  #/data/os/app/oa-lianghua/tomcat
  #/data/os/app/oa-lianghua/WebRoot
  app_name='oa-lianghua'
  tomcatDir='tomcat'
  projectDir='WebRoot'
  ContainHostname='oa-lianghua.dev.jjshome.local'
  ContainerIP='172.16.16.97'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-system-param(){
  #/data/os/app/oa-system-param/tomcat
  #/data/os/app/oa-system-param/param_jjshome_com
  app_name='oa-system-param'
  tomcatDir='tomcat'
  projectDir='param_jjshome_com'
  ContainHostname='oa-system-param.dev.jjshome.local'
  ContainerIP='172.16.16.98'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function oa-zhugan(){
  #/data/os/app/oa-zhugan/tomcat
  #/data/os/app/oa-zhugan/tomcat1_jjshome_com
  app_name='oa-zhugan'
  tomcatDir='tomcat'
  projectDir='tomcat1_jjshome_com'
  ContainHostname='oa-zhugan.dev.jjshome.local'
  ContainerIP='172.16.16.99'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-app-release(){
  #/data/os/app/platform-app-release/tomcat
  #/data/os/app/platform-app-release/jjs_app
  app_name='platform-app-release'
  tomcatDir='tomcat'
  projectDir='jjs_app'
  ContainHostname='platform-app-release.dev.jjshome.local'
  ContainerIP='172.16.16.100'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-call-center(){
  #/data/os/app/platform-call-center/tomcat
  #/data/os/app/platform-call-center/mc_jjshome_com
  app_name='platform-call-center'
  tomcatDir='tomcat'
  projectDir='mc_jjshome_com'
  ContainHostname='platform-call-center.dev.jjshome.local'
  ContainerIP='172.16.16.101'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-ctpapi(){
  #/data/os/app/platform-ctpapi/tomcat
  #/data/os/app/platform-ctpapi/ctpapi
  app_name='platform-ctpapi'
  tomcatDir='tomcat'
  projectDir='ctpapi/crapapi'
  ContainHostname='platform-ctpapi.dev.jjshome.local'
  ContainerIP='172.16.16.102'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-demand-problem-management(){
  #/data/os/app/platform-demand-problem-management/tomcat
  #/data/os/app/platform-demand-problem-management/demprob
  app_name='platform-demand-problem-management'
  tomcatDir='tomcat'
  projectDir='demprob'
  ContainHostname='platform-demand-problem-management.dev.jjshome.local'
  ContainerIP='172.16.16.103'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-distributed-job-schedule(){
  #/data/os/app/platform-distributed-job-schedule/tomcat
  #/data/os/app/platform-distributed-job-schedule/lts-jobtracker
  app_name='platform-distributed-job-schedule'
  tomcatDir='tomcat'
  projectDir='lts-jobtracker'
  ContainHostname='platform-distributed-job-schedule.dev.jjshome.local'
  ContainerIP='172.16.16.104'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-login(){
  #/data/os/app/platform-login/tomcat
  #/data/os/app/platform-login/jjslogin
  app_name='platform-login'
  tomcatDir='tomcat'
  projectDir='jjslogin'
  ContainHostname='login.dev.jjshome.local'
  ContainerIP='172.16.16.105'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-msg-center-api-main(){
  #/data/os/app/platform-msg-center-api-main/tomcat_msg_api
  #/data/os/app/platform-msg-center-api-main/msg_api_main
  app_name='platform-msg-center-api-main'
  tomcatDir='tomcat_msg_api'
  projectDir='msg_api_main'
  ContainHostname='platform-msg-center-api-main.dev.jjshome.local'
  ContainerIP='172.16.16.106'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-msg-center-api-front(){
  #/data/os/app/platform-msg-center-api-front/tomcat_msg_front
  #/data/os/app/platform-msg-center-api-front/msg_front
  app_name='platform-msg-center-api-front'
  tomcatDir='tomcat_msg_front'
  projectDir='msg_front'
  ContainHostname='platform-msg-center-api-front.dev.jjshome.local'
  ContainerIP='172.16.16.107'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-msg-center-api-timer(){
  #/data/os/app/platform-msg-center-api-timer/tomcat
  #/data/os/app/platform-msg-center-api-timer/msg_api_main
  app_name='platform-msg-center-api-timer'
  tomcatDir='tomcat'
  projectDir='msg_api_main'
  ContainHostname='platform-msg-center-api-timer.dev.jjshome.local'
  ContainerIP='172.16.16.108'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-msg-center-old(){
  #/data/os/app/platform-msg-center-old/tomcat
  #/data/os/app/platform-msg-center-old/msg-center-old
  app_name='platform-msg-center-old'
  tomcatDir='tomcat'
  projectDir='msg-center-old'
  ContainHostname='platform-msg-center-old.dev.jjshome.local'
  ContainerIP='172.16.16.109'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-purview(){
  #/data/os/app/platform-purview/tomcat
  #/data/os/app/platform-purview/jjspurview
  app_name='platform-purview'
  tomcatDir='tomcat'
  projectDir='jjspurview'
  ContainHostname='platform-purview.dev.jjshome.local'
  ContainerIP='172.16.16.110'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-ueditor(){
  #/data/os/app/platform-ueditor/tomcat-ueditor
  #/data/os/app/platform-ueditor/upload_jjshome_com/
  app_name='platform-ueditor'
  tomcatDir='tomcat-ueditor'
  projectDir='upload_jjshome_com'
  ContainHostname='platform-ueditor.dev.jjshome.local'
  ContainerIP='172.16.16.111'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-upload(){
  #/data/os/app/platform-upload/tomcat-upload
  #/data/os/app/platform-upload/upload_jjshome_com
  app_name='platform-upload'
  tomcatDir='tomcat-upload'
  projectDir='upload_jjshome_com'
  ContainHostname='platform-upload.dev.jjshome.local'
  ContainerIP='172.16.16.112'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function platform-workflow(){
  #/data/os/app/platform-workflow/tomcat
  #/data/os/app/platform-workflow/jjswf_jjshome_com
  app_name='platform-workflow'
  tomcatDir='tomcat'
  projectDir='jjswf_jjshome_com'
  ContainHostname='platform-workflow.dev.jjshome.local'
  ContainerIP='172.16.16.113'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function platform-workflow-tmp(){
  #/data/os/app/platform-workflow-tmp/tomcat
  #/data/os/app/platform-workflow-tmp/jjswftemp_jjshome_com
  app_name='platform-workflow-tmp'
  tomcatDir='tomcat'
  projectDir='jjswftemp_jjshome_com'
  ContainHostname='platform-workflow-tmp.dev.jjshome.local'
  ContainerIP='172.16.16.114'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}
function umc-api-main(){
  #/data/os/app/umc-api-main/tomcat
  #/data/os/app/umc-api-main/umc_api_main
  app_name='umc-api-main'
  tomcatDir='tomcat'
  projectDir='umc_api_main'
  ContainHostname='umc-api-main.dev.jjshome.local'
  ContainerIP='172.16.16.115'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function umc-kefu(){
  #/data/os/app/umc-kefu/tomcat
  #/data/os/app/umc-kefu/kf_jjshome_com
  app_name='umc-kefu'
  tomcatDir='tomcat'
  projectDir='kf_jjshome_com'
  ContainHostname='umc-kefu.dev.jjshome.local'
  ContainerIP='172.16.16.116'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function fang-esf-api-main() {
   #/data/os/app/fang-esf-api-main/api-main
  app_name='fang-esf-api-main'
  appDir='api-main'
  ContainHostname='fang-esf-api-main.dev.jjshome.local'
  ContainerIP='172.16.16.117'
  img=${img1}
  javaAppRun ${app_name} ${appDir} ${ContainHostname} ${ContainerIP} ${img}

}
function platform-workflowplatform(){
  #/data/os/app/platform-workflowplatform/tomcat-platform
  #/data/os/app/platform-workflowplatform/flowplatform_jjshome_com
  app_name='platform-workflowplatform'
  tomcatDir='tomcat-platform'
  projectDir='flowplatform_jjshome_com'
  ContainHostname='platform-workflowplatform.dev.jjshome.local'
  ContainerIP='172.16.16.118'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}

function platform-msg-center-api-backend(){
  #/data/os/app/platform-msg-center-api-backend/tomcat_msg_api
  #/data/os/app/platform-msg-center-api-backend/msg_api_main
  app_name='platform-msg-center-api-backend'
  tomcatDir='tomcat_msg_back'
  projectDir='msg_back'
  ContainHostname='platform-msg-center-api-backend.dev.jjshome.local'
  ContainerIP='172.16.16.119'
  img=${img1}

  tomcatRun ${app_name} ${tomcatDir} ${projectDir} ${ContainHostname} ${ContainerIP} ${img}
}


function i() {
  ContainHostname='i.dev.jjshome.local'
  ContainerIP='172.16.16.254'
  img=${img3}

nginxIRun ${ContainHostname} ${ContainerIP} ${img} 
}
function Autostart() { 
  dubbo
  sleep 5
  platform-xdiamond
  sleep 5
  fang-esf-mycat
  sleep 5
  platform-mycat
  sleep 5
  public-memcached 
  sleep 5
  app_redis 
  sleep 5
 
  platform-redis 
  sleep 5
 
  share-session-redis 
  sleep 5
 
  bigdata-redis 
  sleep 5
 
  coa-redis 
  sleep 5
 
  fang-esf-redis 
  sleep 5
 
  fang-web-redis 
  sleep 5
 
  fang-xinfang-redis 
  sleep 5
 
  jinrong-redis 
  sleep 5
 
  key-redis 
  sleep 5
 
  oa-redis 
  sleep 5
 
  umc-redis 
  sleep 5
 
  dubbo_admin 
  sleep 5
 
  oa-system-param 
  sleep 5
 
  oa-hrworker 
  sleep 5
 
  oa-funds 
  sleep 5
 
  fang-community 
  sleep 5
 
  bigdata-api 
  sleep 5
 
  bigdata-biadmin 
  sleep 5
 
  bigdata-dpf 
  sleep 5
 
  bigdata-engin1 
  sleep 5
 
  bigdata-engine1 
  sleep 5
 
  bigdata-fkp-core 
  sleep 5
 
  bigdata-fkp-view 
  sleep 5
 
 #未部署
  #bigdata-logs-for-bigdata 
  sleep 5
 
  bigdata-mongodb-api 
  sleep 5
 
  bigdata-mysql-api 
  sleep 5
 
  bigdata-spagobi1 
  sleep 5
 
  bigdata-web 
  sleep 5
 
  bigdata-nginx 
  sleep 5
 

  oa-zhugan 
  sleep 5
 
  coa-api 
  sleep 5
 
  coa-api-manager 
  sleep 5
 
  coa-app-api-admin 
  sleep 5
 
  coa-gaizhang 
  sleep 5
 
  coa-im-api 
  sleep 5
 
  coa-im-im 
  sleep 5
 
  coa-kaipu-backend 
   sleep 5
 
  coa-kaipu-portal 
   sleep 5
 
  coa-organizational-structure 
   sleep 5
 
  coa-ssk 
   sleep 5
 
  coa-xd 
   sleep 5
 
  coa-zhifu-payment 
   sleep 5
 

  platform-app-release 
   sleep 5
 
  platform-call-center 
   sleep 5
 
  platform-ctpapi 
   sleep 5
 
  platform-demand-problem-management 
   sleep 5
 
  platform-distributed-job-schedule 
   sleep 5
 
  platform-login 
   sleep 5
 
  platform-msg-center-api-main 
   sleep 5
 
  platform-msg-center-api-front 
   sleep 5
 
  platform-msg-center-api-timer 
   sleep 5
 
 platform-msg-center-api-backend
 sleep 5
  platform-msg-center-old 
   sleep 5
 
  platform-purview 
   sleep 5
 
  platform-ueditor 
   sleep 5
 
  platform-upload 
   sleep 5
 
  platform-workflow 
   sleep 5
 
  platform-workflowplatform 
   sleep 5
 
  platform-workflow-tmp 
   sleep 5
 

  fang-esf-api-main 
   sleep 5
 
  fang-daiguanfang 
   sleep 5
 
  fang-dispatcher 
   sleep 5
 
  fang-esf-fangyuan 
   sleep 5
 
  fang-jjrplus-api 
   sleep 5
 
  fang-kanfang 
   sleep 5
 
  fang-shcool-house-manager 
   sleep 5
 
  fang-wap 
   sleep 5
 
  fang-steward 
   sleep 5
 
  fang-web-agent 
   sleep 5
 
  fang-web-cj-hangqing 
   sleep 5
 
  fang-web-esf 
   sleep 5
 
  fang-web-index-page 
   sleep 5
 
  fang-web-manager 
   sleep 5
 
  fang-web-map 
   sleep 5
 
  fang-web-timer 
   sleep 5
 
  fang-web-user-center 
   sleep 5
 
  fang-web-xiaoqu 
   sleep 5
 
 fang-web-xinfang 
   sleep 5
 
  fang-web-xinfang-api 
   sleep 5
 
  fang-web-zufang 
   sleep 5
 
 fang-xinfang-api 
   sleep 5
 
 fang-xinfang-core 
   sleep 5
 
 fang-xinfang-pm-api-main 
   sleep 5
 
 fang-xinfang-pm-system 
   sleep 5
 
 fang-xinfang-ysl-core 
   sleep 5
 
 fang-zhuchang-api 
   sleep 5
 
 umc-api-main 
   sleep 5
 
 umc-kefu 
   sleep 5
 

 oa-ask-and-answer 
   sleep 5
 

 oa-home-and-hr-web 
   sleep 5
 
 oa-hr 
   sleep 5
 
 oa-hr-portal 
   sleep 5
 
 oa-lianghua 
   sleep 5
 
 key-keyuan 
   sleep 5
 
 jinrong-chengjiao 
   sleep 5
 
 jinrong-dangan 
   sleep 5
 
 jinrong-dangan-new 
   sleep 5
 
 jinrong-gongdan-api 
   sleep 5
 
 jinrong-gongdan-timer 
   sleep 5
 
 jinrong-gongdan-web 
   sleep 5
 
 jinrong-hetong 
   sleep 5
 
 jinrong-hezuojigou 
   sleep 5
 
 jinrong-tax-api 
   sleep 5
 
 jinrong-tax-backend 
   sleep 5
 
}

function main() {
case $1 in
   $1)
     $1
 ;;
  "auto")
  Autostart
  ;;

 esac

}

main