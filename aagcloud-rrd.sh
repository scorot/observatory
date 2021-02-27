#!/bin/bash

# Put your settings here
INDISERVER=localhost
RRDDIR=/home/seb/observatory/rrd
IMGDIR=/var/www/html/observatory/images
RRDFILE=$RRDDIR/aagcloud.rrd
HEARTBEAT=1200

COLORS="-c BACK#000000 -c CANVAS#000000 --color FONT#FF0000 --color SHADEA#000000 --color SHADEB#000000"


# Creation of the rrd database
if [ ! -f $RRDFILE ]; then
rrdtool create $RRDFILE \
        DS:sky:GAUGE:$HEARTBEAT:-30:50 \
        DS:rain:GAUGE:$HEARTBEAT:U:U \
        DS:brightness:GAUGE:$HEARTBEAT:U:U \
        DS:temp:GAUGE:$HEARTBEAT:-30:60 \
        DS:wind:GAUGE:$HEARTBEAT:-5:200 \
        DS:cloudCover:GAUGE:$HEARTBEAT:0:100 \
        DS:humidity:GAUGE:$HEARTBEAT:0:100 \
        DS:light:GAUGE:$HEARTBEAT:0:100 \
        RRA:AVERAGE:0.5:1:525600
fi


# Get all data form the AAG cloud Watcher
irsky=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher.sensors.correctedInfraredSky)
rain=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher.sensors.rainSensor)
brightness=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher.sensors.brightnessSensor)
temp=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher.sensors.ambientTemperatureSensor)
wind=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher.readings.windSpeed)


# A usefulel list of AAG Cloud attribute for the limits
# AAG Cloud Watcher.limitsCloud.clear=-5
# AAG Cloud Watcher.limitsCloud.cloudy=0
# AAG Cloud Watcher.limitsCloud.overcast=30
# AAG Cloud Watcher.limitsRain.dry=2000
# AAG Cloud Watcher.limitsRain.wet=1700
# AAG Cloud Watcher.limitsRain.rain=400
# AAG Cloud Watcher.limitsBrightness.dark=2100
# AAG Cloud Watcher.limitsBrightness.light=100
# AAG Cloud Watcher.limitsBrightness.veryLight=0

# WWe have to check if the device is connected. In not we proceed to the connection...
constatus=$(indi_getprop -t 5 -1 AAG\ Cloud\ Watcher.CONNECTION.CONNECT)
if [ $constatus == "Off" ]; then
    # Not connected. Enable connection..."
    indi_setprop -h $INDISERVER -t 5 AAG\ Cloud\ Watcher.CONNECTION.CONNECT=On
fi 

# Compute the cloud coever percentage
cloudCover=100
# Above 0 is overcast
# Between -5 and 0 is cloudy
# Bellow -5 is clear
if [ $(echo "$irsky>0" | bc) == 1 ] ; then cloudCover=100; else if [ $(echo "$irsky<=-5" | bc ) == 1 ]; then cloudCover=0; else cloudCover=$(echo "scale=5;($irsky + 5)/( 5 + 0)*100" | bc); fi; fi; echo $cloudCover;

# Compute the humidity percentage
humidity=100
# Above 2000 is dry
# Between 2000 and 1700 is wet
# Bellow 1700 is rainy 
if [ $(echo "$rain>2000" | bc) == 1 ] ; then humidity=0; else if [ $(echo "$rain<1700" | bc ) == 1 ]; then humidity=100; else humidity=$(echo "scale=5;($rain - 1700)/(2000-1700)*100" | bc); fi; fi; echo $humidity;

#compute the light percentage
light=100
if [ $(echo "$brightness>2100" | bc) == 1 ] ; then light=0; else if [ $(echo "$brightness<0" | bc ) == 1 ]; then light=100; else light=$(echo "scale=5;(2100 - $brightness)/(2100-0)*100" | bc); fi; fi; echo $light;


# Now Store the data into the rrd database
rrdtool update $RRDFILE N:$irsky:$rain:$brightness:$temp:$wind:$cloudCover:$humidity:$light

sleep 2


######################################################################################
#
# Now that the  rrd update is done, we can proceed to the graph creation
#
######################################################################################



# Cloud cover graph

