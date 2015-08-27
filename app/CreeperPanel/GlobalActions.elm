module CreeperPanel.GlobalActions
    ( Addresses
    , addresses
    , Signals
    , signals
    )
    where

import AppUtils

{-
This module exposes the signals and addresses of mailboxes for actions which
always affect the whole app model, no matter where messages are sent from.

It does not handle inflow ports, those rather are handled in CreeperPanel.Ports.

These signals do not necessarily lead directly to updates on the App model, but
may instead start API requests whose eventual results lead to updates, or similar situations.
-}

-- Records which break out the addresses and signals.

type alias Addresses =
    { logRequest : Signal.Address ()
    , serverStopRequest : Signal.Address ()
    , serverRestartRequest : Signal.Address ()
    , serverStartRequest : Signal.Address ()
    }

addresses : Addresses
addresses =
    { logRequest = Signal.forwardTo logRequest.address Just
    , serverStopRequest = Signal.forwardTo serverStopRequest.address Just
    , serverRestartRequest = Signal.forwardTo serverRestartRequest.address Just
    , serverStartRequest = Signal.forwardTo serverStartRequest.address Just
    }

type alias Signals =
    { logRequest : Signal.Signal (Maybe ())
    , serverStopRequest : Signal.Signal (Maybe ())
    , serverRestartRequest : Signal.Signal (Maybe ())
    , serverStartRequest : Signal.Signal (Maybe ())
    }

signals : Signals
signals =
    { logRequest = AppUtils.onlyJusts logRequest.signal
    , serverStopRequest = AppUtils.onlyJusts serverStopRequest.signal
    , serverRestartRequest = AppUtils.onlyJusts serverRestartRequest.signal
    , serverStartRequest = AppUtils.onlyJusts serverStartRequest.signal
    }



-- Global action mailboxen.
-- These boxen's signals are all folded into the top-level Actions Signal which ultimately drives updates to the model.

logRequest : Signal.Mailbox (Maybe ())
logRequest =
    Signal.mailbox Nothing

serverStopRequest : Signal.Mailbox (Maybe ())
serverStopRequest =
    Signal.mailbox Nothing

serverRestartRequest : Signal.Mailbox (Maybe ())
serverRestartRequest =
    Signal.mailbox Nothing

serverStartRequest : Signal.Mailbox (Maybe ())
serverStartRequest =
    Signal.mailbox Nothing
