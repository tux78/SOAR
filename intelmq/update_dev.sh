#!/bin/bash

cd /opt/dev_intelmq
pip3 install -e .
cp /opt/dev_intelmq/intelmq/bots/BOTS /opt/intelmq/etc/BOTS
