module CreeperPanel where

import CreeperPanel.State as State
import CreeperPanel.View as View
import CreeperPanel.Aries as Aries
import CreeperPanel.GlobalActions as GlobalActions
-- In order to actually use the attributes of an exposed record, you have to expose it into the current namespace.
-- Things like Foo.foos.foobar do not work.
-- Because... Elm looks for a module named Foo.foos?  That seems odd.
-- That seems borne out by tests.  With the following `exposing` line,
-- addresses.logRequest works.  However, after this,
-- I tried (.logRequest GlobalActions.addresses), and that also worked.
-- Being that direct function application works, of course it can be
-- rewritten with forward application into (GlobalActions.addresses |> .logRequest)
-- Which reads more sensically except for the random `|>`.
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
            --Signal.send (.logRequest GlobalActions.addresses) ()
            --Signal.send (GlobalActions.addresses |> .logRequest) ()

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
