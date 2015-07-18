module CreeperPanel.Actions
    ( Action(..)
    , update
    )
    where

import CreeperPanel.Model as Model
import CreeperPanel.LoadingStatus as LoadingStatus

type Action
    = AnticipateLogUpdate
    | UpdateLog Model.LogModel

update : Action -> Model.Model -> Model.Model
update action model =
    case action of
        AnticipateLogUpdate ->
            { model
                | log <- LoadingStatus.update LoadingStatus.AwaitingUpdate model.log
            }

        UpdateLog newLog ->
            { model
                | log <- newLog
            }
