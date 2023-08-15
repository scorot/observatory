#!/usr/bin/python
"""
This scripts runs as a service ans connect to the arduino
weather station device on /dev/anemometer.
Then it writes and updates the file /var/log/anemometer.txt
which is red by the aagcloud_rrd.sh script.
"""

import ast
import serial
import time

#ser = serial.Serial('/dev/ttyUSB0', baudrate=9600)
ser = serial.Serial('/dev/anemometer', baudrate=9600)

ser.bytesize = serial.EIGHTBITS #number of bits per bytes
ser.parity = serial.PARITY_NONE #set parity check: no parity
#ser.stopbits = serial.STOPBITS_TWO #number of stop bits
#ser.timeout = None          #block read
ser.timeout = 5               #non-block read
#ser.timeout = 2              #timeout block read
ser.xonxoff = False     #disable software flow control
ser.rtscts = False     #disable hardware (RTS/CTS) flow control
ser.dsrdtr = False       #disable hardware (DSR/DTR) flow control


value = True
interval = 60
counter = 0

while value:
    try:
        ser_bytes = ser.readline()
        s = ser_bytes.decode().strip()
        if s.find("wind") > 0:
            d = ast.literal_eval(s)
            for v in d.values():
                try:
                    outputStr = '{};{}'.format(outputStr, v)
                except NameError:
                    outputStr = '{}'.format(v)
            if counter >= interval:
                with open('/var/log/anemometer.txt', 'w') as f:
                    f.write(outputStr)
                counter = 0
            #print outputStr
            del outputStr
            counter += 1
            #value = False
    except UnicodeDecodeError:
        print("Unicode error")
        #break
    except KeyboardInterrupt:
        print("Keyboard Interrupt")
        break

