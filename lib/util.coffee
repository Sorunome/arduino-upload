@seperator = '/'
if /^win/.test process.platform
	@seperator = '\\'

@getArduinoPath = () => 
	execPath = atom.config.get 'arduino-upload.arduinoExecutablePath'
	if execPath == 'arduino'
		# we want the default path which is actually dependent on our os
		if process.platform == 'darwin'
			execPath = '/Applications/Arduino.app/Contents/MacOS/Arduino'
		if /^win/.test process.platform
			execPath = 'C:\\Program Files (x86)\\Arduino\\arduino_debug.exe' # arduino_debug.exe to not launch any GUI stuff
	return execPath
