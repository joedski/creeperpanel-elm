module CreeperPanel.Ports
    ( logRequests
    , credentialsOfServer
    , logResponseReactions
    )
    where

import Json.Decode as Decode exposing ((:=))
import Time
import CreeperPanel.Aries as Aries
import CreeperPanel.Model as Model
import CreeperPanel.Actions as Actions
import AppUtils

import Debug

-- Action signals from responses need to be type Signal (Maybe Action),
-- but response signals must be Signal SomeResponse



----- Utility Functions -----



----- Internal Details -----

logTicker : Signal Time.Time
logTicker =
    Time.every (Time.second * 15)



----- Public Functions -----

