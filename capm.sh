yum -y install git
yum -y update
# selinux=disable 로 바꾼후 재부팅후 사용해야함  중요
#sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/5.6/fpm/php.ini
sed -i 's/SELINUX=enable/SELINUX=disable/' /etc/selinux/config

yum -y install psmisc
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install php56w php56w-opcache php56w-mysql php56w-gd php56w-mbstring php56w-xml php56w-intl
yum -y install httpd
systemctl enable httpd
systemctl start httpd
rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum -y install php56w php56w-opcache php56w-mysql php56w-gd php56w-mbstring php56w-xml php56w-intl
yum -y install mysql-community-server
systemctl enable mysqld
systemctl start mysqld
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=21/tcp
firewall-cmd --permanent --zone=public --add-port=3306/tcp
firewall-cmd --reload
yum -y install phpmyadmin

echo "ServerName localhost
Include /etc/httpd/conf/sites-enable/*.conf" >> /etc/httpd/conf/httpd.conf
mkdir /etc/httpd/conf/sites-available 
mkdir /etc/httpd/conf/sites-enable

echo "<VirtualHost *:80>
        ServerAdmin     ceo@webend.xyz
	DocumentRoot    /home/intro
        ServerName      192.168.219.119
        ErrorLog        /home/logs/error.log
        CustomLog       /home/logs/access.log combined
        <Directory /home/*>
                Require all granted
                AllowOverride All
        </Directory>
</VirtualHost>" >> /etc/httpd/conf/sites-available/webend.xyz.conf

ln -s /etc/httpd/sites-available/conf/webend.xyz.conf /etc/httpd/sites-enable/conf/webend.xyz.conf

systemctl restart httpd

yum -y install vsftpd
mv /etc/localtime /etc/localtime_backup
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
timedatectl set-timezone Asia/Seoul


7. Database 생성 및 사용자 생성/권한

Database Name : ownclouddb
User Name : owncloud

mysql -u root -p패스워드




 create user 'owncloud'@'%' identified by 'speeds0303';
 create user 'owncloud'@'localhost' identified by 'speeds0303';

 flush privileges;

 create database ownclouddb;
 grant all privileges on ownclouddb.* to 'owncloud'@'%';
 grant all privileges on ownclouddb.* to 'owncloud'@'localhost';



Owncloud 설치

1. Owncloud 10 설치

rpm --import https://download.owncloud.org/download/repositories/production/CentOS_7/repodata/repomd.xml.key
 wget http://download.owncloud.org/download/repositories/production/CentOS_7/ce:stable.repo -O /etc/yum.repos.d/ce:stable.repo
 yum clean expire-cache
 yum -y install owncloud-files



HTTPD 에 Owncloud 관련 설정 및 Data 폴더 설정

반드시 Owncloud 설치 후에 이 작업을 해야 함

1. 설정파일 생성

 vi /etc/httpd/conf.d/owncloud.conf



Alias /owncloud "/var/www/html/owncloud/"

<Directory /var/www/html/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/html/owncloud
 SetEnv HTTP_HOME /var/www/html/owncloud

</Directory>



2. 권한 설정 및 Data 저장공간 설정

Data 저장할 위치를 /data 로 정함

chown -R apache:apache /var/www/html/owncloud
 mkdir /data
 chown -R apache:apache /data
 chmod -R 0770 /data



3. 방화벽 Port 허용

firewall-cmd --permanent --zone=public --add-port=80/tcp
 firewall-cmd --reload



Owncloud 설정

1. Owncloud 설정

https://설치된 IP/owncloud 

사용자 이름, 암호, 데이터 폴더, Database 설정





업로드 용량 제한 변경

 vi /etc/php.ini

수정

 upload_max_filesize = 8G



 vi /var/www/html/owncloud/.htaccess

수정

php_value upload_max_filesize 8G
 php_value post_max_size 8G



백업

1. 백업 대상

Your config/ directory.
Your data/ directory.
Your ownCloud database.



2. Backing Up the config/ and data/ Directories

 rsync --checksum -Aax /var/www/html/owncloud/config /data /oc-backupdir/



3. Backup Database

 mysqldump --single-transaction -h [server] -u [username] -p[password] [db_name] > owncloud-dbbackup_`date +"%Y%m%d"`.bak



기타

1. 만일 신뢰되지 않은 Domain 연결이라고 뜰 때 config.php 파일 수정

 vi /var/www/html/owncloud/config/config.php



'trusted_domains' =>
array (
0 => 'cloud.xxxxx.xx.xxx.xx',
1 => '자신IP 또는 도메인’ 
