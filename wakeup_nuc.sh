#!/bin/bash
#
# This script allows me to wakeup my NUC from my pi.
# This script must be run as root for etherwake.
#

BASEDIR=$(dirname $0)

# source the config.env where the mac address is
. $BASEDIR/conf.d/private.env

# Send the magick paquet for wol
sudo etherwake -i eth0 $NUC_MAC
