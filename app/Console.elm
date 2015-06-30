module Console (Model, init, initWithLogLines, Action, update, updateLog, view, Context) where

{-
Console

For now, just holds the current log.  May do fancy things like format said log some time,
or hold more than 500 lines. (while in continuous operation.)

It may do at some point to make a separate ConsoleLog module, and a separate ConsoleCommandLine module.  maybe.

Other things...

I'd like the log lines to be stored in the top-level, so that all may be provided with them.
However, I also want the console to have its own log lines because it might do different things with them,
such as highlight them or something.

I don't necessarily want the other parts of the app showing those highlights.
This may mean a separate ConsoleLogLine is necessary, or else a ConsoleLogLineStyle or something,
but I think the former may be the ticket.

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Signal exposing (Signal, Address)
import String

import LogLine

-- MODEL --

type alias Model =
    -- For now, just splatting the log in.  Get fancy later.
    { logLines : List LogLine.Model
    }

init : Model
init =
    { logLines = []
    }

-- Soooorta a test function for now.
initWithLogLines : List LogLine.Model -> Model
initWithLogLines logLines = Model logLines



-- UPDATE --

type Action
    = NoOp
    | ModifyLine LogLine.ID LogLine.Action

update : Action -> Model -> Model
update action model =
    case action of
        NoOp -> model

        ModifyLine logLineId logLineAction ->
            let
                modifyLine logLineModel =
                    if LogLine.idOf logLineModel == logLineId
                        then LogLine.update logLineAction logLineModel
                        else logLineModel
            in
                { model | logLines <- List.map modifyLine model.logLines }

updateLog : List LogLine.Model -> Model -> Model
updateLog newLog model =
    { model | logLines <- newLog }



-- VIEW --

type alias Context =
    {}

view : Signal.Address Action -> Model -> Html
view address model =
    div [ class "console" ] [ viewLog address model ]

viewLog : Signal.Address Action -> Model -> Html
viewLog address model =
    div [ class "console-log", consoleStyle ] (List.map (viewLogLine address) model.logLines)

viewLogLine : Signal.Address Action -> LogLine.Model -> Html
viewLogLine address logLineModel =
    let
        forwardingAddress = Signal.forwardTo address (ModifyLine (LogLine.idOf logLineModel))
    in
        LogLine.view forwardingAddress logLineModel

-- TODO: Move to CSS.
consoleStyle : Attribute
consoleStyle =
    style
        [ ("font-family", "monospace")
        , ("whitespace", "pre")
        ]
