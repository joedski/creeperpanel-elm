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
			.split( /(\r?\n)+/ )
			.filter( function( line ) { return !! line; })
			;
	}

	return normalizedResponse;
}

exports.init = function init( elmApp ) {
	elmApp.ports.logAPIRequest.subscribe( function( requestString ) {
		console.log( 'logRequests:', requestString );
		var request = JSON.parse( requestString );
		var ariesRequest = new Aries( request.credentials.key, request.credentials.secret );

		ariesRequest.exec( request.command[ 0 ], request.command[ 1 ], function( parsedResponse, responseStream, rawResponse ) {
			var normalizedResponse = normalizeAriesResponse( parsedResponse );
			elmApp.ports.logAPIResponse.send( JSON.stringify( normalizedResponse ) );
		});
	});
}