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
--import CreeperPanel.GlobalActions exposing (addresses, signals)
import AppUtils

import Json.Decode as Decode
import Html
import Time
import Task
import Debug



---- PORTS ----
---------------

-- FPO Thingies --

port fpoServerCredentials : Aries.Credentials



-- Request Template
apiRequest : (Aries.Credentials -> Aries.Request) -> Signal.Signal a -> Signal.Signal (Maybe Aries.EncodedRequest)
apiRequest requestOfCredentials impetusSignal =
    let
        encodedRequest credentials =
            Aries.encodedRequest (requestOfCredentials credentials)

        requestSignal =
            AppUtils.mapMaybeSignal encodedRequest modelServerCredentials
            |> AppUtils.onlyJusts
    in
        Signal.sampleOn impetusSignal requestSignal

-- Log Requests --

-- Automatic Log Requests

port logAutoRequest : Signal (Task.Task x ())
port logAutoRequest =
    let
        sendAutoRequest : a -> Task.Task x ()
        sendAutoRequest _ =
            --Signal.send GlobalActions.addresses |> .logRequest ()
            --Signal.send (.logRequest GlobalActions.addresses) ()
            Signal.send (GlobalActions.addresses |> .logRequest) ()

        ticker : Signal Time.Time
        ticker =
            Time.every (15 * Time.second)
    in           
        Signal.map sendAutoRequest ticker

-- Log API Request Ports

-- Style Note: API should probably be Api to match how other Elm names are written.  Html, Json, etc.
port logAPIRequest : Signal (Maybe Aries.EncodedRequest)
port logAPIRequest =
    let
        encodedRequest credentials =
            Aries.encodedRequest (Aries.consoleLogRequest credentials)

        requestSignal =
            AppUtils.mapMaybeSignal encodedRequest modelServerCredentials
            |> AppUtils.onlyJusts
    in
        Signal.sampleOn (GlobalActions.signals |> .logRequest) requestSignal

port logAPIResponse : Signal (Maybe String)

logAPIDecodedResponse : Signal (Maybe (Result String Aries.Response))
logAPIDecodedResponse =
    Signal.map (Maybe.map (Decode.decodeString Aries.responseDecoder)) logAPIResponse

logAPIResponseReaction : Signal (Maybe State.Action)
logAPIResponseReaction =
    let
        logReactionTo result =
            case result of
                Just (Ok response) ->
                    logReactionToResponse response

                Just (Err message) ->
                    Just (State.UpdateLog (State.UpdateLogStatus (State.Errored message)))

                _ ->
                    Nothing

        logReactionToResponse response =
            case response of
                Aries.Log lines ->
                    Just (State.UpdateLog (State.UpdateLogLines lines))

                Aries.APIError message ->
                    Just (State.UpdateLog (State.UpdateLogStatus (State.Errored message)))

                _ ->
                    Nothing
    in
        Signal.map logReactionTo logAPIDecodedResponse

logAPIRequestReaction : Signal (Maybe State.Action)
logAPIRequestReaction =
    Signal.map
        (always (Just (State.UpdateLog (State.UpdateLogStatus State.Pending))))
        (GlobalActions.signals |> .logRequest)

-- Server Start/Restart/Stop Ports

port serverStartAPIRequest : Signal (Maybe Aries.EncodedRequest)
port serverStartAPIRequest =
    apiRequest
        (\ credentials -> Aries.paramlessRequest credentials ("minecraft", "startserver"))
        (GlobalActions.signals |> .serverStartRequest)

port serverStartAPIResponse : Signal (Maybe String)

serverStartAPIDecodedResponse : Signal (Maybe (Result String Aries.Response))
serverStartAPIDecodedResponse =
    Signal.map (Maybe.map (Decode.decodeString Aries.responseDecoder)) serverStartAPIResponse

serverStartAPIResponseReaction : Signal (Maybe State.Action)
serverStartAPIResponseReaction =
    --let
    --    reactionTo result =
    --        case result of
    --            Just (Ok response) ->
    --                reactionToResponse response

    --            _ ->
    --                Nothing

    --    logReactionToResponse response =
    --        case response of
    --            Aries.GenericSuccess ->
    --                -- TODO: Should probably disable buttons until we have either a response or error.
    --                Nothing

    --            _ ->
    --                Nothing
    --in
    --    Signal.map reactionTo serverStartAPIDecodedResponse
    -- TODO: Actual reactions
    Signal.constant Nothing

-- Server Restart Requests

port serverRestartAPIRequest : Signal (Maybe Aries.EncodedRequest)
port serverRestartAPIRequest =
    apiRequest
        (\ credentials -> Aries.paramlessRequest credentials ("minecraft", "restartserver"))
        (GlobalActions.signals |> .serverStartRequest)

port serverRestartAPIResponse : Signal (Maybe String)

serverRestartAPIDecodedResponse : Signal (Maybe (Result String Aries.Response))
serverRestartAPIDecodedResponse =
    Signal.map (Maybe.map (Decode.decodeString Aries.responseDecoder)) serverRestartAPIResponse

serverRestartAPIResponseReaction : Signal (Maybe State.Action)
serverRestartAPIResponseReaction =
    -- TODO: Actual reactions
    Signal.constant Nothing

-- Server Stop Requests

port serverStopAPIRequest : Signal (Maybe Aries.EncodedRequest)
port serverStopAPIRequest =
    apiRequest
        (\ credentials -> Aries.paramlessRequest credentials ("minecraft", "stopserver"))
        (GlobalActions.signals |> .serverStartRequest)

port serverStopAPIResponse : Signal (Maybe String)

serverStopAPIDecodedResponse : Signal (Maybe (Result String Aries.Response))
serverStopAPIDecodedResponse =
    Signal.map (Maybe.map (Decode.decodeString Aries.responseDecoder)) serverStopAPIResponse

serverStopAPIResponseReaction : Signal (Maybe State.Action)
serverStopAPIResponseReaction =
    -- TODO: Actual reactions
    Signal.constant Nothing



---- MAIN ----
--------------

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

-- convenience signal.
modelServerCredentials : Signal (Maybe Aries.Credentials)
modelServerCredentials =
    model
    |> Signal.map .currentServer
    |> AppUtils.mapMaybeSignal .credentials

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
