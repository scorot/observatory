#!/bin/bash


# You may need to run

# Check the configuration parameters in the config file
if [ -e ./config.sh ]; then
    source ./config.sh
else
    echo "*** Error. Configuration file config.sh does not exists."
    exit 1
fi
    

mkdir -p $BASEDIR && chown $USER.$USER $RRDDIR
mkdir -p $RRDDIR && chown $USER.$USER $RRDDIR

mkdir -p $HTMLDIR && chown $USER.$USER $RRDDIR
mkdir -p $IMGDIR && chown $USER.$USER $RRDDIR

mkdir -p /etc/observatory && install -m 644 ./config.sh /etc/observatory/config

install -m644 style.css $HTMLDIR/style.css
install -m644 index.html $HTMLDIR/index.html

# This works with the nginx http server from ubuntu mate on the raspberrypi
if [ ! -d $SYSHTMLDIR/observatory ] || [ ! -h $SYSHTMLDIR/observatory ]; then
    echo "I need super user passwod to enable the html page..."
    sudo ln -s $SYSHTMLDIR/observatory $BASEDIR/html
fi

# No edit the crontab
echo "Now edit your crontab with 'crontab -e' and add the following line:"
echo
echo " */10 *  *   *   *     $BASEDIR/aagcloud-rrd.sh"
echo

echo "Once the crontab has been modified ."
echo "Wait for 10 minutes and open a web browser to : http://$(hostname -I | cut -d ' ' -f 1)/observatory"
echo

