// index.js - Defines the entry point for the app.

exports.init = function init( Elm ) {
	var testKeys = require( './testkeys.json' );

	var app = Elm.fullscreen( Elm.CreeperPanel, {
		// Records are fine as long as they do not contain compound sub-items like Lists or other Records.
		// Specifically, Arrays probably still cause problems unless you explicitly convert them to
		// browser-context Arrays from Node-context arrays.
		fpoServerCredentials: {
			key: testKeys.key,
			secret: testKeys.secret
		},

		// All JSON passed between contexts should be in the form JSON strings.
		// logAPIResponse: "null"

		// logAPIResponse: {
		// 	success: null,
		// 	message: null,
		// 	log: null
		// }
	});

	// ports here.
	require( './ports' ).init( app );

	return app;
};
