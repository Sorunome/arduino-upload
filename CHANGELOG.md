## 1.2.0
* Board can be set now via status bar
* Better arduino default path detection for macos

## 1.1.1
* Actual error output when uploading

## 1.1.0
* multiple bugfixes
* cleaner code
* quicker compiling
* add support to programmers

## 1.0.3
* fix [#10](https://github.com/Sorunome/arduino-upload/issues/6)

## 1.0.2
* add support for arduino.org boards

## 1.0.1
* fix [#6](https://github.com/Sorunome/arduino-upload/issues/6)

## 1.0.0
* First major release
* Added screenshots to readme
* Made serialport a hard dependency, works with atom 1.10

## 0.7.1
* SerialPort is now an optional dependency, please figure out how to get it working...
* Fixed windows support (I hope)

## 0.7.0
* commented out SerialPort until it is working via atom.... (node-pre-gyp issue....)

## 0.6.0
* Added serial sending

## 0.5.0
* Added verification
* Building now copies .hex, .elf and .eep to sketch directory

## 0.4.0
* Port to upload to is now determined by this package instead of the IDE
* Made boards configurable

## 0.3.1
* files when clicked on in error output are now activated even in other pane

## 0.3.0
* Filenames in error output are now clickable, also jumps to line

## 0.2.0
* Added Serial monitor

## 0.1.0 - First Release
* Allowing building the sketch
* Allowing uploading the sketch
* Nice error output
