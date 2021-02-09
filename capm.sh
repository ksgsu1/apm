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

ln -s /etc/httpd/conf/sites-available/webend.xyz.conf /etc/httpd/conf/sites-enable/webend.xyz.conf

mkdir /home/logs
systemctl restart httpd

echo "[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
[client]
default-character-set = utf8
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
character-set-client-handshake=FALSE
init_connect="SET collation_connection = utf8_general_ci"
init_connect="SET NAMES utf8"
character-set-server = utf8
collation-server = utf8_general_ci

[mysqldump]
default-character-set = utf8

[mysql]
default-character-set = utf8

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid" >> /etc/my.cnf

sed -i 's/$cfg['Servers'][$i]['port'] = ''; $cfg['Servers'][$i]['port']= '3306'; >> /etc/phpMyAdmin/config.inc.php
service httpd restart

yum -y install vsftpd
mv /etc/localtime /etc/localtime_backup
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
timedatectl set-timezone Asia/Seoul


