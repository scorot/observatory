#!/bin/bash

BASEDIR=$(dirname $0)

# Read the settings in the config file
if [ ! -e $BASEDIR/conf.d/config.env ]; then
	source $BASEDIR/conf.d/config.env 
else

# Or else put your settings here
INDISERVER=localhost
RRDDIR=/home/pi/observatory/rrd
IMGDIR=/var/www/html/observatory/images
WEATHERWATCHER=/var/www/html/observatory/weather.txt
WEATHERLOGGER=/var/www/html/observatory/weatherlog.txt
AAGRRDFILE=$RRDDIR/aagcloud.rrd
OWMRRDFILE=$RRDDIR/owm.rrd
LOCALRRDFILE=$RRDDIR/local.rrd
HEARTBEAT=1200

COLORS="-c BACK#000000 -c CANVAS#000000 --color FONT#FF0000 --color SHADEA#000000 --color SHADEB#000000"
IMG_SIZE="-w 480 -h 240"
fi

# Read the api keys and station data from config.env file
. $BASEDIR/conf.d/private.env


# Creation of the rrd database if not exists
if [ ! -f $AAGRRDFILE ]; then
rrdtool create $AAGRRDFILE \
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


# Create the rrd for the Open Weather Map service if not exists
if [ ! -f $OWMRRDFILE ]; then
rrdtool create $OWMRRDFILE \
        DS:forecast:GAUGE:$HEARTBEAT:-5:8000 \
        DS:temperature:GAUGE:$HEARTBEAT:-30:60 \
        DS:pressure:GAUGE:$HEARTBEAT:0:1200 \
        DS:humidity:GAUGE:$HEARTBEAT:-5:105 \
        DS:wind:GAUGE:$HEARTBEAT:-5:200 \
        DS:dewpoint:GAUGE:$HEARTBEAT:-30:60 \
        RRA:AVERAGE:0.5:1:525600
fi

# Create the rrd for the local sensors (bme280 and anemometer)
if [ ! -f $LOCALRRDFILE ]; then
rrdtool create $LOCALRRDFILE \
        DS:temperature:GAUGE:$HEARTBEAT:-30:60 \
        DS:pressure:GAUGE:$HEARTBEAT:0:1200 \
        DS:humidity:GAUGE:$HEARTBEAT:-5:105 \
        DS:wind:GAUGE:$HEARTBEAT:-5:200 \
        DS:gust:GAUGE:$HEARTBEAT:-5:200 \
        DS:dewpoint:GAUGE:$HEARTBEAT:-30:60 \
        RRA:AVERAGE:0.5:1:525600
fi

# First We have to check if the device is connected. If not we proceed to the connection...
constatus=$(indi_getprop -t 10 -1 AAG\ Cloud\ Watcher\ NG.CONNECTION.CONNECT)
if [ "$constatus" = "Off" ]; then
    # Not connected. Enable connection..."
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.CONNECTION.CONNECT=On
    sleep 6
    # Set some properties and constants
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k2=100
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k1=33
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k2=200
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k3=75
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k4=70
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k5=80
    indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.WEATHER_CLOUD.MIN_OK=-5
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.limitsCloud.clear=-6

    # si temperature superieure a 25
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k1=35
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k2=90
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k3=75
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k4=80
    #indi_setprop -h $INDISERVER -t 10 AAG\ Cloud\ Watcher\ NG.skyCorrection.k5=80
    sleep 5
fi 



# Get all data form the AAG cloud Watcher
irsky=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher\ NG.sensors.correctedInfraredSky)
rain=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher\ NG.sensors.rainSensor)
brightness=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher\ NG.sensors.brightnessSensor)
temp=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher\ NG.sensors.ambientTemperatureSensor)
wind=$(indi_getprop -h $INDISERVER -t 10 -1 AAG\ Cloud\ Watcher\ NG.readings.windSpeed)


## Now we get some extra data from OpenWeatherMap
#constatus=$(indi_getprop -h $INDISERVER -t 10 -1 OpenWeatherMap.CONNECTION.CONNECT)
#if [ $constatus == "Off" ]; then 
#    indi_setprop -h $INDISERVER -t 10 OpenWeatherMap.CONNECTION.CONNECT=On
#    sleep 5
#fi
#
#indi_setprop -h $INDISERVER -t 10 OpenWeatherMap.WEATHER_REFRESH.REFRESH=On
#sleep 2

