# Put your settings here


# Indi server host name
# Ensure the server is already running on this host. 
INDISERVER=localhost

# Base install directory. Default to /home/user/observatory
BASEDIR=$HOME/observatory

# html and css files
HTMLDIR=$BASEDIR/observatory/html
IMGDIR=$BASEDIR/observatory/html/images

# RRD file location
RRDDIR=$BASEDIR/rrd
RRDFILE=$RRDDIR/aagcloud.rrd
HEARTBEAT=1200

# System http server base html directory. It may depend on the distribution or http server.
SYSHTMLDIR=/var/www/html

# RRD Graph colors and image size
COLORS="-c BACK#000000 -c CANVAS#000000 --color FONT#FF0000 --color SHADEA#000000 --color SHADEB#000000"
IMGPROPS="-w 640 -h 320 -a PNG"

