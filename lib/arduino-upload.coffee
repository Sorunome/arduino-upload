{CompositeDisposable} = require 'atom'
{spawn} = require 'child_process'
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

fs = require 'fs'
path = require 'path'
OutputView = require './output-view'

output = null

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
		
		output = new OutputView
		atom.workspace.addBottomPanel(item:output)
		output.hide()



	deactivate: ->
		@subscriptions.dispose()
		output?.remove()

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
