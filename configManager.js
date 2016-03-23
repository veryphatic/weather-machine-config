/**
 Weather Machine II
 JSON Configuration Manager

 Commands:

 machine --list

 machine --reset:all
 machine --reset:hrm
 machine --reset:fog
 machine --reset:fan
 machine --reset:pump

 machine --fan:increase-duration
 machine --fan:decrease-duration

 machine --pump:increase-interval
 machine --pump:decrease-interval
 machine --pump:increase-duration
 machine --pump:decrease-duration

 machine --fog:increase-volume
 machine --fog:decrease-volume
 machine --fog:increase-duration
 machine --fog:decrease-duration
 machine --fog:increase-interval
 machine --fog:decrease-interval

 machine --heart:increase-rate
 machine --heart:decrease-rate

 machine --light:increase-dimmer
 machine --light:decrease-dimmer


**/

// var jsonPath = '/home/pi/weather-machine/weather-machine.json';
// var jsonBakPath = '/home/pi/weather-machine-config/weather-machine.bak.json';

var jsonPath = 'weather-machine.json';
var jsonBakPath = 'weather-machine.bak.json';

var fs = require('fs');
// var clc = require('cli-color');
var weatherMachineConfig = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
var weatherMachineConfigBackup = JSON.parse(fs.readFileSync(jsonBakPath, 'utf8'));
var exec = require('child_process').exec;


var maximums = {
    SmokeVolume: 100,
    SmokeDuration: 5000,
    SmokeInterval: 15000,
    FanDuration: 15000,
    BeatRate: 1,
    PumpDuration: 5000,
    PumpInterval: 5000,
    Dimmer: 255
};

var cliArgs = process.argv[2];

var cliArgsMethod = null;
if cliArgs.length <= 0 {
    generalError();
}
else {
    cliArgsMethod = cliArgs.split(':')[1];
}


// Switch

if (cliArgs.indexOf('reset') > 0) {
    reset(cliArgsMethod);
}
else if (cliArgs.indexOf('fog') > 0) {
    fog(cliArgsMethod);
}
else if (cliArgs.indexOf('heart') > 0) {
    heart(cliArgsMethod);
}
else if (cliArgs.indexOf('fan') > 0) {
    fan(cliArgsMethod);
}
else if (cliArgs.indexOf('pump') > 0) {
    pump(cliArgsMethod);
}
else if (cliArgs.indexOf('list') > 0) {
    messageConsole('All parameter values:');
    list();
}
else if (cliArgs.indexOf('light') > 0) {
    light(cliArgsMethod);
}
else {
    generalError();
}





// Update methods ------------------------------------------------ //


/**
 * Increase a given node value
 * @param node
 * @param amount
 * @returns {*}
 */
function increase(value, amount, max) {
    var newValue = Number(value) + amount;
    if (value <= max && newValue <= max) {
        return newValue;
    }
    else {
        noticeMessage('You have reached the maximum value for this element. Please ask a question on the support site if you are having issues');
        return max;
    }

}


/**
 * Decrease a given node value
 * @param node
 * @param amount
 * @returns {number}
 */
function decrease(value, amount) {
    var newValue = Number(value - amount);
    var minValue = 0;

    if (value >= minValue && newValue >= minValue) {
        return newValue;
    }
    else {
        noticeMessage('You have reached the minimum value for this element. Please ask a question on the support site if you are having issues');
        return minValue;
    }
}



/**
 * Configure light dimmer
 * @param args
 * @options
 * increase-dimmer
 * decrease-dimmer
 */
function light(args) {
    switch(args) {
        case 'increase-dimmer':

            var oldValue = weatherMachineConfig.S1Beat.Dimmer;
            var newValue = increase(oldValue, 5, maximums.Dimmer).toFixed(0);

            weatherMachineConfig.S1Beat.Dimmer = newValue;
            weatherMachineConfig.S2Beat.Dimmer = newValue;

            messageConsole('Light dimmer increased from ' + oldValue + ' to ' + newValue);

            writeFile();
            break;

        case 'decrease-dimmer':
            var oldValue = weatherMachineConfig.S1Beat.Dimmer;
            var newValue = decrease(oldValue, 5).toFixed(0);
            
            weatherMachineConfig.S1Beat.Dimmer = newValue;
            weatherMachineConfig.S2Beat.Dimmer = newValue;
            
            messageConsole('Light dimmer decreased from ' + oldValue + ' to ' + newValue);
            writeFile();
            break;

        default:
            generalError();
            console.log('\r');
    }
}




/**
 * Configure the fog
 * @param args
 * @options
 *  increase-volume
 *  decrease-volume
 *  increase-duration
 *  decrease-duration
 *  increase-interval
 *  decrease-interval
 */
