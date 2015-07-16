Musing - Services
=================



Aries
-----

There are a few parts where CreeperHost's Aries is needed.

- Console Log
- Server Stats
- Sending Commands

It'll be easiest to set these up as 3 separate items.

### API Requests

The key and secret are alawys sent with each API request.  It makes no difference on the client side, as they must be sent each time the client actually hits up the API server anyway.

#### JSON

Usual command structure:

```json
{
	"command": [ "section", "command" ],
	"parameters": {
		"key": "beepboop@blap.creeperhost.net",
		"secret": "BEEFBEEFBEEFBEEF",
		"data": {}
	}
}
```

Command structure for console commands:

```json
{
	"command": [ "section", "command" ],
	"parameters": {
		"key": "beepboop@blap.creeperhost.net",
		"secret": "BEEFBEEFBEEFBEEF",
		"data": {
			"command": "say BOW BEFORE YOUR GOD"
		}
	}
}
```

### API Responses

Usual response structure for successful API calls.

```json
{
	"status": "success"
}
```

Console Log response:

```json
{
	"status": "success",
	"log": [
		"BLAH BLAH BLAH BLAH BLAH",
		"BLAH BLAH BLAH BLAH BLAH"
	]
}

// This is the raw JSON response:
{
	"status": "success",
	"log": "BLAH BLAH BLAH BLAH BLAH\nBLAH BLAH BLAH BLAH BLAH",
	"count": 2, // or however many lines there are.
	"debug": 0
}
```

Usual response structure for unsuccessful API calls.

```json
{
	"status": "error",
	"message": "You done messed up."
}
```
