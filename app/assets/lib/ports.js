exports.init = function init( elmApp ) {
	var counter = 0;

	elmApp.ports.logRequests.subscribe( function( request ) {
		console.log( 'logRequests:', request );

		sendResponseLater( counter );

		++counter;

		function sendResponseLater( count ) {
			setTimeout( actualSend, 2000 );

			function actualSend() {
				elmApp.ports.logResponses.send({
					success: true,
					message: null,
					log: getPretendLogLines( count )
				});
			}
		}

		function getPretendLogLines( count ) {
			var i, r = [];

			for( i = 0; i <= count; ++i ) {
				r.push( "Line " + String( i ) );
			}

			return r;
		}
	});
}