## Get the data from the OpenWeatherMap indi driver
#wind=$(indi_getprop -h $INDISERVER -1 OpenWeatherMap.WEATHER_PARAMETERS.WEATHER_WIND_SPEED)
#forecast=$(indi_getprop -h $INDISERVER -1 OpenWeatherMap.WEATHER_PARAMETERS.WEATHER_FORECAST)
#temperature=$(indi_getprop -h $INDISERVER -1 OpenWeatherMap.WEATHER_PARAMETERS.WEATHER_TEMPERATURE)
#pressure=$(indi_getprop -h $INDISERVER -1 OpenWeatherMap.WEATHER_PARAMETERS.WEATHER_PRESSURE)
#humidity=$(indi_getprop -h $INDISERVER -1 OpenWeatherMap.WEATHER_PARAMETERS.WEATHER_HUMIDITY)


# Or we can get the data from the OpenWeatherMap API
DATA=$(/home/pi/observatory/owm_observatory.py)
wind=$(echo $DATA | awk -F';' '{print $1'})
forecast=$(echo $DATA | awk -F';' '{print $4'})
pressure=$(echo $DATA | awk -F';' '{print $5'})
temperature=$(echo $DATA | awk -F';' '{print $6'})
humidity=$(echo $DATA | awk -F';' '{print $7'})


# Get data from my bme280
DATA=$(cat /var/log/anemometer.txt)
localtemperature=$(echo $DATA | awk -F';' '{print $2'})
localhumidity=$(echo $DATA | awk -F';' '{print $4'})
localpressure=$(echo $DATA | awk -F';' '{print $6'})
#
# if bme280 fails, I use owm data instead...
#localpressure=$pressure
#localtemperature=$temperature
#localhumidity=$humidity

# https://en.wikipedia.org/wiki/Dew_point#Simple_approximation
# Td = T - ((100 - RH)/5.)
dewpoint=$(echo "$localtemperature - ((100 - $localhumidity)/5)" | bc)


# or a more precise methode given on the same wikipedia page:
# https://en.wikipedia.org/wiki/Dew_point#Calculating_the_dew_point
#gamma=$(echo "l($localhumidity/100.) + (18.678*$localtemperature / (257.14+$localtemperature))" | bc -l)
#dewpoint=$(echo "scale=2;(257.14*$gamma) / (18.678-$gamma)" | bc -l)

# Get data from anemometer
DATA=$(cat /var/log/anemometer.txt)
localwind=$(echo $DATA | awk -F';' '{print $1'})
localwind2mn=$(echo $DATA | awk -F';' '{print $7'})
localwindmph=$(echo $DATA | awk -F';' '{print $3'})
localwind2mnmph=$(echo $DATA | awk -F';' '{print $5'})

date=$(date +%s)

# Send local datas to owm in a separate script owm-send.sh
echo "curl -X POST -H "'"Content-Type: application/json"'" -d '[{ "'"station_id"'" : \"$OWM_STATION_ID\",  "'"dt"'" : $date,  "'"temperature"'" : $localtemperature,  "'"pressure"'" : $localpressure, "'"humidity"'" : $localhumidity }]' http://api.openweathermap.org/data/3.0/measurements?appid=$OWM_API_KEY" > /home/pi/observatory/owm-send.sh

# Send local datas to wunderground in a separate script wunder-send.sh
# but convert to imperial units before
pressureinch=$(echo "scale=5;$localpressure*0.02953" | bc)
temperaturef=$(echo "scale=2;$localtemperature*9.0/5.0+32.0" |bc)
dewpointf=$(echo "scale=2;$dewpoint*9.0/5.0+32.0" |bc)
echo "curl -X GET \"https://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?ID=$WUNDER_STATION_ID&PASSWORD=$WUNDER_PASSWORD&dateutc=now&humidity=$localhumidity&baromin=$pressureinch&tempf=$temperaturef&dewptf=$dewpointf&action=updateraw\"" > /home/pi/observatory/wunder-send.sh


# Now Store the owm data into the rrd database
rrdtool update $OWMRRDFILE N:$forecast:$temperature:$pressure:$humidity:$wind:$dewpoint

# Now Store the local sensors data into the rrd database
rrdtool update $LOCALRRDFILE N:$localtemperature:$localpressure:$localhumidity:$localwind2mn:$localwind:$dewpoint

