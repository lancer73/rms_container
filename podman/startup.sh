#!/bin/bash
cp /RMS_data/config/.config /source/RMS
cp -pr /RMS_data/config/.ssh /
cp /RMS_data/config/mask* /source/RMS
cp /RMS_data/config/platepar* /source/RMS
chmod 600 .ssh/*
chmod 700 .ssh
source /vRMS/bin/activate
cd /source/RMS
/Desktop/RMS_FirstRun.sh
