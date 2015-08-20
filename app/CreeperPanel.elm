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
import Debug



---- PORTS ----

port fpoServerCredentials : Aries.Credentials

-- Automatic Log Requests

port logAutoRequest : Signal (Task.Task x ())
port logAutoRequest =
    let
        sendAutoRequest : a -> Task.Task x ()
        sendAutoRequest _ =
            Signal.send addresses.logRequest ()

        ticker : Signal Time.Time
        ticker =
            Time.every (15 * Time.second)
    in           
        Signal.map sendAutoRequest ticker

port logAPIRequest : Signal (Maybe Aries.EncodedRequest)
port logAPIRequest =
    let
        encodedRequest credentials =
            Aries.encodedRequest (Aries.consoleLogRequest credentials)

        currentCredentials =
            model
            |> Signal.map .currentServer
            |> AppUtils.mapMaybeSignal .credentials

        requestSignal =
            AppUtils.mapMaybeSignal encodedRequest currentCredentials
            |> AppUtils.onlyJusts
    in
        Signal.sampleOn signals.logRequest requestSignal

port logAPIResponse : Signal (Maybe String)

logAPIDecodedResponse : Signal (Maybe (Result String Aries.Response))
logAPIDecodedResponse =
    Signal.map (Maybe.map (Decode.decodeString Aries.responseDecoder)) logAPIResponse

logAPIResponseReaction : Signal (Maybe State.Action)
logAPIResponseReaction =
    let
        logReactionTo result =
            case result of
                Nothing ->
                    Nothing

                Just (Ok response) ->
                    logReactionToResponse response

                Just (Err message) ->
                    Nothing |> Debug.log message

        logReactionToResponse response =
            case response of
                Aries.NullResponse ->
                    Nothing

                Aries.GenericSuccess ->
                    Nothing

                Aries.Log lines ->
                    Just (State.UpdateLog (State.UpdateLogLines lines))

                Aries.APIError message ->
                    Just (State.UpdateLog (State.UpdateLogStatus (State.Errored message)))
    in
        Signal.map logReactionTo logAPIDecodedResponse

logAPIRequestReaction : Signal (Maybe State.Action)
logAPIRequestReaction =
    Signal.map
        (always (Just (State.UpdateLog (State.UpdateLogStatus State.Pending))))
        signals.logRequest



---- MAIN ----

model : Signal State.Model
model =
    let
        -- Turn Maybes into NoOps/Actions.
        update =
            AppUtils.noUpdateOrJustAction State.update

        -- Hold test server info.
        initModel =
            initModelWithFPOServer State.initModel fpoServerCredentials

        initModelWithFPOServer model credentials =
            { model
                | currentServer <- Just (fpoServerFromCredentials credentials)
            }

        fpoServerFromCredentials credentials =
            State.ServerModel "FPO Server (Default Instance)" credentials
    in
        Signal.foldp
            update
            initModel
            appActions

appActions : Signal (Maybe State.Action)
appActions =
    Signal.mergeMany
        [ localActions.signal
        , logAPIResponseReaction
        , logAPIRequestReaction
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
