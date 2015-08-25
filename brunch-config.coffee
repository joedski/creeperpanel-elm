
exports.config =
	conventions:
		assets: [
			/^app[\/\\]assets[\\/]/
			# Because we're in a node environment, we don't want Brunch to wrap things.
			# /^app[\/\\]js[\\/]/
		]

		ignored: [
			/(^|[\/\\])_/
			/^bower_components[\/\\]bootstrap[\/\\]/
		]

	files:
		javascripts:
			joinTo: "lib.js"

		stylesheets:
			joinTo: "app.css"

			order:
				before: [
					'fonts.less'
					'theme.less'
				]

		templates:
			joinTo: "lib.js"

	plugins:
		elmBrunch:
			mainModules: [ 'app/CreeperPanel.elm' ]
			outputFolder: 'public/'