# Write down the data in a text file for the Weather Watcher indi driver 
# This file will be available throught http
echo "#Weather data" > $WEATHERWATCHER
echo date=$date >> $WEATHERWATCHER
echo precip=$rain >> $WEATHERWATCHER
echo temperature=$localtemperature >> $WEATHERWATCHER
echo wind=$localwind2mn >> $WEATHERWATCHER
echo gust=$localwind >> $WEATHERWATCHER
echo humidity=$localhumidity >> $WEATHERWATCHER
#echo humidity=$humidity >> $WEATHERWATCHER
echo pressure=$localpressure >> $WEATHERWATCHER
# Manage power outage given by NUT through a fake bad forecast condition
if [ -f /home/pi/observatory/ups/powerfail ]; then
	echo forecast=999 >> $WEATHERWATCHER
        echo clouds=15 >> $WEATHERWATCHER
else
	echo forecast=$forecast >> $WEATHERWATCHER
        echo clouds=$irsky >> $WEATHERWATCHER
fi
echo dewpoint=$dewpoint >> $WEATHERWATCHER

# Collect data in a csv file for analysis
#echo "$temp;$irsky;$date" >> $WEATHERLOGGER


# A usefulel list of AAG Cloud attribute for the limits
# AAG Cloud Watcher NG.limitsCloud.clear=-5
# AAG Cloud Watcher NG.limitsCloud.cloudy=0
# AAG Cloud Watcher NG.limitsCloud.overcast=30
# AAG Cloud Watcher NG.limitsRain.dry=2000
# AAG Cloud Watcher NG.limitsRain.wet=1700
# AAG Cloud Watcher NG.limitsRain.rain=400
# AAG Cloud Watcher NG.limitsBrightness.dark=2100
# AAG Cloud Watcher NG.limitsBrightness.light=100
# AAG Cloud Watcher NG.limitsBrightness.veryLight=0


# Compute the cloud cover percentage
cloudCover=100
# Above 0 is overcast
# Between -5 and 0 is cloudy
# Bellow -5 is clear
if [ $(echo "$irsky>0" | bc) = 1 ] ; then cloudCover=100; else if [ $(echo "$irsky<=-6" | bc ) = 1 ]; then cloudCover=0; else cloudCover=$(echo "scale=5;($irsky + 6)/( 6 + 0)*100" | bc); fi; fi;
#echo $cloudCover;

# Compute the humidity percentage
humidity=100
# Above 2000 is dry
# Between 2000 and 1700 is wet
# Bellow 1700 is rainy 
if [ $(echo "$rain>2000" | bc) = 1 ] ; then humidity=0; else if [ $(echo "$rain>1700" | bc ) = 1 ]; then humidity=$(echo "scale=5;($rain - 1700)/(2000-1700)*100" | bc); else humidity=100; fi; fi;
#echo $humidity;

#compute the light percentage
light=100
if [ $(echo "$brightness>2100" | bc) = 1 ] ; then light=0; else if [ $(echo "$brightness<0" | bc ) = 1 ]; then light=100; else light=$(echo "scale=5;(2100 - $brightness)/(2100-0)*100" | bc); fi; fi;
#echo $light;


# Now Store the data into the rrd database
rrdtool update $AAGRRDFILE N:$irsky:$rain:$brightness:$temp:$wind:$cloudCover:$humidity:$light

sleep 2



######################################################################################
#
# Now that the  rrd update is done, we can proceed to the graph creation
#
######################################################################################



# Cloud cover graph

rrdtool graph $IMGDIR/aagcloud-cloudcover-lasthour.png \
           $IMG_SIZE -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Cloud Cover (last 3 hours)" \
           DEF:clouds=$AAGRRDFILE:cloudCover:AVERAGE \
	   LINE1:clouds#ff0000:clouds \
	   AREA:20#00000a45:Clear \
	   AREA:40#0000AA45:Cloudy:STACK \
	   AREA:42#0000FF45:Overcast:STACK > /dev/null 2>&1 


rrdtool graph $IMGDIR/aagcloud-cloudcover-lastday.png \
           $IMG_SIZE -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Cloud Cover (last 24 hours)" \
           DEF:clouds=$AAGRRDFILE:cloudCover:AVERAGE \
           LINE1:clouds#ff0000:clouds \
           AREA:20#00000a45:Clear \
           AREA:40#0000AA45:Cloudy:STACK \
           AREA:42#0000FF45:Overcast:STACK > /dev/null 2>&1


# humidity cover graph

