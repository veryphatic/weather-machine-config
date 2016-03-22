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

	# install stop script
	cd $HOME/weather-machine
	curl https://raw.githubusercontent.com/veryphatic/weather-machine-config/master/WeatherMachine2-stop.sh > WeatherMachine2-stop
	chmod +x WeatherMachine2-stop.sh
}



# Compile the go app
compileWeatherMachine() {
	cd $HOME/weather-machine

	export GOPATH=$HOME/weather-machine
	go build github.com/cfreeman/WeatherMachine2
	go build github.com/cfreeman/WeatherMachine2-hrm
	go build github.com/cfreeman/WeatherMachine2-scan
}



# create the start and stop scripts
createStartStopScript() {
	# TODO
}



#installConfigTool
installConfigTool() {
	cd $HOME
	git clone https://github.com/veryphatic/weather-machine-config

	#copy the json file over to the weather-machine directory
	cp weather-machine-config/weather-machine.bak.json weather-machine/weather-machine.json
	chmod 666 weather-machine/weather-machine.json
}



# creates the monit entry
setupMonit() {
	cd $HOME/weather-machine-config
	sudo cp weathermachine.monit /etc/monit/conf.d/weathermachine 

	sudo monit
}



# get the shutdown switch tool and copy the machine.sh into init.d
shutdownSwitch() {
	echo "Setting up shutdown switch"
	# add to .bashrc 
	# start the python button shutdown script
	# sudo  /home/pi/weather-machine-shutdown/shutdown.sh &
}



#reboot
restartSystem() {
	sudo reboot
}









# reboot
installLibraries
installGo
setupBluez
installWeatherMachine
compileWeatherMachine
#createStartStopScript
installConfigTool
setupMonit
#shutdownSwitch
#restartSystem






