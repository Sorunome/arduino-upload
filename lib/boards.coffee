{SelectListView} = require 'atom-space-pen-views'
{spawn} = require 'child_process'
Promise = require 'bluebird'
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""
fs = require 'fs'

readdir = Promise.promisify(fs.readdir)
readFile = Promise.promisify(fs.readFile)
{ seperator, getArduinoPath } = require './util'
module.exports = 
	class Boards extends SelectListView
		inited: false
		loaded: false
		boards: {}
		statusBar: null
		selectNode: null
		init: =>
			if @inited
				return
			@div = document.createElement 'div'
			@div.className = 'inline-block arduino-upload'
			@div.style.display = 'none'
			@inited = true
		addBoards: (pkg, arch, file) ->
			return readFile(file).then((data) =>
				re = /(\w+)\.name=([^\r\n]+)/g
				data = data.toString()
				while matches = re.exec data
					@boards[pkg+':'+arch+':'+matches[1]] = matches[2]
			).catch((err) =>
				# do nothing
			)
		destroy: (partial = false) ->
			if @loaded
				boards = {}
				loaded = false
			if not partial
				@statusBar?.destroy()
		parseNewPath: (path) ->
			return readdir(path).then((files) =>
				Promise.each(files, (pkg) =>
					path2 = path + seperator + pkg + seperator + 'hardware'
					readdir(path2).then((files) =>
						Promise.each(files, (arch) =>
							path3 = path2 + seperator + arch
							readdir(path3).then((files) =>
								Promise.each(files, (version) =>
									path4 = path3 + seperator + version
									return @addBoards pkg, arch, path4 + seperator + 'boards.txt'
								)
							).catch((err) =>
								# do nothing
							)
						)
					).catch((err) =>
						# do nothing
					)
				)
			).catch((err) =>
				# do nothing
			)
		parseOldPath: (path) ->
			return readdir(path).then((files) =>
				Promise.each(files, (pkg) =>
					path2 = path + seperator + pkg
					readdir(path2).then((files) =>
						Promise.each(files, (arch) =>
							return @addBoards pkg, arch, path2 + seperator + arch + seperator + 'boards.txt'
						)
					).catch((err) => 
						# do nothing
					)
				)
			).catch((err) =>
				# do nothing
			)
		load: ->
			@div.innerHTML = 'Loading arduino boards...'
			if @loaded
				@destroy true
			# first we parse the arduino15 file structure
			path = ''
			if /^win/.test process.platform
				path = process.env.LOCALAPPDATA + seperator + 'Arduino15'
			else if process.platform == 'darwin'
				path = process.env.HOME + seperator + 'Arduino15'
			else
				path = process.env.HOME + seperator + '.arduino15'
			path += seperator + 'packages'
			@parseNewPath(path).then( =>
				if /^win/.test process.platform
					path = getArduinoPath().split(seperator)
					path.pop()
					path = path.join(seperator) + seperator + 'hardware'
					return @parseOldPath(path)
			).then( =>
				# parse the pre-arduino 1.5 boards
				stdoutput = spawn getArduinoPath(), ['--get-pref', 'sketchbook.path']
				return new Promise((resolve, reject) =>
					res = ''
					stdoutput.stdout.on 'data', (data) =>
						res += data.toString()
					stdoutput.on 'close', (code) =>
						if code
							reject code
						else
							res = res.split('\r').join('').split('\n')
							while !res[res.length - 1] # remove the empty lines
								res.pop()
							res = res[res.length - 1]
							resolve res
				).then((path) => 
					path = path.strip() + seperator + 'hardware'
					@parseOldPath(path)
				)
			).finally( =>
				console.log "Boards found:", @boards
				@loaded = true
				@populateStatusBar()
			)
		set: (val) ->
			if !@loaded || !@selectNode
				return # trash
			if @boards[val] || val == ''
				@selectNode.value = val
			else
				@selectNode.value = 'ignore'
		populateStatusBar: ->
			@div.innerHTML = ''
			@selectNode = document.createElement 'select'
			
			op = new Option()
			op.value = ''
			op.text = '== Arduino Setting =='
			@selectNode.options.add op
			op = new Option()
			op.value = 'ignore'
			op.text = '== Custom Setting =='
			@selectNode.options.add op
			for board of @boards
				op = new Option()
				op.value = board
				op.text = @boards[board]
				@selectNode.options.add op
			@div.appendChild @selectNode
			
			cfg = atom.config.get 'arduino-upload.board'
			if @boards[cfg] || cfg == ''
				@selectNode.value = cfg
			else
				@selectNode.value = 'ignore'
			@selectNode.onchange = ->
				if @value != 'ignore'
					atom.config.set 'arduino-upload.board', @value
		setStatusBar: (sb) ->
			@statusBar = sb.addRightTile item: @div, priority: 5
		hide: ->
			@div.style.display = 'none'
		show: ->
			@div.style.display = ''
