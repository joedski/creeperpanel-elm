module CreeperPanel.State
    ( Status(..)
    , Model, initModel
    , Action(..), update
    , LogModel
    , LogAction(..), updateLog
    , LogLineModel
    , ServerModel
    )
    where

import CreeperPanel.Aries as Aries

{-
This module defines the models in the app, the actions that can update them,
and the way they each of those updates are effected.

If any parts of the app are heavily componentized, this will also refer to those components' models, updates, and actions,
though of course they will not refer back to this module.
-}

---- General

type Status
    = Initial
    | Loaded
    | Pending
    | Errored String



---- Root

type alias Model =
    { log : LogModel
    , currentServer : Maybe ServerModel
    }

initModel : Model
initModel =
    { log = initLogModel
    , currentServer = Nothing
    }

type Action
    = UpdateLog LogAction

update : Action -> Model -> Model
update action model =
    case action of
        UpdateLog logAction ->
            { model | log <- updateLog logAction model.log }



---- Log

type alias LogModel =
    { lines : List LogLineModel
    , status : Status
    }

initLogModel : LogModel
initLogModel =
    { lines = []
    , status = Initial
    }

type LogAction
    = UpdateLogLines (List String)
    | UpdateLogStatus Status

updateLog : LogAction -> LogModel -> LogModel
updateLog action model =
    case action of
        UpdateLogLines newLogLines ->
            { model
                | lines <- List.map logLineModelOfString newLogLines
                , status <- Loaded
            }

        UpdateLogStatus status ->
            { model | status <- status }

-- This will change later.  Well, maybe.
type alias LogLineModel = String

logLineModelOfString : String -> LogLineModel
logLineModelOfString string =
    string



----- Server

type alias ServerModel =
    { name : String
    , credentials : Aries.Credentials
    }
