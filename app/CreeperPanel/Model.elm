module CreeperPanel.Model
    ( Model
    , ServerModel
    , LogModel
    , LogLineModel
    , initModel
    , initLogModel
    , logModelOf
    )
    where

import CreeperPanel.LoadingStatus as LoadingStatus

type alias Model =
    { currentServer : Maybe ServerModel
    , log : LogModel
    --, serverStats : ServerStatsModel
    }

type alias ServerModel =
    { name : String
    , key : String
    , secret : String
    }

type alias LogModel =
    LoadingStatus.WithLoadingStatus
        { lines : List LogLineModel
        }

type alias LogLineModel =
    { text : String
    }

--type alias ServerStatsModel =
--    {}



initModel : Model
initModel =
    { currentServer = Nothing
    , log = initLogModel
    --, serverStats = initServerStatsModel
    }

initLogModel : LogModel
initLogModel =
    { loadingStatus = LoadingStatus.NotLoaded
    , lines = []
    }

logModelOf : List String -> LogModel
logModelOf rawLogLines =
    { initLogModel
        | lines <- List.map logLineModelOf rawLogLines
    }
    |> LoadingStatus.update LoadingStatus.Updated

logLineModelOf : String -> LogLineModel
logLineModelOf rawLogLine =
    { text = rawLogLine
    }
