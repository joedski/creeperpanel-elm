var app = require( 'app' );
var BrowserWindow = require( 'browser-window' );

// Report any crashes to Electron team.
require( 'crash-reporter' ).start();

// Keep a reference to any window you want to remain open.  GCed (Garbage Collected) windows are automatically closed.
var mainWindow = null;

app.on( 'window-all-closed', function() {
	// In most platforms, closing the last window also closes the app.
	// This is not the case on Macs, which remain open until the user tells it to close.

	// Notice that `process` is already in scope.
	if( process.platform != 'darwin' ) {
		app.quit();
	}
});

app.on( 'ready', function() {
	mainWindow = new BrowserWindow({ width: 1300, height: 800 });
	mainWindow.loadUrl( localAsset( 'public/index.html' ) );
	mainWindow.openDevTools();

	mainWindow.on( 'closed', function() {
		// Make sure to null out or remove any refs to windows that have been closed.
		mainWindow = null;
	});
});

function localAsset( assetPath ) {
	if( assetPath.indexOf( '/' ) !== 0 ) {
		assetPath = '/' + assetPath;
	}

	return 'file://' + __dirname + assetPath;
}
