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
mkdir /home/logs
systemctl restart httpd

yum -y install vsftpd
mv /etc/localtime /etc/localtime_backup
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
timedatectl set-timezone Asia/Seoul


