check process WeatherMachine2 matching "WeatherMachine2"
		start program = "/bin/bash -c 'cd /home/pi/weather-machine && ./WeatherMachine2 &" with timeout 60 seconds 
		stop program = "/home/pi/weather-machine/WeatherMachine2-stop"  
		if changed pid then exec /sbin/reboot