module CreeperPanel.Ports
    ( logRequests
    , credentialsOfServer
    , logResponseReactions
    )
    where

import Json.Decode as Decode exposing ((:=))
import Time
import CreeperPanel.Aries as Aries
import CreeperPanel.Model as Model
import CreeperPanel.Actions as Actions

import Debug

-- Action signals from responses need to be type Signal (Maybe Action),
-- but response signals must be Signal SomeResponse



----- Utility Functions -----

boolOfMaybe : Maybe a -> Bool
boolOfMaybe maybeSomething =
    case maybeSomething of
        Just something -> True

        Nothing -> False

reactionTo : Result String Aries.Response -> Maybe Actions.Action
reactionTo responseResult =
    case (Debug.log "reactionTo" responseResult) of
        Ok response ->
            case response of
                Aries.NullResponse -> Nothing

                Aries.Log logLines ->
                    Just (Actions.UpdateLog (Model.logModelOf logLines))

                -- In the future this may carry additional information.  But for now, it does nothing.
                Aries.GenericSuccess -> Nothing                

        Err message ->
            Nothing |> Debug.log ("Error: " ++ message)



----- Internal Details -----

logTicker : Signal Time.Time
logTicker =
    Time.every (Time.second * 10)



----- Public Functions -----

-- I can't think of anothing way to do this yet,
-- so I'm just starting with Nothing which, on output, I think maps to JS null.
-- JS cannot, however, pass a null back as a port value.
logRequests : Signal (Maybe Aries.Credentials) -> Signal (Maybe Aries.Request)
logRequests maybeCredentialsSignal =
    let
        maybeCredentialsSignalOnTick : Signal (Maybe Aries.Credentials)
        maybeCredentialsSignalOnTick =
            Signal.sampleOn logTicker maybeCredentialsSignal
    in
        Signal.map
            (Maybe.map Aries.consoleLogRequest)
            maybeCredentialsSignalOnTick
        |> Signal.filter
            boolOfMaybe
            Nothing

credentialsOfServer : Model.ServerModel -> Aries.Credentials
credentialsOfServer server =
    { key = server.key
    , secret = server.secret
    }

-- Doing the same thing again here with filtering Nothings.
-- Can't think of a better way to do this. but at least here it's hidden.
-- While I'm reasonably sure Nothing will only appear as the initial value,
-- this still feels skeevy.
logResponseReactions : Signal String -> Signal (Maybe Actions.Action)
logResponseReactions logResponses =
    let
        decodeResponse =
            Decode.decodeString Aries.responseDecoder
    in
        Signal.map
            (reactionTo << decodeResponse)
            logResponses
        |> Signal.filter
            boolOfMaybe
            Nothing
