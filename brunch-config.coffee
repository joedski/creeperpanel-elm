
exports.config =
	conventions:
		assets: [
			/^app[\/\\]assets[\\/]/
			# Because we're in a node environment, we don't want Brunch to wrap things.
			/^app[\/\\]js[\\/]/
		]

	files:
		javascripts:
			joinTo: "index.js"

		stylesheets:
			joinTo: "index.css"

		templates:
			joinTo: "index.js"

	plugins:
		elmBrunch:
			mainModules: [ 'app/CreeperPanel.elm' ]
			outputFolder: 'public/'
