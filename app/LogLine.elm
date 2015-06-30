module LogLine (Model, ID, listFromRaw, idOf, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Signal exposing (Signal, Address)
import String



-- Model

type alias Model =
    { tid : ID
    , text : String
    }

type alias ID = Int

listFromRaw : String -> List Model
listFromRaw rawLog =
    let rawLines =
            String.lines rawLog
            |> List.map String.trim
            |> List.filter (not << String.isEmpty)
    in
        List.indexedMap (\tid -> \text -> Model tid text) rawLines

idOf : Model -> ID
idOf model = model.tid



-- Actions/Update

{-
Examples of possible actions may include highlighting, ... and something.
-}

type Action
    = NoOp

update : Action -> Model -> Model
update action model =
    case action of
        NoOp -> model



-- View

view : Signal.Address Action -> Model -> Html
view address model =
    p [ (class "log-line") ] [ text model.text ]
