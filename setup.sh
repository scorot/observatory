#!/bin/bash


# Check the configuration parameters in the config file
if [ -e ./conf.d/config.env ]; then
    source ./conf.d/config.env
else
    echo "*** Error. Configuration file config.env does not exists."
    exit 1
fi
    

mkdir -p $BASEDIR && chown $USER.$USER $RRDDIR
mkdir -p $RRDDIR && chown $USER.$USER $RRDDIR

mkdir -p $HTMLDIR && chown $USER.$USER $RRDDIR
mkdir -p $IMGDIR && chown $USER.$USER $RRDDIR


install -m644 style.css $HTMLDIR/style.css
install -m644 index.php $HTMLDIR/index.php
install -m755 status.php $HTMLDIR/status.php

# This works with the nginx http server from ubuntu mate and RaspberryPi OS
# on the raspberrypi
#if [ ! -d $SYSHTMLDIR/observatory ] || [ ! -h $SYSHTMLDIR/observatory ]; then
#    echo "I need super user passwod to enable the html page..."
#    sudo ln -s $SYSHTMLDIR/observatory $BASEDIR/html
#fi

# No edit the crontab
echo "Now edit your crontab with 'crontab -e' and add the following line:"
echo
echo " */5 *  *   *   *     $BASEDIR/aagcloud-rrd.sh"
echo " */5 *  *   *   *     $BASEDIR/owm-send.sh > /dev/null 2>&1"
echo " */5 *  *   *   *     $BASEDIR/wunder-send.sh > /dev/null 2>&1"
echo

echo "Once the crontab has been modified ."
echo "Wait for 5 minutes and open a web browser to : http://$(hostname -I | cut -d ' ' -f 1)/observatory"
echo

