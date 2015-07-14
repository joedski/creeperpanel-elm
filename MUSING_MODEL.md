Musing - Model
==============

Road Map - Model
----------------

### v x.0

Intent: Basic operation.

- Model:
	- log : ConsoleLogModel
	- serverStats : ServerStatsModel

- ConsoleLog:
	- lines : List ConsoleLogLineModel
	- status : Maybe ConsoleLogStatus

- ServerStatsModel:
	- cpu : Float
	- ram : Float
	- hdd : Float
	- status : Maybe ServerStatsStatus

- ConsoleLogLineModel:
	- text : String

Auxiliary Types:

- ConsoleLogStatus: Union of...
	- Updating
	- Updated
	- Errored String

- ServerStatsStatus: Union of...
	- Updating
	- Updated
	- Errored String

### v x.1

Intent: A little more basic operation.

- Model, additional attributes:
	- players : List PlayerModel

- ConsoleLogLineModel, additional attributes:
	- timestamp : Time?  Date?
	- body : String?
	- level : String?  Union?  Info | Warning | Severe?

- PlayerModel:
	- ...?

### v x.2

Intent: Send commands.

### v x.3

Intent: View pending commands.

- Model, additional attributes:
	- pendingCommands : List PendingCommandSetModel

- PendingCommandSetModel:
	- commands : List PendingCommandModel

- PendingCommandModel:
	- ...?  Need some sort of ID and the command, at least.

### v x.3

Intent: Add command macros.

- Model, additional attributes:
	- macros : List ConsoleMacroModel

- ConsoleMacroModel:
	- commands : List ConsoleCommandModel
	- sync : Bool
		- True if we want each command guaranteed to come after the last.
		- False if we don't care what the actual order of execution is.
