#!/bin/bash
#############yum############################
/etc/init.d/iptables stop
chkconfig iptables off   
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
/usr/sbin/setenforce 0
##############################################
echo -e "\033[32m system is yuming,please waiting about 5 minutes!!!!!!\033[0m"
yum -y install make* cmake gcc* curl curl-devel wget autoconf automake bzip2-devel ncurses-devel \
libjpeg-devel libpng-devel libtiff-devel freetype-devel pam-devel kernel perl perl libmcrypt libmcrypt-devel \
libmhash libmhash-devel gd* libxml2* openssl* mysql-devel  libpng libpng-devel libxml2 libxml2-devel zlib \
zlib-devel glibc glibc-devel glib2 glib2-devel bzip2  ncurses ncurses-devel libidn libidn-devel openldap \
openldap-devel nss_ldap openldap-clients openldap-servers lrzsz pcre-devel openssl-devel
#############pcre#############################
cd /usr/local/src
tar -zxvf pcre-8.10.tar.gz 
cd pcre-8.10
./configure 
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: pcre config false\033[0m"
    exit 1
fi
make && make install 
if [ $? -eq 0 ] ;then
     echo -e "\033[32m pcre  install ok \033[0m"
        else 
        echo -e "\033[31m pcre install false\033[0m"
        exit 1
fi
#############nginx############################
#wget -N http://nginx.org/download/nginx-1.8.1.tar.gz -P /usr/local/src/
groupadd www
useradd www -g www
cd /usr/local/src
tar -zxf nginx-1.8.1.tar.gz
cd nginx-1.8.1
./configure --prefix=/usr/local/nginx
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: nginx config false\033[0m"
    exit 1
fi
make && make install
if [ $? -eq 0 ] ;then
     echo -e "\033[32m nginx  install ok \033[0m"
        else 
        echo -e "\033[31m nginx install false\033[0m"
        exit 1
fi
sed -i 's/#user  nobody/user  www www/g' /usr/local/nginx/conf/nginx.conf
sed -i '45s#index  index.html index.htm#index  index.html index.htm index.php#g' /usr/local/nginx/conf/nginx.conf
sed -i '65,71s/#//g' /usr/local/nginx/conf/nginx.conf
sed -i 's#/scripts#$document_root#g' /usr/local/nginx/conf/nginx.conf
sed -i '/fastcgi_params;/a\include fastcgi.conf;'  /usr/local/nginx/conf/nginx.conf
/usr/local/nginx/sbin/nginx
echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.local
###########################php########################
#wget http://jaist.dl.sourceforge.net/project/autonpfmp/NPFMP/libmcrypt-2.5.8.tar.gz -P /usr/local/src/
cd /usr/local/src/
tar -zxvf libmcrypt-2.5.8.tar.gz
cd /usr/local/src/libmcrypt-2.5.8
./configure --prefix=/usr/local
make && make install
#wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.9.2.tar.gz  -P /usr/local/src/
cd /usr/local/src/
tar -zxf libiconv-1.9.2.tar.gz
cd libiconv-1.9.2
./configure --prefix=/usr/local
make && make install   
ln -s /usr/local/lib/libiconv.so.2 /lib64/
/sbin/ldconfig
cp /usr/lib64/libldap* /usr/lib/
#wget -N http://mirrors.sohu.com/php/php-5.4.41.tar.gz -P /usr/local/src/
echo "/usr/local/lib" >>/etc/ld.so.conf
ldconfig
cd /usr/local/src/
tar -zxf php-7.0.7.tar.gz
cd php-7.0.7
./configure \
--prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--enable-opcache \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--enable-short-tags \
--with-libxml-dir \
--enable-opcache \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--with-gettext

if [ $? != 0 ] ;then
    echo -e "\033[31m Error: php configure false\033[0m"
    exit 1
fi
make ZEND_EXTRA_LIBS='-liconv' && make install
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: php install false\033[0m"
    exit 1
else
   echo -e "\033[32m php install successful\033[0m"
fi
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
ln -s /usr/local/php/bin/php /usr/bin/
cp /usr/local/src/php-7.0.7/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
/etc/init.d/php-fpm start
sed -i 's#disable_functions =#disable_functions =passthru,exec,system,popen,chroot,escapeshellcmd,escapeshellarg,shell_exec,proc_open,proc_get_status#g' /usr/local/php/etc/php.ini
sed -i 's#max_execution_time = 30#max_execution_time = 3000#g' /usr/local/php/etc/php.ini
sed -i 's#;default_charset = "UTF-8"#default_charset = "UTF-8"#g' /usr/local/php/etc/php.ini
sed -i 's#;date.timezone =#date.timezone = Asia/Shanghai#g' /usr/local/php/etc/php.ini
mv /usr/local/php/etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf.bak
cat > /usr/local/php/etc/php-fpm.conf << E0F
[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = notice
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 5s
daemonize = yes
[www]
listen = 127.0.0.1:9000
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = nobody
listen.group = nobody
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 256
pm.start_servers = 125
pm.min_spare_servers = 50
pm.max_spare_servers = 150
request_terminate_timeout = 0
request_slowlog_timeout = 0
slowlog = log/$pool.log.slow
rlimit_files = 65535
rlimit_core = 0
chroot =
chdir =
catch_workers_output = yes
php_flag[display_errors] = off
env [LD_LIBRARY_PATH]= /usr/lib:/lib:/usr/local/lib
E0F
cd  /usr/local/nginx/html/
cat > index.php << E0F
<?php  
phpinfo();  
?>  
E0F
##########imagemagick######################
#wget -N http://soft.vpser.net/web/imagemagick/ImageMagick-6.7.1-6.tar.gz -P /usr/local/src
cd /usr/local/src
tar -zxf ImageMagick-7.0.1-6.tar.gz
cd ImageMagick-7.0.1-6
./configure -prefix=/usr/local/ImageMagick
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: ImageMagick configure false\033[0m"
    exit 1
else
   echo -e "\033[32m ImageMagick configure successful\033[0m"
fi
make && make install
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: ImageMagick install false\033[0m"
    exit 1
else
   echo -e "\033[32m ImageMagick install  successful\033[0m"
fi
#wget http://pecl.php.net/get/imagick-3.1.0RC2.tgz -P /usr/local/src
cd /usr/local/src
tar -xzvf imagick-3.4.1.tgz 
cd imagick-3.4.1
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/ImageMagick
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: Imagick configure false\033[0m"
    exit 1
else
   echo -e "\033[32m Imagick configure successful\033[0m"
fi
make && make install  
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: Imagick install false\033[0m"
    exit 1
else
   echo -e "\033[32m Imagick install successful\033[0m"
fi
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/imagick.so#g' -i  /usr/local/php/etc/php.ini
###################phpredis####################################
cd /usr/local/src
unzip php7.zip
cd phpredis-php7
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
if [ $? != 0 ] ;then
echo -e "\033[31m Error: redis-igbinary configure false\033[0m"
    exit 1
else
   echo -e "\033[32m redis-igbinary configure successful\033[0m"
fi
make && make install
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: redis-igbinary install false\033[0m"
    exit 1
else
   echo -e "\033[32m redis-igbinary install successful\033[0m"
fi
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/redis.so#g' -i  /usr/local/php/etc/php.ini
###############################################swoole###################################
cd /usr/local/src
tar -zxvf swoole-1.8.5-stable.tar.gz
cd swoole-src-swoole-1.8.5-stable
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
if [ $? != 0 ] ;then
echo -e "\033[31m Error: swoole configure false\033[0m"
    exit 1
else
   echo -e "\033[32m swoole configure successful\033[0m"
fi
make && make install
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: swoole install false\033[0m"
    exit 1
else
   echo -e "\033[32m swoole install successful\033[0m"
fi
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/swoole.so#g' -i  /usr/local/php/etc/php.ini
/usr/local/nginx/sbin/nginx -s reload
/etc/init.d/php-fpm restart
echo -e "\033[32m ALL SOFTWARE is COMPLETED,OK OK OK OK !!!!!!!! \033[0m"

