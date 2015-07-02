// index.js - Defines the entry point for the app.

exports.init = function init( Elm ) {
	// elm stuff.
	// var Elm = window.Elm;

	var app = Elm.fullscreen( Elm.CreeperPanel );

	// ports here.

	return app;
};
