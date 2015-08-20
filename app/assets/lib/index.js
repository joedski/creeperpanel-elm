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

		// Note: Although JSON is passed in as a string, this port is a Maybe,
		// and therefore passing null yields a Nothing.
		// A string is interpreted as a valid response. (Although the error case is handled.)
		logAPIResponse: null
	});

	// ports here.
	require( './ports' ).init( app );

	return app;
};
