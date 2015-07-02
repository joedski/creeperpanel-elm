module CreeperPanel where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Json.Decode as Json
import Signal exposing (Signal, Address)
import String
import StartApp
import Window

import Console
import LogLine

-- ENTRY POINT --

main = StartApp.start
    { model = init
    , view = view
    , update = update
    }



-- MODEL --

type alias Model =
    -- We want to be able to do things with them later, so we need to have them exposed at the top level.
    { logLines : List LogLine.Model
    , console : Console.Model
    }

init : Model
init =
    let logLines = LogLine.listFromRaw "Here's a log line.\nHere's a second line.\nYay a third!\n"
    in
        { logLines = logLines
        , console = Console.initWithLogLines logLines
        }



-- UPDATE --

type Action
    -- Replaces the current log.
    = UpdateConsoleLog (List LogLine.Model)
    | ModifyConsole Console.Action

update : Action -> Model -> Model
update action model =
    case action of
        UpdateConsoleLog newLogLines ->
            { model
            | logLines <- newLogLines
            , console <- Console.updateLog newLogLines model.console
            }

        ModifyConsole consoleAction ->
            { model | console <- Console.update consoleAction model.console }



-- VIEW --

view : Signal.Address Action -> Model -> Html
view address model =
    div [ class "creeperpanel" ]
        [ consoleView address model ]

consoleView : Signal.Address Action -> Model -> Html
consoleView address model =
    Console.view (Signal.forwardTo address (ModifyConsole)) model.console



-- CH-API --

-- ports...
