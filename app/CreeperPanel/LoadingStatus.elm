module CreeperPanel.LoadingStatus
    ( WithLoadingStatus
    , LoadingStatus(..)
    , update
    )
    where

type alias WithLoadingStatus r =
    { r
        | loadingStatus : LoadingStatus
    }

type LoadingStatus
    = NotLoaded
    | AwaitingUpdate
    | Updated
    | Errored String

update : LoadingStatus -> WithLoadingStatus r -> WithLoadingStatus r
update status record =
    { record | loadingStatus <- status }
