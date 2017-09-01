module.exports = 
	class SerialView
		editor: null
		editorView:null
		onDidDestroy: (callback) ->
			@editor.onDidDestroy =>
				callback()
		sendCallback: null
		sendText: ->
			input = @editorView?.querySelector '#arduino-upload-serial-input'
			if input && @sendCallback
				add = ['','\n','\r','\r\n']
				add = add[@editorView?.querySelector('#arduino-upload-serial-lineending').value]
				console.log @editorView?.querySelector('#arduino-upload-serial-lineending').value
				console.log add
				@sendCallback input.value+add
				input.value = ''
		onSend: (@sendCallback) ->
		open: (callback) ->
			atom.workspace.open('Serial Monitor').then (editor) =>
				@editor = editor
				@editor.setText ''
				@editorView = @editor.editorElement
				
				div = document.createElement 'div'
				div.className = 'arduino-upload-serial'
				div.innerHTML = '<input type="text" id="arduino-upload-serial-input" /><select id="arduino-upload-serial-lineending"><option value="0">No line ending</option><option value="1">Newline</option><option value="2">Carriage return</option><option value="3">Both CR &amp; NL</option></select><button id="arduino-upload-serial-send">Send</button>'
				@editorView.childNodes[0].style.height = 'calc(100% - 1.8em)'
				@editorView.appendChild div
				
				input = @editorView.querySelector '#arduino-upload-serial-input'
				input.addEventListener 'focus', (e) =>
					e.preventDefault()
					e.stopPropagation()
				input.addEventListener 'keydown', (e) =>
					e.stopPropagation()
					if e.keyCode == 13 # we hit enter
						@sendText()
				select = @editorView.querySelector '#arduino-upload-serial-lineending'
				select.value = atom.config.get 'arduino-upload.lineEnding'
				select.addEventListener 'change', ->
					atom.config.set 'arduino-upload.lineEnding',@value
				@editorView.querySelector('#arduino-upload-serial-send').addEventListener 'click', (e) =>
					e.preventDefault()
					@sendText()
				callback()
		destroy: ->
			@editor?.destroy()
			sendCallback = null
			@editorView = null
		insertText: (s) ->
			if s instanceof Uint8Array
				s = new TextDecoder('utf-8').decode s
			console.log s
			@editor?.insertText s