function fog(args) {

    switch (args) {

        case 'increase-volume':
            var oldValue = weatherMachineConfig.SmokeVolume;
            var newValue = increase(oldValue, 5, maximums.SmokeVolume);
            weatherMachineConfig.SmokeVolume = newValue;
            messageConsole('Fog volume increased from ' + oldValue + '% to ' + newValue + '%');
            writeFile();
            break;

        case 'decrease-volume':
            var oldValue = weatherMachineConfig.SmokeVolume;
            var newValue = decrease(oldValue, 5);
            weatherMachineConfig.SmokeVolume = newValue;
            messageConsole('Fog volume decreased from ' + oldValue + '% to ' + newValue + '%');
            writeFile();
            break;

        case 'increase-duration':
            var oldValue = weatherMachineConfig.SmokeDuration;
            var newValue = increase(oldValue, 100, maximums.SmokeDuration);
            weatherMachineConfig.SmokeDuration = newValue;
            messageConsole('Fog duration increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-duration':
            var oldValue = weatherMachineConfig.SmokeDuration;
            var newValue = decrease(oldValue, 100);
            weatherMachineConfig.SmokeDuration = newValue;
            messageConsole('Fog duration decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'increase-interval':
            var oldValue = weatherMachineConfig.SmokeInterval;
            var newValue = increase(oldValue, 500, maximums.SmokeInterval);
            weatherMachineConfig.SmokeInterval = newValue;
            messageConsole('Fog interval increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-interval':
            var oldValue = weatherMachineConfig.SmokeInterval;
            var newValue = decrease(oldValue, 500);
            weatherMachineConfig.SmokeInterval = newValue;
            messageConsole('Fog interval decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        default:
            generalError();
            console.log('\r');
    }
}


/**
 * Configure heart rate
 * @param args
 * @options
 * increase-rate
 * decrease-rate
 */
function heart(args) {
    switch(args) {
        case 'increase-rate':
            var oldValue = weatherMachineConfig.BeatRate;
            var newValue = increase(oldValue, .1, maximums.BeatRate).toFixed(1);
            weatherMachineConfig.BeatRate = newValue;
            messageConsole('Fog interval increased from ' + oldValue*100 + '% to ' + newValue*100 + '%');
            writeFile();
            break;

        case 'decrease-rate':
            var oldValue = weatherMachineConfig.BeatRate;
            var newValue = (decrease(oldValue, .1)).toFixed(1);
            weatherMachineConfig.BeatRate = newValue;
            messageConsole('Fog interval decreased from ' + oldValue*100 + '% to ' + newValue*100 + '%');
            writeFile();
            break;

        default:
            generalError();
            console.log('\r');
    }
}


/**
 * Config fan
 * @param args
 * @options
 * increase-duration
 * decrease-duration
 */
function fan(args) {
    switch(args) {
        case 'increase-duration':
            var oldValue = weatherMachineConfig.FanDuration;
            var newValue = increase(oldValue, 1000, maximums.FanDuration);
            weatherMachineConfig.FanDuration = newValue;
            messageConsole('Fan duration increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-duration':
            var oldValue = weatherMachineConfig.FanDuration;
            var newValue = decrease(oldValue, 1000);
            weatherMachineConfig.FanDuration = newValue;
            messageConsole('Fan duration decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        default:
            generalError();
            console.log('\r');
    }
}



/**
 * Pump adjustments
 * @param args
 * @options
 * increase-interval
 * decrease-interval
 * increase-duration
 * decrease-duration
 */
function pump(args) {
    switch(args) {
        case 'increase-interval':
            var oldValue = weatherMachineConfig.PumpInterval;
            var newValue = increase(oldValue, 500, maximums.PumpInterval);
            weatherMachineConfig.PumpInterval = newValue;
            messageConsole('Pump interval increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-interval':
            var oldValue = weatherMachineConfig.PumpInterval;
            var newValue = decrease(oldValue, 500);
            weatherMachineConfig.PumpInterval = newValue;
            messageConsole('Fan interval decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'increase-duration':
            var oldValue = weatherMachineConfig.PumpDuration;
            var newValue = increase(oldValue, 500, maximums.PumpDuration);
            weatherMachineConfig.PumpDuration = newValue;
            messageConsole('Pump duration increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-duration':
            var oldValue = weatherMachineConfig.PumpDuration;
            var newValue = decrease(oldValue, 500);
            weatherMachineConfig.PumpDuration = newValue;
            messageConsole('Fan duration decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        default:
            generalError();
            console.log('\r');
    }
}


/**
 * Reset given items to their default value
 * @param args
 */
function reset(args) {
    switch(args) {
        case 'all':
            weatherMachineConfig = weatherMachineConfigBackup;
            console.log('\r');
            messageConsole('All parameters reset to default values.');
            noticeMessage('**** Notice the Raspberry Pi will reset in 10 seconds');
            messageConsole('You will need to re-pair the heart rate monitor paddles by grabbing them until the water pump starts up.');
            console.log('\r');
            // list();
            writeFile();
            
            setTimeout( function() {
                //exec('sudo reboot',function(error, stdout, stderr) {});
                exec('sudo reboot',function(error, stdout, stderr) {
                    console.log(stdout);
                });
            }, 10000);

            break;

        case 'fog':
            weatherMachineConfig.SmokeVolume = weatherMachineConfigBackup.SmokeVolume;
            weatherMachineConfig.SmokeDuration = weatherMachineConfigBackup.SmokeDuration;
            weatherMachineConfig.SmokeInterval = weatherMachineConfigBackup.SmokeInterval;
            messageConsole('Fog reset to default values:');
            messageConsole('Volume: ' + weatherMachineConfig.SmokeVolume + '%');
            messageConsole('Duration: ' + weatherMachineConfig.SmokeDuration/1000 + ' seconds');
            messageConsole('Interval: ' + weatherMachineConfig.SmokeInterval/1000 + ' seconds');
            writeFile();
            break;

        case 'heart':
            weatherMachineConfig.BeatRate = weatherMachineConfigBackup.BeatRate;
            messageConsole('Heart rate reset to default value:');
            messageConsole('Heart beat rate: ' + weatherMachineConfig.BeatRate * 100 + '%');
            writeFile();
            break;

        case 'fan':
            weatherMachineConfig.FanDuration = weatherMachineConfigBackup.FanDuration;
            messageConsole('Fan duration reset to default value:');
            messageConsole('Fan duration: ' + weatherMachineConfig.FanDuration / 1000 + ' seconds');
            writeFile();
            break;

        case 'pump':
            weatherMachineConfig.PumpDuration = weatherMachineConfigBackup.PumpDuration;
            weatherMachineConfig.PumpInterval = weatherMachineConfigBackup.PumpInterval;
            messageConsole('Pump reset to default value:');
            messageConsole('Pump duration: ' + weatherMachineConfig.PumpDuration / 1000 + ' seconds');
            messageConsole('Pump interval: ' + weatherMachineConfig.PumpInterval / 1000 + ' seconds');
            writeFile();
            break;

        case 'light': 
            weatherMachineConfig.S1Beat.Dimmer = weatherMachineConfigBackup.S1Beat.Dimmer;
            weatherMachineConfig.S2Beat.Dimmer = weatherMachineConfigBackup.S2Beat.Dimmer;
            messageConsole('Light dimmer reset to default value:');
            messageConsole('Dimmer value: ' + weatherMachineConfig.S1Beat.Dimmer);
            break;

        default:
            generalError();
            console.log('\r');
    }
}





/**
 * Print out the current values for everything
 */
function list() {
    
    messageConsole('Fog Volume: ' + weatherMachineConfig.SmokeVolume + '%');
    messageConsole('Fog Duration: ' + weatherMachineConfig.SmokeDuration/1000 + ' seconds');
    messageConsole('Fog Interval: ' + weatherMachineConfig.SmokeInterval/1000 + ' seconds');
    messageConsole('Heart beat rate: ' + weatherMachineConfig.BeatRate * 100 + '%');
    messageConsole('Fan duration: ' + weatherMachineConfig.FanDuration / 1000 + ' seconds');
    messageConsole('Pump duration: ' + weatherMachineConfig.PumpDuration / 1000 + ' seconds');
    messageConsole('Pump interval: ' + weatherMachineConfig.PumpInterval / 1000 + ' seconds');
    messageConsole('Light dimmer: ' + weatherMachineConfig.S1Beat.Dimmer);
}


/**
 * Write out the JSON file
 */
function writeFile() {
    fs.writeFile(jsonPath, JSON.stringify(weatherMachineConfig), (err) => {
        if (err) throw err;
        messageConsole('File saved');
        console.log('\r');
    });
}


// Console out ------------------------------------------------ //


/**
 * General error message
 */
function generalError() {
    // console.log(clc.red('Sorry the parameters you passed were incorrect. Please check the spelling, the format and try again.'));
    console.log('Sorry the parameters you passed were incorrect. Please check the spelling, the format and try again.');
}   


/**
 * General console
 * @param msg
 */
function messageConsole(msg) {
    // console.log(clc.whiteBright(msg));
    console.log(msg);
}


/**
 * Notice message (in blue)
 * @param msg
 */
function noticeMessage(msg) {
    // var col = clc.xterm(45);
    // console.log(col(msg));
    console.log(msg);
}