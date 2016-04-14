{CompositeDisposable} = require 'atom'
{spawn} = require 'child_process'
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

fs = require 'fs'
path = require 'path'

module.exports = ArduinoUpload =
	config:
		arduinoExecutablePath:
			type: 'string'
			default: 'arduino'

	activate: (state) ->
		# Setup to use the new composite disposables API for registering commands
		@subscriptions = new CompositeDisposable
		@subscriptions.add atom.commands.add "atom-workspace",
			'arduino-upload:build': => @build()
		@subscriptions.add atom.commands.add "atom-workspace",
			'arduino-upload:upload': => @upload()



	deactivate: ->
		@subscriptions.dispose()

	build: ->
		editor = atom.workspace.getActivePaneItem()
		file = editor?.buffer?.file?.getPath()?.split "/"
		file?.pop()
		name = file?.pop()
		file?.push name
		file?.push name+".ino"
		file = file?.join("/")
		dispError = false
		if fs.existsSync(file)
			output = spawn atom.config.get('arduino-upload.arduinoExecutablePath'), [file,'--verify']
			output.stdout.on 'data', (data) ->
				if data.toString().strip().indexOf('Sketch') == 0 || data.toString().strip().indexOf('Global') == 0
					atom.notifications.addInfo(data.toString())
			output.stderr.on 'data', (data) ->
				if data.toString().strip() == "exit status 1"
					dispError = false
				if dispError
					atom.notifications.addError(data.toString())
				if data.toString().strip() == "Verifying..."
					dispError = true
		else
			atom.notifications.addError("File isn't part of an Arduino sketch!")
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
		if fs.existsSync(file)
			output = spawn atom.config.get('arduino-upload.arduinoExecutablePath'), [file,'-v','--upload']
			output.stdout.on 'data', (data) ->
				if data.toString().strip().indexOf('Sketch') == 0 || data.toString().strip().indexOf('Global') == 0
					atom.notifications.addInfo(data.toString())
			output.stderr.on 'data', (data) ->
				if data.toString().strip().indexOf("avrdude:") == 0 && !uploading
					uploading = true
					atom.notifications.addInfo('Uploading sketch...')
				else if data.toString().strip() == "Verifying and uploading..."
					dispError = true
				else if dispError && !uploading
					atom.notifications.addError(data.toString())
			output.on 'close', (code) ->
				if code == 0
					atom.notifications.addInfo('Successfully uploaded sketch')
				else
					atom.notifications.addError("Couldn't upload to board, is it connected?")
		else
			atom.notifications.addError("File isn't part of an Arduino sketch!")
