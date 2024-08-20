#!/bin/bash
#
# This script allows me to wakeup my NUC from my pi.
# This script must be run as root for etherwake.
#

BASEDIR=$(dirname $0)

# source the config.env where the mac address is
. $BASEDIR/conf.d/private.env

# Send the magick paquet for wol
echo "Send magick paquet to $NUC_MAC ..."
sudo etherwake -i eth0 $NUC_MAC

if [ $? -eq 0 ]; then
    echo "Magick paquet send successfully."
else
    echo "Error when send magick packet."
fi
