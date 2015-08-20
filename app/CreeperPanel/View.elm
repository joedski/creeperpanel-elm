module CreeperPanel.View
    ( view
    )
    where

import CreeperPanel.State as State

import Html
import Html.Attributes as Attrs

view : Signal.Address State.Action -> State.Model -> Html.Html
view address model =
    Html.div [ Attrs.class "panel-app" ] [ viewConsole address model ]

viewConsole : Signal.Address State.Action -> State.Model -> Html.Html
viewConsole address model =
    Html.div [ Attrs.class "console" ]
        [ viewConsoleLogStatus address model
        , viewConsoleLog address model
        ]

viewConsoleLogStatus : Signal.Address State.Action -> State.Model -> Html.Html
viewConsoleLogStatus address model =
    let
        statusString =
            case model.currentServer of
                Nothing -> "(No server selected)"

                Just _ ->
                    case (model.log |> .status) of
                        State.Initial -> "Not yet requested."

                        State.Loaded -> "Up to date."

                        State.Pending -> "Awaiting update..."

                        State.Errored message -> "Error: " ++ message
    in
        Html.div [ Attrs.class "console-log-status" ]
            [ Html.text statusString ]

viewConsoleLog : Signal.Address State.Action -> State.Model -> Html.Html
viewConsoleLog address model =
    Html.div [ Attrs.class "console-log" ]
        (List.map (viewConsoleLogLine address) (model.log |> .lines))

viewConsoleLogLine : Signal.Address State.Action -> State.LogLineModel -> Html.Html
viewConsoleLogLine address model =
    Html.div [ Attrs.class "console-log-line" ]
        [ Html.text model ]
