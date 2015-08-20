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
    }

addresses : Addresses
addresses =
    { logRequest = Signal.forwardTo logRequest.address Just
    }

type alias Signals =
    { logRequest : Signal.Signal (Maybe ())
    }

signals : Signals
signals =
    { logRequest = AppUtils.onlyJusts logRequest.signal
    }



-- Global action mailboxen.
-- These boxen's signals are all folded into the top-level Actions Signal which ultimately drives updates to the model.

logRequest : Signal.Mailbox (Maybe ())
logRequest =
    Signal.mailbox Nothing
