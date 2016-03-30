#!/bin/sh

clear
echo "\n"
echo "Weather Machine 2"
echo "================="
echo "\n"
echo "Installing the Weather Machine 2 libraries and application."
echo "This may take 5 - 15 minutes."
echo "Once everything has installed the Raspberry Pi will automatically restart."
sleep 5s



# install the dependencies
installLibraries() {
	cd /home/pi
	apt-get update && apt-get install -y git-core monit glib2.0 libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libical-dev libreadline-dev libudev-dev libusb-dev make
}


# setup i2c
setupi2c() {
	echo 'i2c-bcm2708' >> /etc/modules
	echo 'i2c-dev' >> /etc/modules
}


# install go
# via http://dave.cheney.net/2015/09/04/building-go-1-5-on-the-raspberry-pi
installGo() {
	cd /home/pi
	#wget http://dave.cheney.net/paste/go1.5.2.linux-arm.tar.gz
	wget http://nathenstreet.com/files/smithsonian/go1.5.2.linux-arm.tar.gz
	tar -C /usr/local -xzf go1.5.2.linux-arm.tar.gz
	export PATH=$PATH:/usr/local/go/bin

	echo 'PATH=$PATH:/usr/local/go/bin' >> /home/pi/.profile
}



# installs bluez library
setupBluez() {
	cd /home/pi
	wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.37.tar.xz
	tar -xvf bluez-5.37.tar.xz
	cd bluez-5.37
	./configure --disable-systemd
	make
	make install
}



# install NodeJS
setupNodeJs() {
	cd /home/pi
	wget https://nodejs.org/dist/v4.0.0/node-v4.0.0-linux-armv7l.tar.gz 
	tar -xvf node-v4.0.0-linux-armv7l.tar.gz 
	cd node-v4.0.0-linux-armv7l
	cp -R * /usr/local/
}



# get weathermachine software
installWeatherMachine() {
	cd /home/pi
	mkdir weather-machine/
	cd weather-machine
	export GOPATH=/home/pi/weather-machine

	go get github.com/cfreeman/WeatherMachine2
	go get github.com/cfreeman/gatt

	# update the gatt library with the weather machine changes
	cd /home/pi/weather-machine/src/github.com/cfreeman/gatt
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/device.go > device.go
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/device_darwin.go > device_darwin.go
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/examples/option/option_darwin.go > examples/option/option_darwin.go
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/examples/option/option_linux.go > examples/option/option_linux.go

	cd /home/pi/weather-machine
	go get github.com/cfreeman/WeatherMachine2-hrm
	go get github.com/cfreeman/WeatherMachine2-scan
}



# Compile the go app
compileWeatherMachine() {
	cd /home/pi/weather-machine

	go build github.com/cfreeman/WeatherMachine2
	go build github.com/cfreeman/WeatherMachine2-hrm
	go build github.com/cfreeman/WeatherMachine2-scan
}



# install the configuration tools
installConfigTool() {
	cd /home/pi
	git clone https://github.com/veryphatic/weather-machine-config
	cd weather-machine-config
	npm install

	# copy the machine script to the /var/local/bin directory
	cp machine.sh /usr/local/bin/machine

	# copy the json file over to the weather-machine directory
	cp weather-machine.bak.json /home/pi/weather-machine/weather-machine.json
	chmod 666 /home/pi/weather-machine/weather-machine.json

	# install stop script
	cp WeatherMachine2-stop.sh /home/pi/weather-machine/WeatherMachine2-stop
	chmod +x /home/pi/weather-machine/WeatherMachine2-stop

	# install the shutdown button
	sudo chmod +x /home/pi/weather-machine-config/shutdown.sh
	echo 'sudo /home/pi/weather-machine-config/shutdown.sh &' >> /home/pi/.bashrc
}



# creates the monit entry
setupMonit() {
	cd /home/pi/weather-machine-config
	cp weathermachine.monit /etc/monit/conf.d/weathermachine 

	# uncomment the monit webserver lines
	sed -i '/set httpd port 2812 and/,+5 s/^#//' /etc/monit/monitrc

	# start monit
	monit reload
	monit start all
}


#reboot
restartSystem() {
	read -p "Congratulations. The Raspberry Pi has completed installing the software. Please press [Enter] to reboot the system." -n1 -s
	reboot
}



# installation path ....
installLibraries
setupi2c
installGo
setupBluez
setupNodeJs
installWeatherMachine
compileWeatherMachine
installConfigTool
setupMonit
restartSystem






