#!/bin/bash
source /home/bb/.phpbrew/init
source /home/bb/.phpbrew/bashrc 
source /home/bb/.bashrc
phpbrew switch 5.3.29 ; php -v
sudo service nginx restart
sudo service redis-server restart
sudo service memcached restart
sudo service gearman-job-server restart
sudo service mysql restart
/bin/bash
