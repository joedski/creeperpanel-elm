module AppUtils
    ( boolOfMaybe
    , onlyJusts
    , noUpdateOrJustAction
    )
    where

boolOfMaybe : Maybe a -> Bool
boolOfMaybe maybeSomething =
    case maybeSomething of
        Just something -> True

        Nothing -> False

onlyJusts : Signal (Maybe a) -> Signal (Maybe a)
onlyJusts =
    Signal.filter boolOfMaybe Nothing

noUpdateOrJustAction : (a -> m -> m) -> (Maybe a) -> m -> m
noUpdateOrJustAction update maybeAction model =
    case maybeAction of
        Nothing ->
            model

        Just action ->
            update action model
