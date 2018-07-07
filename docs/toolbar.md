# Arduino Upload Package

## Add a toolbar

You can install `tool-bar` and `flex-tool-bar` Atom packages and use them to add a toolbar for Arduino commands, similar to the one in the official IDE.

	apm install tool-bar
	apm install flex-tool-bar
	
The following is an example for the Flex Tool Bar's configuration file, `toolbar.cson`. It adds the buttons for Arduino **Verify** and **Upload** commands (automatically saving the current file before), and another to open the **Serial Monitor**.

	[
	  {
		type: "button"
		icon: "check"
		callback: ["core:save", "arduino-upload:verify"]
		tooltip: "Arduino: Verify",
		enable: { grammar: "arduino" }
	  }
	  {
		type: "button"
		icon: "arrow-right"
		callback: ["core:save", "arduino-upload:upload"]
		tooltip: "Arduino: Upload",
		enable: { grammar: "arduino" }
	  }
	  {
		type: "button"
		icon: "terminal"
		callback: "arduino-upload:serial-monitor"
		tooltip: "Arduino: Serial monitor",
		enable: { grammar: "arduino" }
	  }
	  {
		type: "spacer"
	  }
	  {
		type: "button"
		icon: "gear"
		callback: "flex-tool-bar:edit-config-file"
		tooltip: "Edit Tool Bar"
	  }
	]