rrdtool graph $IMGDIR/aagcloud-humidity-lasthour.png \
           $IMG_SIZE -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 105 -l -5 -r \
           --vertical-label "Percentage" \
           --title "Rain and humidity (last 3 hours)" \
           DEF:RAIN=$AAGRRDFILE:humidity:AVERAGE \
           DEF:HR=$OWMRRDFILE:humidity:AVERAGE \
           DEF:LHR=$LOCALRRDFILE:humidity:AVERAGE \
  	   HRULE:100#FF00FFAA:"100%" \
	   HRULE:0#00FFFFAA:"0%" \
	   LINE1:RAIN#5858FA:"Rain" \
           LINE1:HR#0080FF:"OWM HR" \
           LINE1:LHR#80FF00:"Local HR\\r" \
	   COMMENT:"\\n" \
	   GPRINT:HR:MIN:"Min\: %6.2lf %s" \
	   GPRINT:HR:MAX:"Max\: %6.2lf %s" \
	   GPRINT:HR:LAST:"Current\: %6.2lf %s" \
	   GPRINT:HR:AVERAGE:"Avg HR\: %6.2lf %S\\r"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-humidity-lastday.png \
           $IMG_SIZE -a PNG --slope-mode \
           $COLORS \
           -c BACK#000000 -c CANVAS#000000 --color FONT#FF0000 --color SHADEA#000000 --color SHADEB#000000 \
           --start -86400 --end now \
           -u 105 -l -5 -r \
           --vertical-label "Percentage" \
           --title "Rain and humidity (last 24 hours)" \
           DEF:RAIN=$AAGRRDFILE:humidity:AVERAGE \
           DEF:HR=$OWMRRDFILE:humidity:AVERAGE \
           DEF:LHR=$LOCALRRDFILE:humidity:AVERAGE \
           HRULE:100#FF00FFAA:"100%" \
           HRULE:0#00FFFFAA:"0%" \
	   LINE1:RAIN#5858FA:"Rain" \
           LINE1:HR#0080FF:"OWM HR" \
           LINE1:LHR#80FF00:"Local HR\\r" \
           COMMENT:"\\n" \
	   GPRINT:HR:MIN:"Min\: %6.2lf %s" \
	   GPRINT:HR:MAX:"Max\: %6.2lf %s" \
	   GPRINT:HR:LAST:"Current\: %6.2lf %s" \
           GPRINT:HR:AVERAGE:"Avg HR\: %6.2lf %S\\r"  > /dev/null 2>&1



# Light graph 

rrdtool graph $IMGDIR/aagcloud-light-lasthour.png \
           $IMG_SIZE -a PNG --slope-mode \
           $COLORS \
           --start -10800 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Luminosity (last 3 hours)" \
           DEF:light=$AAGRRDFILE:light:AVERAGE LINE1:light#ff0000:light \
	   AREA:30#00000a40:Dark \
	   AREA:40#0000AA40:Light:STACK \
	   AREA:32#0000FF40:VeryLight:STACK > /dev/null 2>&1 


rrdtool graph $IMGDIR/aagcloud-light-lastday.png \
           $IMG_SIZE -a PNG --slope-mode \
           $COLORS \
           --start -86400 --end now \
           -u 102 -l -2 -r \
           --vertical-label "Percentage" \
           --title "Luminosity (last 24 hours)" \
           DEF:light=$AAGRRDFILE:light:AVERAGE LINE1:light#ff0000:light \
	   AREA:30#00000a40:Dark \
	   AREA:40#0000AA40:Light:STACK \
	   AREA:32#0000FF40:VeryLight:STACK > /dev/null 2>&1 


# #########################################################################
# Create graph for last 3 hours
##########################################################################

rrdtool graph $IMGDIR/aagcloud-all-lasthour.png \
   $IMG_SIZE -a PNG --slope-mode \
   $COLORS \
   --start -10800 --end now \
   -u 60000 -l -10 \
   --vertical-label "luminosity sensor data" \
   --title "AAG Cloud Watcher lunimosity (last 3 hours)" \
   DEF:brightness=$AAGRRDFILE:brightness:AVERAGE \
   LINE1:brightness#0080FF:"Brightness" \
   AREA:brightness#0080FF40 \
   HRULE:2100#00ff00AA:"Limit Very light" \
   HRULE:100#DF7401AA:"Limit light" \
   HRULE:0#FF0000AA:"Limit dark"  > /dev/null 2>&1

#   AREA:brightness#0080FF40 \

