#! /usr/bin/env node

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


**/

var jsonPath = '~/weather-machine/weather-machine.json';
var jsonBakPath = '~/weather-machine-config/weather-machine.bak.json';

var fs = require('fs');
var clc = require('cli-color');
var weatherMachineConfig = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
var weatherMachineConfigBackup = JSON.parse(fs.readFileSync(jsonBakPath, 'utf8'));



var maximums = {
    SmokeVolume: 100,
    SmokeDuration: 5000,
    SmokeInterval: 15000,
    FanDuration: 15000,
    BeatRate: 1,
    PumpDuration: 5000,
    PumpInterval: 5000
};

var cliArgs = process.argv[2];
var cliArgsMethod = cliArgs.split(':')[1];


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
    list();
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
function increase(node, amount) {

    var newValue = Number(weatherMachineConfig[node]) + amount;
    var maxValue = Number(maximums[node]);

    if (weatherMachineConfig[node] <= maxValue && newValue <= maxValue) {
        return newValue;
    }
    else {
        noticeMessage('You have reached the maximum value for this element. Please ask a question on the support site if you are having issues');
        return maxValue;
    }

}


/**
 * Decrease a given node value
 * @param node
 * @param amount
 * @returns {number}
 */
function decrease(node, amount) {
    var newValue = Number(weatherMachineConfig[node] - amount);
    var minValue = 0;

    if (weatherMachineConfig[node] >= minValue && newValue >= minValue) {
        return newValue;
    }
    else {
        noticeMessage('You have reached the minimum value for this element. Please ask a question on the support site if you are having issues');
        return minValue;
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
            var newValue = increase('SmokeVolume', 5);
            weatherMachineConfig.SmokeVolume = newValue;
            messageConsole('Fog volume increased from ' + oldValue + '% to ' + newValue + '%');
            writeFile();
            break;

        case 'decrease-volume':
            var oldValue = weatherMachineConfig.SmokeVolume;
            var newValue = decrease('SmokeVolume', 5);
            weatherMachineConfig.SmokeVolume = newValue;
            messageConsole('Fog volume decreased from ' + oldValue + '% to ' + newValue + '%');
            writeFile();
            break;

        case 'increase-duration':
            var oldValue = weatherMachineConfig.SmokeDuration;
            var newValue = increase('SmokeDuration', 100);
            weatherMachineConfig.SmokeDuration = newValue;
            messageConsole('Fog duration increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-duration':
            var oldValue = weatherMachineConfig.SmokeDuration;
            var newValue = decrease('SmokeDuration', 100);
            weatherMachineConfig.SmokeDuration = newValue;
            messageConsole('Fog duration decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'increase-interval':
            var oldValue = weatherMachineConfig.SmokeInterval;
            var newValue = increase('SmokeInterval', 500);
            weatherMachineConfig.SmokeInterval = newValue;
            messageConsole('Fog interval increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-interval':
            var oldValue = weatherMachineConfig.SmokeInterval;
            var newValue = decrease('SmokeInterval', 500);
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
            var newValue = (increase('BeatRate', .1)).toFixed(1);
            weatherMachineConfig.BeatRate = newValue;
            messageConsole('Fog interval increased from ' + oldValue*100 + '% to ' + newValue*100 + '%');
            writeFile();
            break;

        case 'decrease-rate':
            var oldValue = weatherMachineConfig.BeatRate;
            var newValue = (decrease('BeatRate', .1)).toFixed(1);
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
            var newValue = increase('FanDuration', 1000);
            weatherMachineConfig.FanDuration = newValue;
            messageConsole('Fan duration increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-duration':
            var oldValue = weatherMachineConfig.FanDuration;
            var newValue = decrease('FanDuration', 1000);
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
            var newValue = increase('PumpInterval', 500);
            weatherMachineConfig.PumpInterval = newValue;
            messageConsole('Pump interval increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-interval':
            var oldValue = weatherMachineConfig.PumpInterval;
            var newValue = decrease('PumpInterval', 500);
            weatherMachineConfig.PumpInterval = newValue;
            messageConsole('Fan interval decreased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'increase-duration':
            var oldValue = weatherMachineConfig.PumpDuration;
            var newValue = increase('PumpDuration', 500);
            weatherMachineConfig.PumpDuration = newValue;
            messageConsole('Pump duration increased from ' + oldValue/1000 + ' seconds to ' + newValue/1000 + ' seconds');
            writeFile();
            break;

        case 'decrease-duration':
            var oldValue = weatherMachineConfig.PumpDuration;
            var newValue = decrease('PumpDuration', 500);
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
            messageConsole('All parameters reset to default values:');
            messageConsole('Fog Volume: ' + weatherMachineConfig.SmokeVolume + '%');
            messageConsole('Fog Duration: ' + weatherMachineConfig.SmokeDuration/1000 + ' seconds');
            messageConsole('Fog Interval: ' + weatherMachineConfig.SmokeInterval/1000 + ' seconds');
            messageConsole('Heart beat rate: ' + weatherMachineConfig.BeatRate * 100 + '%');
            messageConsole('Fan duration: ' + weatherMachineConfig.FanDuration / 1000 + ' seconds');
            messageConsole('Pump duration: ' + weatherMachineConfig.PumpDuration / 1000 + ' seconds');
            messageConsole('Pump interval: ' + weatherMachineConfig.PumpInterval / 1000 + ' seconds');

            writeFile();
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

        default:
            generalError();
            console.log('\r');
    }
}


/**
 * Print out the current values for everything
 */
function list() {
    messageConsole('All parameter values:');
    messageConsole('Fog Volume: ' + weatherMachineConfig.SmokeVolume + '%');
    messageConsole('Fog Duration: ' + weatherMachineConfig.SmokeDuration/1000 + ' seconds');
    messageConsole('Fog Interval: ' + weatherMachineConfig.SmokeInterval/1000 + ' seconds');
    messageConsole('Heart beat rate: ' + weatherMachineConfig.BeatRate * 100 + '%');
    messageConsole('Fan duration: ' + weatherMachineConfig.FanDuration / 1000 + ' seconds');
    messageConsole('Pump duration: ' + weatherMachineConfig.PumpDuration / 1000 + ' seconds');
    messageConsole('Pump interval: ' + weatherMachineConfig.PumpInterval / 1000 + ' seconds');
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
    console.log(clc.red('Sorry the parameters you passed were incorrect. Please check the spelling, the format and try again.'));
}


/**
 * General console
 * @param msg
 */
function messageConsole(msg) {
    console.log(clc.whiteBright(msg));
}


/**
 * Notice message (in blue)
 * @param msg
 */
function noticeMessage(msg) {
    var col = clc.xterm(45);
    console.log(col(msg));
}