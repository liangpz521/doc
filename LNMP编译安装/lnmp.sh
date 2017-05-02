#!/bin/bash
#############yum############################
/etc/init.d/iptables stop   
chkconfig iptables off      
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
/usr/sbin/setenforce 0   
##############################################
echo -e "\033[32m system is yuming,please waiting about 5 minutes!!!!!!\033[0m"
yum -y install make* cmake gcc* curl curl-devel wget autoconf automake bzip2-devel ncurses-devel libjpeg-devel libpng-devel libtiff-devel freetype-devel pam-devel kernel perl perl libmcrypt libmcrypt-devel libmhash libmhash-devel gd* libxml2* openssl* mysql-devel  libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2  ncurses ncurses-devel libidn libidn-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers lrzsz pcre-devel openssl-devel 
#############nginx############################
wget -N http://nginx.org/download/nginx-1.6.3.tar.gz -P /usr/local/src/
groupadd www
useradd www -g www
cd /usr/local/src/ 
tar -zxf nginx-1.6.3.tar.gz
cd nginx-1.6.3
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
#############mysql#################################
wget -N http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.43.tar.gz -P /usr/local/src/ 
groupadd mysql
useradd mysql -g mysql
cd /usr/local/src/
tar -zxf mysql-5.5.43.tar.gz
cd mysql-5.5.43
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql_s02 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_UNIX_ADDR=/usr/local/mysql_s02/tmp/mysql.sock -DMYSQL_TCP_PORT=3308 
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: cmake false\033[0m"
    exit 1
fi
make && make install 
if [ $? -eq 0 ] ;then
     echo -e "\033[32m mysql  install ok \033[0m"
	else 
	echo -e "\033[31m mysql install false\033[0m"
	exit 1
fi
chmod +x /usr/local/mysql_s02
touch /usr/local/mysql_s02/data/mysql.pid
chown -R mysql:mysql /usr/local/mysql_s02 
ln -s /usr/local/mysql_s02/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
cp support-files/my-large.cnf  /usr/local/mysql_s02/my.cnf
cp support-files/mysql.server /etc/init.d/mysql_s02
sed -i 's#$bindir/mysqld_safe --datadir="$datadir"#$bindir/mysqld_safe --defaults-file=/usr/local/mysql_s02/my.cnf#g' /etc/init.d/mysql_s02
sed '/skip-external-locking/i\default-storage-engine=INNODB' -i /usr/local/mysql_s02/my.cnf
sed '/skip-external-locking/i\innodb_file_per_table=1' -i /usr/local/mysql_s02/my.cnf
sed '/skip-external-locking/i\pid-file=/usr/local/mysql_s02/data/mysql.pid' -i /usr/local/mysql_s02/my.cnf
chmod 755 /etc/init.d/mysql_s02
/usr/local/mysql_s02/scripts/mysql_install_db --defaults-file=/usr/local/mysql_s02/my.cnf --basedir=/usr/local/mysql_s02 --datadir=/usr/local/mysql_s02/data --user=mysql --pid-file=/usr/local/mysql_s02/data/mysql.pid
sleep 5
/etc/init.d/mysql_s02 start
chkconfig --add mysql_s02
chkconfig --level 345 mysql_s02 on
###########################php########################
wget http://jaist.dl.sourceforge.net/project/autonpfmp/NPFMP/libmcrypt-2.5.8.tar.gz -P /usr/local/src/ 
cd /usr/local/src/ 
tar -zxvf libmcrypt-2.5.8.tar.gz
cd /usr/local/src/libmcrypt-2.5.8
./configure --prefix=/usr/local 
make && make install 
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.9.2.tar.gz  -P /usr/local/src/ 
cd /usr/local/src/
tar -zxf libiconv-1.9.2.tar.gz
cd libiconv-1.9.2
./configure --prefix=/usr/local/libiconv 
make && make install   
ln -s /usr/local/lib/libiconv.so.2 /lib64/
/sbin/ldconfig
cp /usr/lib64/libldap* /usr/lib/
wget -N http://mirrors.sohu.com/php/php-5.4.41.tar.gz -P /usr/local/src/ 
cd /usr/local/src/
tar -zxf php-5.4.41.tar.gz 
cd php-5.4.41
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local/libiconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --enable-short-tags --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop -enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable--sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext
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
cp /usr/local/src/php-5.4.41/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
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
wget -N http://soft.vpser.net/web/imagemagick/ImageMagick-6.7.1-6.tar.gz -P /usr/local/src 
cd /usr/local/src
tar -zxf ImageMagick-6.7.1-6.tar.gz 
cd ImageMagick-6.7.1-6
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
wget http://pecl.php.net/get/imagick-3.1.0RC2.tgz -P /usr/local/src 
cd /usr/local/src
tar -xzvf imagick-3.1.0RC2.tgz
cd imagick-3.1.0RC2
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
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/imagick.so#g' -i  /usr/local/php/etc/php.ini
#######################eaccelerator################
wget  http://soft.vpser.net/web/eaccelerator/eaccelerator-eaccelerator-42067ac.tar.gz -P /usr/local/src  
cd /usr/local/src  
tar zxvf eaccelerator-eaccelerator-42067ac.tar.gz
cd eaccelerator-eaccelerator-42067ac/
/usr/local/php/bin/phpize  
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config  
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: eaccelerrator configure false\033[0m"
    exit 1
else
   echo -e "\033[32m eacclerator configure successful\033[0m"
fi
make && make install  
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: eaccelerrator install false\033[0m"
    exit 1
else
   echo -e "\033[32m eacclerator install successful\033[0m"
fi
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/eaccelerator.so#g' -i  /usr/local/php/etc/php.ini
#############igbinary######################################
wget https://nodeload.github.com/phadej/igbinary/zip/master -P /usr/local/src/
cd /usr/local/src/
unzip master
cd igbinary-master/
/usr/local/php/bin/phpize
./configure CFLAGS="-O2 -g" --enable-igbinary --with-php-config=/usr/local/php/bin/php-config
if [ $? != 0 ] ;then
echo -e "\033[31m Error: igbinary configure false\033[0m"
    exit 1
else
   echo -e "\033[32m  igbinary configure successful\033[0m"
fi
make && make install
if [ $? != 0 ] ;then
    echo -e "\033[31m Error: igbinary install false\033[0m"
    exit 1
else
   echo -e "\033[32m igbinary install successful\033[0m"
fi
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/igbinary.so#g' -i  /usr/local/php/etc/php.ini
###################phpredis####################################
cd /usr/local/src 
unzip phpredis-develop.zip  
cd phpredis-develop
/usr/local/php/bin/phpize
./configure --enable-redis-igbinary --with-php-config=/usr/local/php/bin/php-config 
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
sed 's#; End:#; End:\nextension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/redis.so#g' -i  /usr/local/php/etc/php.ini
/usr/local/nginx/sbin/nginx -s reload
/etc/init.d/php-fpm restart
echo -e "\033[32m ALL SOFTWARE is COMPLETED,OK OK OK OK !!!!!!!! \033[0m"
