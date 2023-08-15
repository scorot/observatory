#!/bin/bash

BASEDIR=$(dirname $0)
. $BASEDIR/conf.d/private.env

lftp ftp://$FTP_USER:$FTP_PASSWORD@$FTP_ADDRESS -e "mirror -R /var/www/html/observatory/images/ observatory/images/; put -O observatory/ /var/www/html/observatory/weather.txt; bye" >> /dev/null 2>&1

