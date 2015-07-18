module CreeperPanel.Aries
    ( Request
    , Credentials
    , consoleLogRequest
    , consoleCommandRequest
    , GenericResponse
    , LogResponse
    , genericNonresponse
    , logNonresponse
    )
    where

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

genericRequest : Credentials -> (String, String) -> List (String, String) -> Request
genericRequest credentials command parameters =
    { credentials = credentials
    , command = command
    , parameters = parameters
    }

paramlessRequest : Credentials -> (String, String) -> Request
paramlessRequest credentials command =
    genericRequest credentials command []

consoleLogRequest : Credentials -> Request
consoleLogRequest credentials =
    paramlessRequest credentials ("minecraft", "readconsole")

consoleCommandRequest : Credentials -> String -> Request
consoleCommandRequest credentials command =
    genericRequest credentials ("minecraft", "writeconsole") [("command", command)]



---- Responses ----

type alias GenericResponse =
    { success : Maybe Bool
    , message : Maybe String
    }

type alias LogResponse =
    { success : Maybe Bool
    , message : Maybe String
    , log : Maybe (List String)
    }

genericNonresponse : GenericResponse
genericNonresponse =
    { success = Nothing
    , message = Nothing
    }

logNonresponse : LogResponse
logNonresponse =
    { success = Nothing
    , message = Nothing
    , log = Nothing
    }
