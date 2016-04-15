{CompositeDisposable} = require 'atom'
{spawn} = require 'child_process'
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

fs = require 'fs'
path = require 'path'
OutputView = require './output-view'
serialport = require 'serialport'

output = null
serial = null
serialeditor = null

module.exports = ArduinoUpload =
	config:
		arduinoExecutablePath:
			type: 'string'
			default: 'arduino'
		baudRate:
			type: 'number'
			default: '9600'

	activate: (state) ->
		# Setup to use the new composite disposables API for registering commands
		@subscriptions = new CompositeDisposable
		@subscriptions.add atom.commands.add "atom-workspace",
			'arduino-upload:build': => @build()
		@subscriptions.add atom.commands.add "atom-workspace",
			'arduino-upload:upload': => @upload()
		@subscriptions.add atom.commands.add "atom-workspace",
			'arduino-upload:serial-monitor': => @openserial()
		
		output = new OutputView
		atom.workspace.addBottomPanel(item:output)
		output.hide()



	deactivate: ->
		@subscriptions.dispose()
		output?.remove()
		@closeserial()

	build: ->
		editor = atom.workspace.getActivePaneItem()
		file = editor?.buffer?.file?.getPath()?.split "/"
		file?.pop()
		name = file?.pop()
		file?.push name
		file?.push name+".ino"
		file = file?.join("/")
		dispError = false
		output.reset()
		if fs.existsSync(file)
			stdoutput = spawn atom.config.get('arduino-upload.arduinoExecutablePath'), [file,'--verify']
			
			stdoutput.stdout.on 'data', (data) ->
				if data.toString().strip().indexOf 'Sketch' == 0 || data.toString().strip().indexOf 'Global' == 0
					atom.notifications.addInfo data.toString()
			
			stdoutput.stderr.on 'data', (data) ->
				if data.toString().strip() == "exit status 1"
					dispError = false
				if dispError
					output.addLine data.toString()
				if data.toString().strip() == "Verifying..."
					dispError = true
			stdoutput.on 'close', (code) ->
				if code != 0
					atom.notifications.addError 'Build failed'
				output.finish()
		else
			atom.notifications.addError "File isn't part of an Arduino sketch!"
	upload: ->
		editor = atom.workspace.getActivePaneItem()
		file = editor?.buffer?.file?.getPath()?.split "/"
		file?.pop()
		name = file?.pop()
		file?.push name
		file?.push name+".ino"
		file = file?.join("/")
		dispError = false
		uploading = false
		output.reset()
		if fs.existsSync(file)
			stdoutput = spawn atom.config.get('arduino-upload.arduinoExecutablePath'), [file,'-v','--upload']
			
			stdoutput.stdout.on 'data', (data) ->
				if data.toString().strip().indexOf('Sketch') == 0 || data.toString().strip().indexOf('Global') == 0
					atom.notifications.addInfo data.toString()
			
			stdoutput.stderr.on 'data', (data) ->
				if data.toString().strip().indexOf("avrdude:") == 0 && !uploading
					uploading = true
					atom.notifications.addInfo 'Uploading sketch...'
				else if dispError && !uploading
					output.addLine data.toString()
				else if data.toString().strip() == "Verifying and uploading..."
					dispError = true
			
			stdoutput.on 'close', (code) ->
				output.finish()
				if code == 0
					atom.notifications.addInfo 'Successfully uploaded sketch'
				else
					if uploading
						atom.notifications.addError "Couldn't upload to board, is it connected?"
					else
						atom.notifications.addError 'Build failed'
		else
			atom.notifications.addError "File isn't part of an Arduino sketch!"
	isArduino: (port) ->
		console.log port
		if port.manufacturer == 'FTDI'
			return true
		if port.vendorId == '0x0403' || port.vendorId == '0x2341'
			return true
		return false
	openserialport: ->
		if serial!=null
			atom.notifications.addInfo 'wut, serial open?'
			return
		p = ''
		serialport.list (err,ports) =>
			for port in ports
				if @isArduino(port)
					p = port.comName
			
			if p == ''
				atom.notifications.addError 'No Arduino found!'
				@closeserial()
				return
			
			serial = new serialport.SerialPort p, {
					baudRate: atom.config.get('arduino-upload.baudRate')
					parser: serialport.parsers.readline "\n"
				}
			
			serial.on 'open', (data) =>
				atom.notifications.addInfo 'new serial connection'
			serial.on 'data', (data) =>
				serialeditor?.insertText data
			serial.on 'close', (data) =>
				@closeserial()
				atom.notifications.addInfo 'Serial connection closed'
			serial.on 'error', (data) =>
				@closeserial()
				atom.notifications.addInfo 'error in serial connection'
	openserial: ->
		if serial!=null
			return
		
		atom.workspace.open('Serial Monitor').then (editor) =>
			editor.setText ''
			
			editor.onDidDestroy =>
				@closeserial()
			serialeditor = editor
			@openserialport()
	closeserial: ->
		if serial!=null
			serial?.close (err) ->
				return
		serial = null
		if serialeditor!=null
			serialeditor?.destroy()
		serialeditor = null
