{View} = require 'atom-space-pen-views'
escape = (s) -> 
	s.replace(/&/g,'&amp;' ).replace(/</g,'&lt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;')

{ seperator } = require './util'

module.exports = 
	class OutputView extends View
		message: ''
		
		@content: ->
			@div class: 'arduino-upload info-view', =>
				@button click: 'close', class: 'btn', 'close'
				@pre class: 'output', @message
		@initialize: ->
			super
		addLine: (line, tmppath = '', path = '') ->
			if tmppath && path
				line = line.replace /((?:\/|\n|^)[\w\-\/\.]+:)(\d)*/gi, (match) =>
					# ok here we parse whcih filenames are clickable
					
					# extra holds the additional path in front, whch isn't clickable (such as the sketch path, or the tmp path)
					extra = ''
					# line holds the line number to jump to
					line = -1
					# match is the current thing to parse
					if !match.endsWith ':'
						line = match.substring match.lastIndexOf(':')+1
					match = match.substring 0, match.lastIndexOf(':') # we need this anyways to strip the last char
					
					# check if it is in the tmp directory. stripping that from the link
					if match.strip().startsWith tmppath
						extra += tmppath
						match = match.substring tmppath.length
						# strip optional trailing seperator
						if match[0] == seperator
							extra += seperator
							match = match.substring 1
					# make sure that we are in the sketch folder
					if match.strip().substring(0, 7) == 'sketch' + seperator
						extra += 'sketch' + seperator
						match = match.substring 7
					
					# generate nice output
					file = match
					match += ':'
					if line != -1
						match += line
					file = file.strip()
					if seperator != file.substring 0,1
						file = path + seperator + file
					if file.lastIndexOf('.')==-1 || file.lastIndexOf('.')+20 < file.length
						file += '.ino'
					extra+'<a data-line="'+line+'" data-file="'+escape(file)+'">'+match+'</a>'
			@message += line
			this
		reset: ->
			@message = ''
		finish: ->
			if @message.trim() == ''
				@message = ''
				@hide()
				return
			@find('pre').html @message
			
			for elem in @find('pre a')
				elem.addEventListener 'click', ->
					for pane in atom.workspace.getPanes()
						for editor in pane.getItems()
							if editor.getPath && editor.getPath() == @dataset.file
								pane.activateItem editor
								if @dataset.line != -1
									editor.setCursorBufferPosition [@dataset.line - 1,0]
									editor.scrollToCursorPosition() # center the cursor
								pane.activate()
								return
					atom.workspace.open(@dataset.file).then (editor) =>
						if @dataset.line != -1
							editor.setCursorBufferPosition [@dataset.line - 1,0]
							editor.scrollToCursorPosition() # center the cursor
			@show()
		close: ->
			@hide()
