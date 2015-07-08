FROM debian:jessie
MAINTAINER Ronmi Ren <ronmi.ren@gmail.com>

ENV PHPBREW_PHP=php-5.3.29 PHPBREW_ROOT=/home/bb/.phpbrew PHPBREW_HOME=/home/bb/.phpbrew \
PATH=/home/bb/.phpbrew/php/php-5.3.29/bin:/home/bb/.phpbrew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN echo "dash dash/sh boolean false" | debconf-set-selections && dpkg-reconfigure --frontend=noninteractive dash
RUN \
echo mysql-server mysql-server/root_password password 1234 | debconf-set-selections && \
echo mysql-server mysql-server/root_password_again password 1234 | debconf-set-selections && \
echo 'deb http://debian.office.rde/debian jessie main' > /etc/apt/sources.list && \
echo 'deb http://debian.office.rde/security jessie/updates main' >> /etc/apt/sources.list && \
apt-get update && \
apt-get install -y sudo php5-cli wget build-essential buildbot-slave \
        libxslt-dev libssl-dev libbz2-dev libcurl4-gnutls-dev \
        libenchant-dev libjpeg-dev libpng12-dev libgd-dev \
        libgmp-dev libc-client-dev libicu-dev libmcrypt-dev \
        firebird-dev unixodbc-dev postgresql-server-dev-all \
        libreadline-dev libsqlite3-dev libmhash-dev libtidy-dev \
        libexpat-dev php-pear autoconf nginx mysql-server redis-server  \
        gearman memcached && \
apt-get clean && \
mkdir /usr/include/freetype2/freetype && \
ln -fs /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/ && \
ln -s `dpkg -L libgmp-dev|grep -F gmp.h` /usr/include/gmp.h && \
wget -O /usr/local/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew && \
adduser --shell /bin/bash --disabled-password --gecos ,,, bb && \
echo 'bb ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_bb && \
chmod a+wx /usr/local/bin/phpbrew && \
chown bb:bb /usr/local/bin/phpbrew

USER bb
RUN \
phpbrew init && \
phpbrew self-update && \
phpbrew update && \
echo 'source /home/bb/.phpbrew/bashrc' | tee -a /home/bb/.bashrc && \
phpbrew --debug install 5.3 +default +gd=shared +iconv +gmp +intl +phar +pcre +dbs \
+mb +tidy +xml_all +zlib +gettext -- --with-xpm-dir=/usr --enable-gd-natf && \
echo 'export PHPBREW_ROOT=/home/bb/.phpbrew' | tee -a /home/bb/.bashrc | tee -a /home/bb/.phpbrew/bashrc | tee -a /home/bb/.phpbrew/init && \
echo 'export PHPBREW_HOME=/home/bb/.phpbrew' | tee -a /home/bb/.bashrc | tee -a /home/bb/.phpbrew/bashrc | tee -a /home/bb/.phpbrew/init && \
echo "export PHPBREW_PHP=$(phpbrew list | grep -v system | sed 's/^..//' | sed -r 's/[[:space:]]//g')" | \
tee -a /home/bb/.bashrc | tee -a /home/bb/.phpbrew/bashrc | tee -a /home/bb/.phpbrew/init && \
echo -n 'export PHPBREW_PATH=' | tee -a /home/bb/.bashrc | tee -a /home/bb/.phpbrew/bashrc | tee -a /home/bb/.phpbrew/init && \
find /home/bb/.phpbrew/php -maxdepth 2 -mindepth 2 -name 'bin' | tee -a /home/bb/.bashrc | tee -a /home/bb/.phpbrew/bashrc | tee -a /home/bb/.phpbrew/init && \
source /home/bb/.phpbrew/bashrc && \
source /home/bb/.phpbrew/init && \
source /home/bb/.bashrc && \
phpbrew switch 5.3.29 && \
phpbrew -d ext install gd && \
buildslave create-slave /home/bb master php5.3 slave
WORKDIR /home/bb
ADD start.sh /home/bb/start.sh
RUN sudo chmod 777 /home/bb/start.sh
#ENTRYPOINT ["buildslave", "start", "--nodaemon", "/home/bb"]
CMD ["/home/bb/start.sh"]