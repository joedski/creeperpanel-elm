module CreeperPanel where

import CreeperPanel.State as State
import CreeperPanel.View as View
import AppUtils as AppUtils

import Json.Decode as Decode
import Html



---- PORTS ----

-- Automatic Log Requests

--port logAutoRequest : Signal (Task x ())
--port logAutoRequest =
--    let
--        sendAutoRequest _ =
--            Task.send GlobalActions.addresses.logRequest

-- on GA.logRequest.signal, if current server credentials, update logAPIRequest port to new request using current server credentials.
--port logAPIRequest : Signal (Maybe Aries.EncodedRequest)
--port logAPIRequest =
--    let

    --let
    --    onLogRequest =
    --        Signal.sampleOn GlobalActions.signals.logRequest

    --    credentials model =
    --        { key = model.server.key
    --        , secret = model.server.secret
    --        }

    --    request _ (Just credentials) ->
    --        { credentials = credentials
    --        , command = ("minecraft", "readconsole")
    --        , parameters = []
    --        }

    --in
    --    Signal.map request
    --        GlobalActions.signals.logRequest
    --        (Signal.map (Maybe.map credentials) model)
    --    |> onLogRequest
    --    |> AppUtils.onlyJusts
    --    |> Signal.map Aries.encodeRequest


--port logAPIResponse : Signal (Maybe Encode.Value)



---- MAIN ----

model : Signal State.Model
model =
    let
        -- Turn Maybes NoOps/Actions.
        update =
            AppUtils.noUpdateOrJustAction State.update
    in
        Signal.foldp
            update
            State.initModel
            appActions

appActions : Signal (Maybe State.Action)
appActions =
    Signal.mergeMany
        [ localActions.signal
        ]
    |> AppUtils.onlyJusts

localActions : Signal.Mailbox (Maybe State.Action)
localActions =
    Signal.mailbox Nothing

main : Signal Html.Html
main =
    let
        localActionsAddress : Signal.Address State.Action
        localActionsAddress =
            Signal.forwardTo localActions.address Just
    in
        Signal.map (View.view localActionsAddress) model
