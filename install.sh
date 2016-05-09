#!/bin/bash

if [ “$(id -u)” != “0” ]; then
  echo "This script must be run as root" 2>&1
  exit 1
else

apt-get install -y dialog > /dev/null
cmd=(dialog --separate-output --checklist "Choose your options:" 22 76 16)
options=(1 "Apache + PHP5" on
         2 "MySQL" off
         3 "PHPMyAdmin" off
         4 "Java 8" off
         5 "Phalcon 1.3.4" off
         6 "ProFTPD + FTPS" off
         7 "PHP 5.4 -> 5.5 Update" off
         8 "User + commands" on
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
#apt-get update
#apt-get -y upgrade
#apt-get -y dist-upgrade
#apt-get install -y htop nano sudo mc
    case $choice in
        1)
                apt-get install -y php5-dev php5-curl php5-mysql libpcre3-dev curl php5-common libapache2-mod-php5 php5-cli
            ;;
        2)
                apt-get install -y mysql-server mysql-client
            ;;
        3)
                apt-get install -y phpmyadmin
            ;;
        4)
                echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
                echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
                apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
		apt-get update
                apt-get install -y oracle-java8-installer
            ;;
        5)
                cd ~
                wget https://github.com/phalcon/cphalcon/archive/phalcon-v1.3.4.tar.gz
                tar -zxvf phalcon-v1.3.4.tar.gz
                rm phalcon-v1.3.4.tar.gz
                ./cphalcon-phalcon-v1.3.4/build/install
                rm cphalcon
                if [ ! -f "/etc/php5/conf.d/30-phalcon.ini" ]; then sudo touch /etc/php5/conf.d/30-phalcon.ini; echo 'extension=phalcon.so' > /etc/php5/conf.d/30-phalcon.ini; fi
                a2enmod rewrite
                service apache2 restart
            ;;
        6)
		OUTPUT="/tmp/input.txt"
		>$OUTPUT
		trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
                apt-get -y install proftpd
		dialog --inputbox "Enter FTP username:" 8 40 2>$OUTPUT
		respose=$?
		username=$(<$OUTPUT)
		echo "$username"
		useradd $username --home /var/www/ -s /bin/false
		chown $username /var/www
		chgrp $username /var/www
		password=`date +%s | sha256sum | base64 | head -c 16`
		echo $username:$password | chpasswd
		echo "Created $username with password: $password for FTPS (Port: 2227)"
                sed -i 's/UseIPv6/#UseIPv6/g' /etc/proftpd/proftpd.conf
                sed -i 's/# DefaultRoot/DefaultRoot/g' /etc/proftpd/proftpd.conf
                sed -i 's/# RequireValidShell/RequireValidShell/g' /etc/proftpd/proftpd.conf
		cd /etc/proftpd/conf.d/
		wget --no-check-certificate https://raw.githubusercontent.com/masowa/skrypty/master/sftp.conf > /dev/null
                sed -i 's/Subsystem sftp \/usr\/lib\/openssh\/sftp-server/# Subsystem sftp \/usr\/lib\/openssh\/sftp-server/g' /etc/ssh/sshd_config
		service proftpd restart
		service ssh restart
            ;;
        7)
                echo 'deb http://packages.dotdeb.org wheezy-php55 all' | tee -a /etc/apt/sources.list
                echo 'deb-src http://packages.dotdeb.org wheezy-php55 all' | tee -a /etc/apt/sources.list
                apt-get update
                apt-get install -y php5-dev php5-curl php5-mysql libpcre3-dev curl php5-common libapache2-mod-php5 php5-cli
        ;;

        8)
                adduser masowa
                cd /usr/bin
                wget --no-check-certificate https://raw.githubusercontent.com/masowa/skrypty/master/zabij > /dev/null
        ;;
    esac
done

fi
