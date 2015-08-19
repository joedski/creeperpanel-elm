module CreeperPanel.View
    ( view
    )
    where

import CreeperPanel.State as State

import Html

view : Signal.Address State.Action -> State.Model -> Html.Html
view address model =
    Html.div [] [ Html.text "Hi." ]
