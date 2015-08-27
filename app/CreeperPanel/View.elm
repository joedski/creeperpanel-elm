module CreeperPanel.View
    ( view
    )
    where

import CreeperPanel.State as State
import CreeperPanel.GlobalActions as GlobalActions

import Html
import Html.Attributes as Attrs
import Html.Events as Events
import Flex



-------- Main --------

view : Signal.Address State.Action -> State.Model -> Html.Html
view address model =
    let
        viewStyles = 
            [ ("width", "100vw")
            , ("height", "100vh")
            ]
            ++ Flex.display
            ++ (Flex.direction Flex.Vertical)
            ++ (Flex.justifyContent Flex.Stretch)
    in
        Html.div
            [ Attrs.class "panel-app"
            , Attrs.style viewStyles
            ]
            [ viewServerControls address model
            , viewConsole address model
            ]



-------- Console --------

viewConsole : Signal.Address State.Action -> State.Model -> Html.Html
viewConsole address model =
    let
        consoleStyles =
            Flex.display
            ++ (Flex.direction Flex.Vertical)
            ++ (Flex.justifyContent Flex.Stretch)
            ++ (Flex.grow 1)
    in
        Html.div
            [ Attrs.class "console"
            , Attrs.style consoleStyles
            ]
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
    let
        consoleLogStyles =
            [ ("overflow", "auto")
            ]
            ++ (Flex.grow 1)
    in
        Html.div
            [ Attrs.class "console-log"
            , Attrs.style consoleLogStyles
            ]
            (List.map (viewConsoleLogLine address) (model.log |> .lines))

viewConsoleLogLine : Signal.Address State.Action -> State.LogLineModel -> Html.Html
viewConsoleLogLine address model =
    Html.div [ Attrs.class "console-log-line" ]
        [ Html.text model ]

-- TODO: Command Line...



-------- Server Buttons + Stats --------

viewServerControls : Signal.Address State.Action -> State.Model -> Html.Html
viewServerControls address model =
    let
        styles =
            Flex.display
            ++ (Flex.justifyContent Flex.Stretch)
    in
        Html.div
            [ Attrs.class "server-controls"
            , Attrs.style styles
            ]
            [ viewServerControlsButtons address model
            , viewServerControlsStats address model
            ]

viewServerControlsButtons : Signal.Address State.Action -> State.Model -> Html.Html
viewServerControlsButtons address model =
    let
        styles =
            Flex.display
            ++ (Flex.justifyContent Flex.Stretch)
            -- No flex-item styles here because the buttons don't resize.  I think.

        buttonStyles =
            [ ("margin", "2px")
            ]
            ++ (Flex.grow 1)
            ++ (Flex.shrink 1)

        button (address, value) colorClass label =
            Html.div
                [ Attrs.class ("btn btn-block btn-" ++ colorClass)
                , Events.onClick address value
                , Attrs.style buttonStyles
                ]
                [ Html.text label
                ]
    in
        Html.div
            [ Attrs.class "server-controls-buttons"
            , Attrs.style styles
            ]
            [ button (GlobalActions.addresses |> .serverStopRequest, ()) "danger" "Stop"
            , button (GlobalActions.addresses |> .serverRestartRequest, ()) "warning" "Restart"
            , button (GlobalActions.addresses |> .serverStartRequest, ()) "success" "Start"
            ]

viewServerControlsStats : Signal.Address State.Action -> State.Model -> Html.Html
viewServerControlsStats address model =
    let
        styles =
            Flex.display
            ++ (Flex.justifyContent Flex.Stretch)
            ++ (Flex.grow 1)
            ++ (Flex.shrink 1)
    in
        Html.div
            [ Attrs.class "server-controls-stats"
            , Attrs.style styles
            ]
            [ Html.text "Stats..."
            ]
