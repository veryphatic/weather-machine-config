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
	cd $HOME
	sudo apt-get update && apt-get install -y git-core monit glib2.0 libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libical-dev libreadline-dev libudev-dev libusb-dev make
}


# setup i2c
setupi2c() {
	sudo echo 'i2c-bcm2708' >> /etc/modules
	sudo echo 'i2c-dev' >> /etc/modules
}


# install go
# via http://dave.cheney.net/2015/09/04/building-go-1-5-on-the-raspberry-pi
installGo() {
	cd $HOME
	#curl http://dave.cheney.net/paste/go1.5.2.linux-arm.tar.gz
	curl http://nathenstreet.com/files/go1.5.2.linux-arm.tar.gz
	sudo tar -C /usr/local -xzf go1.5.2.linux-arm.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	echo 'PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
}



# installs bluez library
setupBluez() {
	cd $HOME
	curl http://www.kernel.org/pub/linux/bluetooth/bluez-5.37.tar.xz
	tar -xvf bluez-5.37.tar.xz
	cd bluez
	./configure --disable-systemd
	make
	sudo make install
}



# install NodeJS
setupNodeJs() {
	wget https://nodejs.org/dist/v4.0.0/node-v4.0.0-linux-armv7l.tar.gz 
	tar -xvf node-v4.0.0-linux-armv7l.tar.gz 
	cd node-v4.0.0-linux-armv7l
	sudo cp -R * /usr/local/
}



# get weathermachine software
installWeatherMachine() {
	cd $HOME
	mkdir weather-machine/
	cd weather-machine
	echo 'GOPATH=/home/pi/weather-machine' >> $HOME/.profile
	go get github.com/cfreeman/WeatherMachine2
	go get github.com/cfreeman/gatt
	go get github.com/cfreeman/WeatherMachine2-hrm
	go get github.com/cfreeman/WeatherMachine2-scan
	# update the gatt library with the weather machine changes
	cd $HOME/weather-machine/src/github.com/cfreeman/gatt
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/device.go > device.go
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/device_darwin.go > device_darwin.go
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/examples/option/option_darwin.go > examples/option/option_darwin.go
	curl https://raw.githubusercontent.com/veryphatic/gatt/master/examples/option/option_linux.go > examples/option/option_linux.go
}



# Compile the go app
compileWeatherMachine() {
	cd $HOME/weather-machine
	go build github.com/cfreeman/WeatherMachine2
	go build github.com/cfreeman/WeatherMachine2-hrm
	go build github.com/cfreeman/WeatherMachine2-scan
}



# install the configuration tools
installConfigTool() {
	cd $HOME
	git clone https://github.com/veryphatic/weather-machine-config
	cd weather-machine-config
	sudo npm install
	# copy the machine script to the /var/local/bin directory
	sudo cp machine.sh /usr/local/bin/machine
	# copy the json file over to the weather-machine directory
	cp weather-machine.bak.json $HOME/weather-machine/weather-machine.json
	chmod 666 $HOME/weather-machine/weather-machine.json
	# install stop script
	cp WeatherMachine2-stop.sh > $HOME/weather-machine/WeatherMachine2-stop
	chmod +x $HOME/weather-machine/WeatherMachine2-stop
	# install the shutdown button
	echo 'sudo /home/pi/weather-machine-shutdown/shutdown.sh &' >> $HOME/.bashrc
}



# creates the monit entry
setupMonit() {
	cd $HOME/weather-machine-config
	sudo cp weathermachine.monit /etc/monit/conf.d/weathermachine 
	# uncomment the monit webserver lines
	sudo sed -i '/set httpd port 2812 and/,+5 s/^#//' monitrc
	# start monit
	sudo monit reload
	sudo monit
}


#reboot
restartSystem() {
	sudo reboot
}





# installation path ....
installLibraries
installGo
setupBluez
setupNodeJs
installWeatherMachine
compileWeatherMachine
installConfigTool
setupMonit
restartSystem






