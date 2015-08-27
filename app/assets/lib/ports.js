var Aries = require( 'creeperhost-aries' );

function normalizeAriesResponse( parsedResponse ) {
	var normalizedResponse = {
		status: parsedResponse.status
	};

	if( parsedResponse.message ) {
		normalizedResponse.message = parsedResponse.message;
	}

	if( parsedResponse.hasOwnProperty( 'log' ) ) {
		normalizedResponse.log = parsedResponse.log
			// Note: Capture group causes the delimiter to be included in the results, use of non-capturing group prevents this.
			.split( /(?:\r?\n)+/ )
			.filter( function( line ) { return ! /^\s*$/.test( line ); })
			;
	}

	return normalizedResponse;
}

function bindAPIRequestResponsePorts( requestPort, responsePort ) {
	requestPort.subscribe( function( requestString ) {
		var request = JSON.parse( requestString );
		var ariesRequest = new Aries( request.credentials.key, request.credentials.secret );

		ariesRequest.exec( request.command[ 0 ], request.command[ 1 ], request.parameters, function( parsedResponse, responseStream, rawResponse ) {
			var normalizedResponse = normalizeAriesResponse( parsedResponse );
			responsePort.send( JSON.stringify( normalizedResponse ) );
		});
	})
}

exports.init = function init( elmApp ) {
	bindAPIRequestResponsePorts( elmApp.ports.logAPIRequest, elmApp.ports.logAPIResponse );
	bindAPIRequestResponsePorts( elmApp.ports.serverStartAPIRequest, elmApp.ports.serverStartAPIResponse );
	bindAPIRequestResponsePorts( elmApp.ports.serverRestartAPIRequest, elmApp.ports.serverRestartAPIResponse );
	bindAPIRequestResponsePorts( elmApp.ports.serverStopAPIRequest, elmApp.ports.serverStopAPIResponse );
}