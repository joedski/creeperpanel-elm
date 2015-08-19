exports.init = function init( elmApp ) {
	// var counter = 0;

	// elmApp.ports.logRequests.subscribe( function( request ) {
	// 	console.log( 'logRequests:', request );

	// 	sendResponseLater( counter );

	// 	++counter;

	// 	function sendResponseLater( count ) {
	// 		setTimeout( actualSend, 2000 );
	
		// 	function actualSend() {
		// 		// Stringifying because Elm bugs out if you pass an array created in the Node context rather than in the Webkit context.
		// 		// You have to in some manner bring in the window object, and use window.Array.apply( null, nodeSideArray ) to generate a compliant array.
		// 		elmApp.ports.logResponses.send( JSON.stringify({
		// 			status: "success",
		// 			// message: null,
		// 			log: getPretendLogLines( count )
		// 		}));
		// 	}
		// }

	// 	function getPretendLogLines( count ) {
	// 		var i, r = [];

	// 		for( i = 0; i <= count; ++i ) {
	// 			r.push( "Line " + String( i ) );
	// 		}

	// 		return r;
	// 	}
	// });
}