rrdtool graph $IMGDIR/aagcloud-cloudcover-lasthour.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Cloud Cover (last 3 hours)" \
           DEF:clouds=$RRDFILE:cloudCover:AVERAGE \
	   LINE1:clouds#ff0000:clouds \
	   AREA:20#00000a45:Clear \
	   AREA:40#0000AA45:Cloudy:STACK \
	   AREA:42#0000FF45:Overcast:STACK > /dev/null 2>&1 


rrdtool graph $IMGDIR/aagcloud-cloudcover-lastday.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Cloud Cover (last 24 hours)" \
           DEF:clouds=$RRDFILE:cloudCover:AVERAGE \
           LINE1:clouds#ff0000:clouds \
           AREA:20#00000a45:Clear \
           AREA:40#0000AA45:Cloudy:STACK \
           AREA:42#0000FF45:Overcast:STACK > /dev/null 2>&1


# humidity cover graph

rrdtool graph $IMGDIR/aagcloud-humidity-lasthour.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 105 -l -5 -r \
           --vertical-label "Percentage" \
           --title "Rain humidity (last 3 hours)" \
           DEF:HR=$RRDFILE:humidity:AVERAGE \
  	   HRULE:100#FF00FFAA:"100%" \
	   HRULE:0#00FFFFAA:"0%" \
	   LINE1:HR#:0080F0:"HR\\r" \
	   COMMENT:"\\n" \
	   GPRINT:HR:AVERAGE:"Avg HR\: %6.2lf %S\\r"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-humidity-lastday.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           -c BACK#000000 -c CANVAS#000000 --color FONT#FF0000 --color SHADEA#000000 --color SHADEB#000000 \
           --start -86400 --end now \
           -u 105 -l -5 -r \
           --vertical-label "Percentage" \
           --title "Rain humidity (last 24 hours)" \
           DEF:HR=$RRDFILE:humidity:AVERAGE \
           HRULE:100#FF00FFAA:"100%" \
           HRULE:0#00FFFFAA:"0%" \
           LINE1:HR#:0080F0:"HR\\r" \
           COMMENT:"\\n" \
           GPRINT:HR:AVERAGE:"Avg HR\: %6.2lf %S\\r"  > /dev/null 2>&1



# Light graph 

rrdtool graph $IMGDIR/aagcloud-light-lasthour.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Luminosity (last 3 hours)" \
           DEF:light=$RRDFILE:light:AVERAGE LINE1:light#ff0000:light \
	   AREA:30#00000a40:Dark \
	   AREA:40#0000AA40:Light:STACK \
	   AREA:32#0000FF40:VeryLight:STACK > /dev/null 2>&1 


rrdtool graph $IMGDIR/aagcloud-light-lastday.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Luminosity (last 24 hours)" \
           DEF:light=$RRDFILE:light:AVERAGE LINE1:light#ff0000:light \
	   AREA:30#00000a40:Dark \
	   AREA:40#0000AA40:Light:STACK \
	   AREA:32#0000FF40:VeryLight:STACK > /dev/null 2>&1 


# #########################################################################
# Create graph for last 3 hours
##########################################################################

rrdtool graph $IMGDIR/aagcloud-all-lasthour.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           --vertical-label "All Sensors data" \
           --title "AAG Cloud Watcher all sensor datas (last 3 hours)" \
           DEF:sky=$RRDFILE:sky:AVERAGE LINE1:sky#ff0000:"sky" \
           DEF:brightness=$RRDFILE:brightness:AVERAGE LINE1:brightness#00ff00:"Brightness" \
           DEF:rain=$RRDFILE:rain:AVERAGE LINE1:rain#0000ff:"rain" > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-temp-lasthour.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 50 -l -20 -r \
           --vertical-label "temperature (°C)" \
           --title "AAG Cloud Watcher temperature (last 3 hours)" \
           DEF:temp=$RRDFILE:temp:AVERAGE LINE1:temp#FF0000:"Ambient temperature" \
	   HRULE:0#00FFFFAA  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-rain-lasthour.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 3000 -l -2 -r \
           --vertical-label "Cycles" \
           --title "AAG Cloud Watcher rain sensor (last 3 hours)" \
           DEF:rain=$RRDFILE:rain:AVERAGE LINE1:rain#0080FF:"Humidity" AREA:rain#0080FF40 \
  	   HRULE:2100#00ff00AA:"Limit Dry/Wet" \
	   HRULE:1700#DF7401AA:"Limit wet/rainy" \
	   HRULE:400#FF0000AA:"Limit rainy"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-sky-lasthour.png \
        -w 640 -h 320 -a PNG --slope-mode \
        $COLORS \
        --start -10800 --end now \
        -u 30 -l -20 -r \
        --title "AAG Cloud Watcher Sky Temperature (last 3 hours)" \
        --vertical-label "Sky IR temperature (°C)" \
        DEF:sky=$RRDFILE:sky:AVERAGE  LINE1:sky#0080FF:"Sky temperature" AREA:sky#0080FF40 \
        HRULE:-5#00ff00AA:"Limit clear/cloudy" \
        HRULE:0#DF7401AA:"Limit cloudy/overcast" \
        HRULE:30#FF0000AA:"Limit overcast"  > /dev/null 2>&1


