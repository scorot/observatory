#!/bin/bash


# Check the configuration parameters in the config file
source ./config.sh

mkdir -p $BASEDIR && chown $USER.$GROUP $RRDDIR
mkdir -p $RRDDIR && chown $USER.$GROUP $RRDDIR

mkdir -p $HTMLDIR && chown $USER.$GROUP $RRDDIR
mkdir -p $IMGDIR && chown $USER.$GROUP $RRDDIR

mkdir -p /etc/observatory/ && install -m 644 config.sh /etc/observatory/config

install -m644 style.css $HTMLDIR/style.css
install -m644 index.html $HTMLDIR/index.html

# This works with the nginx http server from ubuntu mate on the raspberrypi
ln -s /var/www/html/observatory $OBSDIR/html

# No edit the crontab
echo "Now edit your crontab with 'crontab -e' and add the following line:"
echo
echo " */10 *  *   *   *     $BASEDIR/aagcloud-rrd.sh"
echo

