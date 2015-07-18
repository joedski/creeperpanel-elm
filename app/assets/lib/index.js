// index.js - Defines the entry point for the app.

exports.init = function init( Elm ) {
	var testKeys = require( './testkeys.json' );

	var app = Elm.fullscreen( Elm.CreeperPanel, {
		initServer: {
			name: "Retopo All the Things",
			key: testKeys.key,
			secret: testKeys.secret
		},

		logResponses: {
			success: null,
			message: null,
			log: null
		}
	});

	// ports here.
	require( './ports' ).init( app );

	return app;
};
