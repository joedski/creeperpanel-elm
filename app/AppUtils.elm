module AppUtils
    ( boolOfMaybe
    , onlyJusts
    , noUpdateOrJustAction
    , maybeApply
    , mapMaybeSignal
    , andMapMaybeSignal
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

-- I'm not yet sure where this is useful outside of andMapMaybeSignal.
maybeApply : Maybe (a -> b) -> Maybe a -> Maybe b
maybeApply maybeFun maybeValue =
    case maybeFun of
        Nothing -> Nothing
        Just fun -> Maybe.map fun maybeValue

mapMaybeSignal : (a -> b) -> Signal (Maybe a) -> Signal (Maybe b)
mapMaybeSignal f maybeSignal =
    Signal.map (Maybe.map f) maybeSignal

-- derived from andMap/(~)
andMapMaybeSignal : Signal (Maybe (b -> c)) -> Signal (Maybe b) -> Signal (Maybe c)
andMapMaybeSignal maybeFunSignal maybeOtherSignal =
    -- Just notFunSignal :(
    Signal.map2 maybeApply maybeFunSignal maybeOtherSignal