rrdtool graph $IMGDIR/aagcloud-temp-lasthour.png \
       $IMG_SIZE -a PNG --slope-mode \
       $COLORS \
       --start -10800 --end now \
       -u 60 -l -20 -r \
       --vertical-label "temperature (°C)" \
       --title "AAG Cloud Watcher temperature (last 3 hours)" \
       DEF:temp=$AAGRRDFILE:temp:AVERAGE LINE1:temp#FF0000:"Ambient temperature" \
       HRULE:0#00FFFFAA  > /dev/null 2>&1


rrdtool graph $IMGDIR/temp-and-dewpoint-lasthour.png \
       $IMG_SIZE -a PNG --slope-mode \
       $COLORS \
       --start -10800 --end now \
       -u 40 -l -20 -r \
       --vertical-label "temperature (°C)" \
       --title "Temperature and dew point (last 3 hours)" \
       DEF:temperature=$OWMRRDFILE:temperature:AVERAGE \
       DEF:localtemperature=$LOCALRRDFILE:temperature:AVERAGE \
       DEF:dewpoint=$OWMRRDFILE:dewpoint:AVERAGE \
       HRULE:0#00FFFFAA \
       LINE1:temperature#FF0000:"Ambient temperature" \
       LINE1:localtemperature#FFBF00:"Local Ambient temperature" \
       LINE1:dewpoint#0080F0:"Dew point\\r" \
       COMMENT:"\\n" \
       GPRINT:temperature:MIN:"Min\: %6.2lf %s" \
       GPRINT:temperature:MAX:"Max\: %6.2lf %s" \
       GPRINT:temperature:LAST:"Current\: %6.2lf %s" \
       GPRINT:temperature:AVERAGE:"Avg\: %6.2lf %S\\r"  > /dev/null 2>&1

rrdtool graph $IMGDIR/aagcloud-rain-lasthour.png \
       $IMG_SIZE -a PNG --slope-mode \
       $COLORS \
       --start -10800 --end now \
       -u 3000 -l -2 -r \
       --vertical-label "Cycles" \
       --title "AAG Cloud Watcher rain sensor (last 3 hours)" \
       DEF:rain=$AAGRRDFILE:rain:AVERAGE LINE1:rain#0080FF:"Rain" AREA:rain#0080FF40 \
       HRULE:2100#00ff00AA:"Limit Dry/Wet" \
       HRULE:1700#DF7401AA:"Limit wet/rainy" \
       HRULE:400#FF0000AA:"Limit rainy"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-sky-lasthour.png \
        $IMG_SIZE -a PNG --slope-mode \
        $COLORS \
        --start -10800 --end now \
        -u 30 -l -20 -r \
        --title "AAG Cloud Watcher Sky Temperature (last 3 hours)" \
        --vertical-label "Sky IR temperature (°C)" \
        DEF:sky=$AAGRRDFILE:sky:AVERAGE  \
        LINE1:sky#0080FF:"Sky temperature" AREA:sky#0080FF40 \
        HRULE:-5#00ff00AA:"Limit clear/cloudy" \
        HRULE:0#DF7401AA:"Limit cloudy/overcast" \
        HRULE:30#FF0000AA:"Limit overcast"  > /dev/null 2>&1


# Create graph for last 24 hours
rrdtool graph $IMGDIR/aagcloud-all-lastday.png \
       $IMG_SIZE -a PNG --slope-mode \
       $COLORS \
       --start -86400 --end now \
       -u 60000 -l -10 \
       --title "AAG Cloud Watcher luminosity (last 24 hours)" \
       --vertical-label "luminosity sensor data" \
       DEF:brightness=$AAGRRDFILE:brightness:AVERAGE \
       LINE1:brightness#0080FF:"Brightness" \
       AREA:brightness#0080FF40 \
       HRULE:2100#00ff00AA:"Limit Very light" \
       HRULE:100#DF7401AA:"Limit light" \
       HRULE:0#FF0000AA:"Limit dark"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-temp-lastday.png \
       $IMG_SIZE -a PNG --slope-mode \
       $COLORS \
       --start -86400 --end now \
       -u 60 -l -20 -r \
       --vertical-label "temperature (°C)" \
       --title "AAG Cloud Watcher temperature (last 24 hours)" \
       DEF:temp=$AAGRRDFILE:temp:AVERAGE LINE1:temp#FF0000:"Ambient temperature" \
       HRULE:0#00FFFFAA  > /dev/null 2>&1


