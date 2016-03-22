#!/bin/bash
pkill WeatherMachine2
sudo echo 26 > /sys/class/gpio/unexport
sudo echo 13 > /sys/class/gpio/unexport
sudo echo 19 > /sys/class/gpio/unexport
