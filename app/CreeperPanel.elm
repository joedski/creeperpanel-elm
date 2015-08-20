module CreeperPanel where

import CreeperPanel.State as State
import CreeperPanel.View as View
import CreeperPanel.Aries as Aries
import CreeperPanel.GlobalActions as GlobalActions
import CreeperPanel.GlobalActions exposing (addresses, signals)
import AppUtils

import Json.Decode as Decode
import Html
import Time
import Task



---- PORTS ----

-- Automatic Log Requests

port fpoServerCredentials : Signal Aries.Credentials

port logAutoRequest : Signal (Task.Task x ())
port logAutoRequest =
    let
        sendAutoRequest : a -> Task.Task x ()
        sendAutoRequest _ =
            Signal.send addresses.logRequest ()

        ticker : Signal Time.Time
        ticker =
            Time.every Time.second
    in           
        Signal.map sendAutoRequest ticker
--    let
--        sendAutoRequest _ =
--            Task.send GlobalActions.addresses.logRequest

-- on GA.logRequest.signal, if current server credentials, update logAPIRequest port to new request using current server credentials.
{-
on GlobalActions.signals.logRequest:
    Just credentials ->
        Just encodedRequest (consoleLogRequest credentials)
    |> onlyJusts
-}
port logAPIRequest : Signal (Maybe Aries.EncodedRequest)
port logAPIRequest =
    let
        encodedRequest credentials =
            Aries.encodedRequest (Aries.consoleLogRequest credentials)

        currentCredentials =
            Signal.map Just fpoServerCredentials

        requestSignal =
            Signal.map (Maybe.map encodedRequest) currentCredentials
            |> AppUtils.onlyJusts
    in
        Signal.sampleOn signals.logRequest requestSignal

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
