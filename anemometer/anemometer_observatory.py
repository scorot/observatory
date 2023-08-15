#!/usr/bin/python

import ast
import serial

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

while value:
    try:
        ser_bytes = ser.readline()
        s = ser_bytes.decode().strip()
        print s
        if s.find("wind") > 0:
            d = ast.literal_eval(s)
            for v in d.values():
                try:
                    outputStr = '{};{}'.format(outputStr, v)
                except NameError:
                    outputStr = '{}'.format(v)
            print outputStr
            value = False
    except Exception as msg:
        print "{}".format(str(msg))
        print("Keyboard Interrupt")
        break

