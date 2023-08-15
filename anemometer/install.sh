#!/bin/bash

cp ./anemometer.service /lib/systemd/system/
chown root:root /lib/systemd/system/anemometer.service
chmod 0644 /lib/systemd/system/anemometer.service

systemctl daemon-reload
systemctl enable anemometer.service

