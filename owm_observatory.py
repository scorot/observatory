#!/usr/bin/python3
"""
This file is called by the bash script aagcloud_rrd.sh in order to get
the wheather data from OpenWeatherMap
"""

import json
import urllib.request
from dotenv import dotenv_values
from inspect import getsourcefile
import os.path

base_dir = os.path.dirname(os.path.abspath(getsourcefile(lambda:0)))
conf_dir = os.path.join(base_dir, 'conf.d', 'private.env')

# Load the config from the config.env file
config = dotenv_values(conf_dir)

lat = config.get('LAT')
lon = config.get('LON')
apikey = config.get('OWM_API_KEY')
url = 'http://api.openweathermap.org/data/2.5/onecall?lat={}&lon={}&appid={}'.format(lat, lon, apikey)

weburl = urllib.request.urlopen(url)
data = weburl.read()
json_data = json.loads(data.decode('utf-8'))

wind = json_data.get('current').get('wind_speed')
wind_deg = json_data.get('current').get('wind_deg')
cloudiness = json_data.get('current').get('clouds')
pressure = json_data.get('current').get('pressure')
temperature = json_data.get('current').get('temp') - 273.15
humidity = json_data.get('current').get('humidity')
weather =  json_data.get('current').get('weather')[0].get('id')
#weather_hourly =  json_data.get('hourly')[0].get('weather')[0].get('id')

print('{};{};{};{};{};{:.2f};{}'.format(wind, wind_deg, cloudiness, weather,
                                        pressure, temperature, humidity))

