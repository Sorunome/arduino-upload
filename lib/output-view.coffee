{View} = require 'atom-space-pen-views'

module.exports = 
	class OutputView extends View
		message: ''
		
		@content: ->
			@div class: 'arduino-upload info-view', =>
				@button click: 'close', class: 'btn', 'close'
				@pre class: 'output', @message
		@initialize: ->
			super
		addLine: (line) ->
			@message += line
			this
		reset: ->
			@message = ''
		finish: ->
			if @message.trim() == ''
				@message = ''
				@hide()
				return
			@find('pre').text(@message)
			@show()
		close: ->
			@hide()
