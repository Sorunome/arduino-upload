@seperator = '/'
if /^win/.test process.platform
	@seperator = '\\'

@getArduinoPath = () => 
	execPath = atom.config.get 'arduino-upload.arduinoExecutablePath'
	if execPath == 'arduino' && process.platform == 'darwin' # we are on macos, let's use the real default path
		execPath = '/Applications/Arduino.app/Contents/MacOS/Arduino'
	return execPath