# Create graph for last 24 hours
rrdtool graph $IMGDIR/aagcloud-all-lastday.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           --vertical-label "All Sensors data" \
           --title "AAG Cloud Watcher all datas (last 24 hours)" \
           DEF:sky=$RRDFILE:sky:AVERAGE LINE1:sky#ff0000:"sky" \
           DEF:brightness=$RRDFILE:brightness:AVERAGE LINE1:brightness#00ff00:"Brightness" \
           DEF:rain=$RRDFILE:rain:AVERAGE LINE1:rain#0000ff:"rain" > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-temp-lastday.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           -u 50 -l -20 -r \
           --vertical-label "temperature (°C)" \
           --title "AAG Cloud Watcher temperature (last 24 hours)" \
           DEF:temp=$RRDFILE:temp:AVERAGE LINE1:temp#FF0000:"Ambient temperature" \
	   HRULE:0#00FFFFAA  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-rain-lastday.png \
           -w 640 -h 320 -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           -u 3000 -l -2 -r \
           --vertical-label "Cycles" \
           --title "AAG Cloud Watcher rain sensor (last 3 hours)" \
           DEF:rain=$RRDFILE:rain:AVERAGE LINE1:rain#0080FF:"Humidity" AREA:rain#0080FF40 \
  	   HRULE:2100#00ff00AA:"Limit dry/wet" \
	   HRULE:1700#DF7401AA:"Limit wet/rainy" \
	   HRULE:400#FF0000AA:"Limit rainy"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-sky-lastday.png \
    -w 640 -h 320 -a PNG --slope-mode \
    $COLORS \
    --start -86400 --end now \
    -u 30 -l -20 -r \
    --title "AAG Cloud Watcher Sky Temperature (last 24 hours)" \
    --vertical-label "Sky IR temperature (°C)" \
    DEF:sky=$RRDFILE:sky:AVERAGE  LINE1:sky#0080FF:"Sky temperature" AREA:sky#0080FF40 \
    HRULE:-5#00ff00AA:"Limit clear/cloudy" \
    HRULE:0#DF7401AA:"Limit cloudy/overcast" \
    HRULE:30#FF0000AA:"Limit overcast"  > /dev/null 2>&1


# All usefull sensoR data
#
# AAG Cloud Watcher.sensors.infraredSky=-2.1400001049041748047
# AAG Cloud Watcher.sensors.correctedInfraredSky=-8.1169500350952148438
# AAG Cloud Watcher.sensors.infraredSensor=17.420000000000001705
# AAG Cloud Watcher.sensors.rainSensor=2688
# AAG Cloud Watcher.sensors.rainSensorTemperature=21.460229873657226562
# AAG Cloud Watcher.sensors.rainSensorHeater=22.971651077270507812
# AAG Cloud Watcher.sensors.brightnessSensor=28588
# AAG Cloud Watcher.sensors.ambientTemperatureSensor=17.420000076293945312
# AAG Cloud Watcher.readings.windSpeed=0


# All limit for status
#
# AAG Cloud Watcher.limitsCloud.clear=-5
# AAG Cloud Watcher.limitsCloud.cloudy=0
# AAG Cloud Watcher.limitsCloud.overcast=30
# AAG Cloud Watcher.limitsRain.dry=2000
# AAG Cloud Watcher.limitsRain.wet=1700
# AAG Cloud Watcher.limitsRain.rain=400
# AAG Cloud Watcher.limitsBrightness.dark=2100
# AAG Cloud Watcher.limitsBrightness.light=100
# AAG Cloud Watcher.limitsBrightness.veryLight=0
# AAG Cloud Watcher.limitsWind.calm=5
# AAG Cloud Watcher.limitsWind.moderateWind=25

