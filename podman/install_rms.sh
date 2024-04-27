#!/bin/bash

# Create RMS directories
mkdir /source /RMS_data /Desktop
echo 1 > /.rmsautorunflag

virtualenv --system-site-packages /vRMS
source /vRMS/bin/activate
cd /source/RMS
pip install --no-cache-dir -r requirements.txt
python setup.py install
cd /source/RMS/Scripts
./GenerateDesktopLinks.sh
