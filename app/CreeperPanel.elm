module CreeperPanel where

import Html
import Html.Attributes as Ats
import Html.Events as Events
import Time



-- ======== Model ======== --

type alias Model =
    { log : ConsoleLogModel
    , currentServer : Maybe ServerModel
    , serverStats : ServerStatsModel
    }

type alias ConsoleLogModel =
    LoadingStated
        { lines : List ConsoleLogLineModel
        }

type alias ServerModel =
    { name : String
    , key : String
    , secret : String
    }

type alias ServerStatsModel =
    LoadingStated
        { cpu : Float
        , ram : Float
        , hdd : Float
        }

type alias ConsoleLogLineModel =
    { text : String
    }

type alias LoadingStated a =
    { a
        | loadingStatus : LoadingStatus
    }



type LoadingStatus
    = NotLoaded
    | AwaitingUpdate
    | Updated
    | Errored String



initModel : Model
initModel =
    { log =
        { lines = []
        , loadingStatus = NotLoaded
        }
    , currentServer = Just
        { name = ""
        , key = ""
        , secret = ""
        }
    , serverStats =
        { cpu = 0
        , ram = 0
        , hdd = 0
        , loadingStatus = NotLoaded
        }
    }



-- ======== Actions ======== --

type Action
    = StartLoadingLog
    | UpdateLog ConsoleLogModel
    | ErrorLog String
    | StartLoadingServerStats
    | UpdateServerStats ServerStatsModel
    | ErrorServerStats String



-- ======== Update ======== --

update : Action -> Model -> Model
update action model =
    case action of
        StartLoadingLog ->
            { model | log <- updateLoadingStatus AwaitingUpdate model.log }

        UpdateLog newLog ->
            { model | log <- updateLoadingStatus Updated newLog }

        ErrorLog message ->
            { model | log <- updateLoadingStatus (Errored message) model.log }
            
        StartLoadingServerStats ->
            { model | serverStats <- updateLoadingStatus AwaitingUpdate model.serverStats }

        UpdateServerStats newServerStats ->
            { model | serverStats <- updateLoadingStatus Updated newServerStats }

        ErrorServerStats message ->
            { model | serverStats <- updateLoadingStatus (Errored message) model.serverStats }

updateLoadingStatus : LoadingStatus -> LoadingStated a -> LoadingStated a
updateLoadingStatus status statedModel =
    { statedModel | loadingStatus <- status }



-- ======== View ======== --

view : Signal.Address Action -> Model -> Html.Html
view address model =
    Html.div [ Ats.class "app" ]
        [ viewConsole address model
        ]

viewConsole : Signal.Address Action -> Model -> Html.Html
viewConsole address model =
    Html.div [ Ats.class "console" ]
        [ viewConsoleLog address model.log
        ]

viewConsoleLog : Signal.Address Action -> ConsoleLogModel -> Html.Html
viewConsoleLog address model =
    Html.div [ Ats.class "console-log" ]
        List.map (viewConsoleLogLine address) model.lines

viewConsoleLogLine : Signal.Address Action -> ConsoleLogLineModel -> Html.Html
viewConsoleLogLine address model =
    Html.div [ Ats.class "console-log-line" ] [ text model.text ]

-- TODO: Server Stats.



-- ======== Wiring: Ports ======== --

logTicker : Signal Time.Time
logTicker =
    Time.every (Time.second * 10)

----- Aries: Console Log -----

type alias AriesEmptyParameters =
    { data : {} -- no additional data being passed through.
    }

type alias AriesCredentialed requestParameters =
    { requestParameters
        | key : String
        , secret : String
    }

type alias AriesConsoleLogRequest =
    { parameters : AriesCredentialed AriesEmptyParameters
    }

port ariesConsoleLogRequests : Signal (Maybe AriesConsoleLogRequest)
port ariesConsoleLogRequests =
    let
        requestOf model =
            case model.currentServer of
                Nothing ->
                    Nothing

                Just server ->
                    Just { parameters =
                        { data = {}
                        , key = server.key
                        , secret = server.secret
                        }
                    }
    in
        model
        |> Signal.sampleOn logTicker
        |> Signal.map requestOf

type alias AriesConsoleLogResponse =
    AriesErrorableResponse
        { log : List String }

type alias AriesErrorableResponse r =
    { r | errorMessage : Maybe String }

port ariesConsoleLogResponses : Signal (Maybe AriesConsoleLogResponse)

ariesConsoleLogResponseActions : Signal (Maybe Action)
ariesConsoleLogResponseActions =
    let
        consoleLogModelOf logResponse =
            { lines = List.map consoleLogLineModelOf logResponse.lines
            , loadingStatus = Updated
            }

        actionOf : AriesConsoleLogResponse
        actionOf logResponse =
            UpdateLog (consoleLogModelOf logResponse)
    in
        Signal.map (Maybe.map actionOf) ariesConsoleLogResponses




-- ======== Wiring: Main ======== --

-- This must be defined in the namespace if we want inspect it elsewhere. (Mostly in API requets.)
model : Signal Action -> Signal Model
model appActions =
    Signal.foldp
        (\ (Just action) model -> update action model)
        initModel
        appActions

main : Signal Html.Html
main =
    let
        userActionsMailbox : Signal.Mailbox (Maybe Action)
        userActionsMailbox =
            Signal.mailbox Nothing

        appActions =
            Signal.mergeMany
                [ userActionsMailbox.signal
                ]
    in
        Signal.map (view userActionsAddress) (model appActions)
