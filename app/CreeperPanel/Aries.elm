module CreeperPanel.Aries
    ( Request
    , Credentials
    , consoleLogRequest
    , consoleCommandRequest
    , EncodedRequest
    , Response(..)
    , responseDecoder
    )
    where

import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode

{-
Initializing Response Ports
===========================

Response Ports should be initialized with a null, which will be decoded as a NullResponse.
This also means at any time, a null may be written, and it will be decoded as such.
-}

---- Requests ----

type alias Request =
    { credentials : Credentials
    , command : (String, String)
    -- In the Aries API that CreeperHost published, if no data object was passed,
    -- an empty JSON object was used.  The same applies here, passing an empty list if you have no arguments.
    , parameters : List (String, String)
    }

type alias Credentials =
    { key : String
    , secret : String
    }

request : Credentials -> (String, String) -> List (String, String) -> Request
request credentials command parameters =
    { credentials = credentials
    , command = command
    , parameters = parameters
    }

paramlessRequest : Credentials -> (String, String) -> Request
paramlessRequest credentials command =
    request credentials command []

consoleLogRequest : Credentials -> Request
consoleLogRequest credentials =
    paramlessRequest credentials ("minecraft", "readconsole")

consoleCommandRequest : Credentials -> String -> Request
consoleCommandRequest credentials command =
    request credentials ("minecraft", "writeconsole") [("command", command)]



---- Requests: Encoded ----

type alias EncodedRequest = String

encodedRequest : Request -> String
encodedRequest request =
    let
        encodeCredentials credentials =
            Encode.object
                [ ( "key", Encode.string credentials.key )
                , ( "secret", Encode.string credentials.secret )
                ]

        encodeCommand (section, command) =
            Encode.list
                [ Encode.string section
                , Encode.string command
                ]

        encodeParameters parameters =
            Encode.list
                List.map
                    ((paramName, paramValue) ->
                        [ Encode.string paramName
                        , Encode.string paramValue
                        ])
                    parameters
    in
        Encode.encode 4
            Encode.object
                [ ( "credentials", encodeCredentials )
                , ( "command", encodeCommand )
                , ( "parameters", encodeParameters )
                ]



---- Responses ----

type Response
    = NullResponse
    | GenericSuccess
    | Log (List String)
    | APIError String

responseDecoder : Decode.Decoder Response
responseDecoder =
    Decode.oneOf
        [ Decode.null NullResponse
        , nonNullResponseDecoder
        ]

nonNullResponseDecoder : Decode.Decoder Response
nonNullResponseDecoder =
    ("status" := Decode.string) `Decode.andThen` \ status ->
        case status of
            "success" ->
                Decode.oneOf
                    [ logResponseDecoder
                    , Decode.succeed GenericSuccess
                    ]

            "error" ->
                ("message" := Decode.string)
                `Decode.andThen` message -> Decode.succeed message

            _ ->
                Decode.fail ("Encountered unknown response status: " ++ status)

logResponseDecoder : Decode.Decoder Response
logResponseDecoder =
    ("log" := Decode.list Decode.string)
        `Decode.andThen` \ logLines ->
            Decode.succeed (Log logLines)
