#!/bin/bash

 echo "Running Pre installation script"

sudo apt install python-pip python3-dev python3-pip
wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python3

 echo "Pre Installation Script Complete"
