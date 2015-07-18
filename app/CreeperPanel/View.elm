module CreeperPanel.View
    ( view
    )
    where

import CreeperPanel.Model as Model
import CreeperPanel.Actions as Actions
import Html
import Html.Attributes as Attrs
import Html.Events as Events

view : Signal.Address Actions.Action -> Model.Model -> Html.Html
view address model =
    Html.div [ Attrs.class "app" ]
        [ viewConsole address model
        ]

viewConsole : Signal.Address Actions.Action -> Model.Model -> Html.Html
viewConsole address model =
    Html.div [ Attrs.class "console" ]
        [ viewConsoleLog address model.log
        ]

viewConsoleLog : Signal.Address Actions.Action -> Model.LogModel -> Html.Html
viewConsoleLog address model =
    let
        logLines =
            if model.lines == [] then
                [ Html.text "(No log to show.)" ]
            else
                List.map (viewConsoleLogLine address) model.lines
    in
        Html.div [ Attrs.class "console-log" ] logLines

viewConsoleLogLine : Signal.Address Actions.Action -> Model.LogLineModel -> Html.Html
viewConsoleLogLine address model =
    Html.div [ Attrs.class "console-log-line" ] [ Html.text model.text ]