rrdtool graph $IMGDIR/temp-and-dewpoint-lastday.png \
       $IMG_SIZE -a PNG --slope-mode \
       $COLORS \
       --start -86400 --end now \
       -u 40 -l -20 -r \
       --vertical-label "temperature (°C)" \
       --title "Temperature and dew point (last day)" \
       DEF:temperature=$OWMRRDFILE:temperature:AVERAGE \
       DEF:localtemperature=$LOCALRRDFILE:temperature:AVERAGE \
       DEF:dewpoint=$OWMRRDFILE:dewpoint:AVERAGE \
       HRULE:0#00FFFFAA \
       LINE1:temperature#FF0000:"Ambient temperature" \
       LINE1:localtemperature#FFBF00:"Local Ambient temperature" \
       LINE1:dewpoint#0080F0:"Dew point\\r" \
       COMMENT:"\\n" \
       GPRINT:temperature:MIN:"Min\: %6.2lf %s" \
       GPRINT:temperature:MAX:"Max\: %6.2lf %s" \
       GPRINT:temperature:LAST:"Current\: %6.2lf %s" \
       GPRINT:temperature:AVERAGE:"Avg ambiant Temp\: %6.2lf %S\\r"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-rain-lastday.png \
    $IMG_SIZE -a PNG --slope-mode \
    $COLORS \
    --start -86400 --end now \
    -u 3000 -l -2 -r \
    --vertical-label "Cycles" \
    --title "AAG Cloud Watcher rain sensor (last 24 hours)" \
    DEF:rain=$AAGRRDFILE:rain:AVERAGE LINE1:rain#0080FF:"Rain" AREA:rain#0080FF40 \
    HRULE:2100#00ff00AA:"Limit dry/wet" \
    HRULE:1700#DF7401AA:"Limit wet/rainy" \
    HRULE:400#FF0000AA:"Limit rainy"  > /dev/null 2>&1


rrdtool graph $IMGDIR/aagcloud-sky-lastday.png \
    $IMG_SIZE -a PNG --slope-mode \
    $COLORS \
    --start -86400 --end now \
    -u 30 -l -20 -r \
    --title "AAG Cloud Watcher Sky Temperature (last 24 hours)" \
    --vertical-label "Sky IR temperature (°C)" \
    DEF:sky=$AAGRRDFILE:sky:AVERAGE \
    LINE1:sky#0080FF:"Sky temperature" AREA:sky#0080FF40 \
    HRULE:-5#00ff00AA:"Limit clear/cloudy" \
    HRULE:0#DF7401AA:"Limit cloudy/overcast" \
    HRULE:30#FF0000AA:"Limit overcast"  > /dev/null 2>&1


# Finally send images and data to ftp site
/home/pi/observatory/ftp-send.sh

# All usefull sensoR data
#
# AAG Cloud Watcher NG.sensors.infraredSky=-2.1400001049041748047
# AAG Cloud Watcher NG.sensors.correctedInfraredSky=-8.1169500350952148438
# AAG Cloud Watcher NG.sensors.infraredSensor=17.420000000000001705
# AAG Cloud Watcher NG.sensors.rainSensor=2688
# AAG Cloud Watcher NG.sensors.rainSensorTemperature=21.460229873657226562
# AAG Cloud Watcher NG.sensors.rainSensorHeater=22.971651077270507812
# AAG Cloud Watcher NG.sensors.brightnessSensor=28588
# AAG Cloud Watcher NG.sensors.ambientTemperatureSensor=17.420000076293945312
# AAG Cloud Watcher NG.readings.windSpeed=0


# All limit for status
#
# AAG Cloud Watcher NG.limitsCloud.clear=-5
# AAG Cloud Watcher NG.limitsCloud.cloudy=0
# AAG Cloud Watcher NG.limitsCloud.overcast=30
# AAG Cloud Watcher NG.limitsRain.dry=2000
# AAG Cloud Watcher NG.limitsRain.wet=1700
# AAG Cloud Watcher NG.limitsRain.rain=400
# AAG Cloud Watcher NG.limitsBrightness.dark=2100
# AAG Cloud Watcher NG.limitsBrightness.light=100
# AAG Cloud Watcher NG.limitsBrightness.veryLight=0
# AAG Cloud Watcher NG.limitsWind.calm=5
# AAG Cloud Watcher NG.limitsWind.moderateWind=25

