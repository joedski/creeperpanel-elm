module CreeperPanel.Ports
    ( logRequests
    , credentialsOfServer
    )
    where

import Time
import CreeperPanel.Aries as Aries
import CreeperPanel.Model as Model

-- Action signals from responses need to be type Signal (Maybe Action),
-- but response signals must be Signal SomeResponse

logTicker : Signal Time.Time
logTicker =
    Time.every (Time.second * 10)

-- I can't think of anothing way to do this yet,
-- so I'm just starting with Nothing which, on output, I think maps to JS null.
-- JS cannot, however, pass a null back as a port value.
logRequests : Signal (Maybe Aries.Credentials) -> Signal (Maybe Aries.Request)
logRequests maybeCredentialsSignal =
    let
        maybeCredentialsSignalOnTick : Signal (Maybe Aries.Credentials)
        maybeCredentialsSignalOnTick =
            Signal.sampleOn logTicker maybeCredentialsSignal

        skipNothings m =
            case m of
                Just a -> True

                Nothing -> False
    in
        Signal.map
            (Maybe.map Aries.consoleLogRequest)
            maybeCredentialsSignalOnTick
        |> Signal.filter
            skipNothings
            Nothing

credentialsOfServer : Model.ServerModel -> Aries.Credentials
credentialsOfServer server =
    { key = server.key
    , secret = server.secret
    }
