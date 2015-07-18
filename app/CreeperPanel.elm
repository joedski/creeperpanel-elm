module CreeperPanel where

import CreeperPanel.Aries as Aries
import CreeperPanel.Model as Model
import CreeperPanel.Actions as Actions
import CreeperPanel.View as View
import CreeperPanel.Ports as Ports
import Json.Decode as Decode
import Html

-- Ports

-- TODO: Get this through some method other than initial loading via JS...
port initServer : Model.ServerModel

credentials : Signal (Maybe Aries.Credentials)
credentials =
    Signal.map (Maybe.map Ports.credentialsOfServer) currentServerModel

port logRequests : Signal (Maybe Aries.Request)
port logRequests =
    Ports.logRequests credentials

port logResponses : Signal Decode.Value

-- Actions

logResponseReactions : Signal (Maybe Actions.Action)
logResponseReactions =
    Ports.logResponseReactions logResponses

userActions : Signal.Mailbox (Maybe Actions.Action)
userActions =
    Signal.mailbox Nothing

appActions : Signal (Maybe Actions.Action)
appActions =
    Signal.mergeMany
        [ userActions.signal
        , logResponseReactions
        ]

-- Model

model : Signal Model.Model
model =
    let
        initModelWithoutServer = Model.initModel

        initModel =
            { initModelWithoutServer | currentServer <- Just initServer }
    in 
        Signal.foldp
            (\ (Just action) model -> Actions.update action model)
            initModel
            appActions

currentServerModel : Signal (Maybe Model.ServerModel)
currentServerModel =
    Signal.map (\ model -> model.currentServer) model

-- Main

main : Signal Html.Html
main =
    let
        userActionsAddress = Signal.forwardTo userActions.address Just
    in
        Signal.map (View.view userActionsAddress) model
