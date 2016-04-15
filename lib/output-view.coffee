{View} = require 'atom-space-pen-views'
escape = (s) -> 
	s.replace(/&/g,'&amp;' ).replace(/</g,'&lt;').
			replace(/"/g,'&quot;').replace(/'/g,'&#039;')


module.exports = 
	class OutputView extends View
		message: ''
		
		@content: ->
			@div class: 'arduino-upload info-view', =>
				@button click: 'close', class: 'btn', 'close'
				@pre class: 'output', @message
		@initialize: ->
			super
		addLine: (line,path = '') ->
			if path
				line = line.replace /((?:\/|\n|^)[\w\-\/\.]+:)(\d)*/gi, (match) =>
					extra = ''
					line = -1
					if !match.endsWith ':'
						line = match.substring match.lastIndexOf(':')+1
					match = match.substring 0,match.lastIndexOf(':') # we need this anyways to strip the last char
					if match.strip().substring(0,7) == 'sketch/'
						extra = 'sketch/'
						match = match.substring 7
					file = match
					match += ':'
					if line != -1
						match += line
					file = file.strip()
					if '/' != file.substring 0,1
						file = path + '/' + file
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
					atom.workspace.open(@dataset.file).then (editor) =>
						if @dataset.line != -1
							editor.setCursorBufferPosition [@dataset.line - 1,0]
							editor.scrollToCursorPosition() # center the cursor
			@show()
		close: ->
			@hide()
