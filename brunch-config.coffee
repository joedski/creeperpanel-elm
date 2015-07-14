
exports.config =
	conventions:
		assets: [
			/^app[\/\\]assets[\\/]/
			# Because we're in a node environment, we don't want Brunch to wrap things.
			# /^app[\/\\]js[\\/]/
		]

	files:
		javascripts:
			joinTo: "lib.js"

		stylesheets:
			joinTo: "app.css"

		templates:
			joinTo: "lib.js"

	plugins:
		elmBrunch:
			mainModules: [ 'app/CreeperPanel.elm' ]
			outputFolder: 'public/'
