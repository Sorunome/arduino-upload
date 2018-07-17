# Arduino Upload Package

Did you not like the look of the arduino IDE but were stuck with it nevertheless? Not anymore, this package provides some essential features of the arduino IDE.

* Verify a sketch
* Build a sketch
* Upload a sketch
* Serial Monitor
* Error output when compiling
* Files are clickable in build output --> cursor jumps to that line in that file
* Switch board directly in the status bar

## Installation
`apm install arduino-upload`
(Requires atom 1.10 or later)

## Troubleshooting
* Are you on Windows and can't install because of the serialport package? Try installing the [Visual C++ 2015 building tools](http://landinghub.visualstudio.com/visual-cpp-build-tools)!
* The verify/build output does not appear? Make sure your Arduino official IDE language is set to English.

## Available commands
* `arduino-upload:verify` - Verifies the sketches (checking for error output), deletes all sources, though
* `arduino-upload:build` - Builds the current sketch, the .hex, .elf, .eep and .bin are copied to the sketch directory
* `arduino-upload:upload` - Uploads the current sketch to a connected arduino
* `arduino-upload:serial-monitor` - Opens the serial monitor of a connected arduino

You can place these commands in a toolbar using the [**Flex Tool Bar**](https://atom.io/packages/flex-tool-bar) package. [Here's how](docs/toolbar.md).

## Screenshots
Verifying a program:  
![verify](https://github.com/Sorunome/arduino-upload/blob/master/screenshots/verify.gif?raw=true)

Serial monitor:  
![serial](https://github.com/Sorunome/arduino-upload/blob/master/screenshots/serial.gif?raw=true)
