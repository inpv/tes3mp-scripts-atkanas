# GeneralGUI
This is just some generalised way of using tes3mp's GUI stuff that I'll most likely use for my scripts from now on. It doesn't make using them any easier (in fact, it makes more work), however it offers a basic structure to use. I'd initially intended to simply insert this into every script I needed to use it in rather than making it into a fully-fledge module in order to cut down on installation steps, but either way requires at least some installation, so I relented :P (Though I may still use it the former way, anyways)

## Installation
### General
- Save the file as `GeneralGUI.lua` in `mp-stuff/scripts`
### In `serverCore.lua`
- Find the line `menuHelper = require("menuHelper")`. Add the following *beneath* it: ```GeneralGUI = require(GeneralGUI)```
- Find the line `if eventHandler.OnGUIAction(pid, idGui, data) then return end`. Add the following *beneath* it: ```if GeneralGUI.OnGUIAction(pid, idGui, data) then return end```

## Usage
### Register a New GUI
In order to register a new GUI, use `GeneralGUI.RegisterGUI(id, data)`. `id` should be the identifier you intend to use for your GUI. `data` should be a table containing the info about your GUI, as formatted as described in GUI Data.

### Chains
As a basic method of storing some temporary data that can be shared between multiple GUIs that are opened in a sequence (e.g. pressing a button on one GUI leads to another being opened), GeneralGUI utilises something called a "chain". A chain is first created *before* the first GUI in a sequence is shown, using `GeneralGUI.StartChain(pid)`. This creates a table of data that is fed to and shared between every GUI in the sequence for sharing data, which lasts until the chain is ended, or a new one is created. Even if the new "sequence" you intend to open is just 1-window long, you still need to create a new chain before showing it.  
There are a small handful of things that are automatically stored into a chain's data, with the rest being added by your GUI's functions:
- `pid` - The pid of the player for whom the GUI is being shown. This is set when `GeneralGUI.StartChain(pid)` is used, and is how you get the player you want your GUI to target.
- `currentGeneralGuiId` - The ID of the registered GUI that was most recently opened for the player (note that most recently opened could, and generally does, mean the GUI that they currently see). This is set when `GeneralGUI.ShowGUI(pid, id)` is called. It's used internally to reshow the current GUI by `GeneralGUI.ReshowLast`.
- `currentChoiceList` - The choice list (see: *Choice Data*) from the most recently presented choice by a `CustomMessageBox` or `ListBox`.

If you want your GUIs to store data that lasts beyond the instance of a GUI sequence, you need to store that information elsewhere in your script.

It's good practice to end a chain when the sequence is over (i.e. when no more GUIs are going to be shown) by using the function `GeneralGUI.EndChain(pid)`. This isn't absolutely necessary, and not doing so will only technically become a problem if another sequence is started without first starting a new chain.

Currently, only one chain is supported at a time, with chain data for newly opened GUIs overwriting what's currently stored/deleting previous information when told to end. This could change in the future if I want to add a little bit more complexity, but at the moment I feel like just the one is sufficient for most needs.

The first argument sent to every one of the GUI's functions is the chain data table for the player's current chain.

### Choice Data
Both `CustomMessageBox` and `ListBox` GUIs make use of choice data. For `CustomMessageBox`, choices represent the buttons that the player has available. For `ListBox`, choices represent each line on the list.

There are two pieces of terminology I'm going to use in relation to choices: *choice lists* and *choices/choice data*. A *choice list* is simply an indexed table containing each *choice data* entry, generated by the GUI's `GenerateChoices` function.

By default, choice data entries contain a few values that are required for GeneralGUI. Additional data can be added during `GenerateChoices` if your script requires more information.
- `index` - The index that the choice appears at in the choice list. To be honest this is pretty pointless and I might just end up removing it as a default requirement.
- `display` - This is a string that will be used when displaying the option to a player. For `CustomMessageBox`es, this is what text will be displayed on the button. For `ListBox`es, this is what the entry says on the list.
- `id` - A string used to later filter the choice during `OnSelectOption`.
- `callback` - This is a function that will be run when the choice is selected. This is entirely optional. If the selected choice doesn't have a callback, `OnSelectOption` is run instead.

For an example, we're going to assume we're making a `ListBox` that displays every player and actor in a given cell. Inside our `GenerateChoices` function, we'll compile information on all the players and actors in the cell. When making a choice for a player, we'll make `display` be the player's name, the `id` be "player", and add in a custom entry `pid`, which'll be the player's pid. When making a choice for an actor, we'll make `display` be the actor's name, the `id` be "actor", and add in a custom entry `uniqueIndex`, which'll be the actor's uniqueIndex.  
Inside our `OnSelectOption` function, we can read the choice data that's provided as the second argument to determine information on the player's selection. If the player chose a player from the list, the `id` will be "player", and we can do whatever logic we want, also utilising the stored `pid`. If the player chose an actor instead, the `id` will be "actor", and we can do something different, utilising the stored `uniqueIndex`.

## Script Functions
There are a number of script functions available to use. Read through the file to see them all. Here is a list of the most important ones:
- `RegisterGUI(id, data)` - Use this to register a new GUI for use with GeneralGUI. `id` should be a unique identifier for that GUI, `data` should be a table containing the GUI Data as outlined in the GUI Data section. Obviously use this to register a GUI before it's shown with `ShowGUI`.
- `StartChain(pid)` - Begin a new chain for the player (`pid`). Use *before* `ShowGUI` when beginning a new sequence. See *Chains* section for more information.
- `EndChain(pid)` - End the current chain for the player (`pid`). See *Chains* section for more information.
- `ShowGUI(pid, id)` - Show a registered GUI to the player. `pid` should be the player ID of the player to target. `id` should be the ID of the GUI that was provided when it was registered via `RegisterGUI`.

## GUI Data
A GeneralGUI GUI is defined by a table of information that's passed to it during `RegisterGUI`. There are three types of GUI for use in GeneralGUI: `CustomMessageBox`, `InputDialog`, and `ListBox`. The following is a list of every variable that makes up a GUI's data for each type of GUI:
### InputDialog
- `type` - `string` (required) - Should be `"InputDialog"`
- `isPassword` - `true`/`false` (optional) - If `true` the dialog will use the censored display like a password entry prompt
- `OnInput` - `function` (required) - After all validation has been passed, this function is run. The first argument is the chain data, the second is the `input`.
#### Label
- `GenerateLabel` - `function` (optional) - If present, the function will be run to determine what text to display as the dialog's label (the text above the input box). The first argument given is the chain data. Whatever is returned is used as the label.
- `label` - `string` (optional) - If `GenerateLabel` isn't present, this string will be used for the dialog's label.

*If both are absent, will default to a blank label.*
#### Note
- `GenerateNote` - `function` (optional) - If present, the function will be run to determine what text to display as the dialog's note (the text below the input box). The first argument given is the chain data. Whatever is returned is used as the label.
- `label` - `string` (optional) - If `GenerateNote` isn't present, this string will be used for the dialog's note.

*If both are absent, will default to a blank note.*
#### Validation
- `ValidateInput` - `function` (optional) - If present, the function will be run to determine if the provided input is valid. If the input is determined to be invalid, the player will be prompted to enter again. The first argument given is the chain data, the second argument is the string that the player input. The input will be accepted if the function returns `true`, and rejected if it returns `false`. If the function returns a second value when rejecting, that value will be used for the rejection message, otherwise a default message will be used instead.

### MessageBox
- `type` - `string` (required) - Should be `"CustomMessageBox"`
#### Label
- `GenerateLabel` - `function` (optional) - If present, the function will be run to determine what text to display as the message's label (the main body of text). The first argument given is the chain data. Whatever is returned is used as the label.
- `label` - `string` (optional) - If `GenerateLabel` isn't present, this string will be used for the message's label.

*If both are absent, will default to a blank label.*
#### Buttons
- `GenerateChoices` - `function` (optional) - If present, the function will be run to create the GUI's choice list. The first argument given is the chain data. Whatever is returned is used as the choice list (See Choice Data).

*If absent, the script will generate a choice list with a single entry: `{index = 1, display = "Close", id = "close", callback = GeneralGUI.CloseButton}`*
- `OnSelectOption` - `function` (required if a choice lacks callback) - If a button is selected that lacks a callback function in its data, this function is run instead. The first argument is the chain data, the second is the choice's data.

### ListBox
- `type` - `string` (required) - Should be `"ListBox"`
- `requireSelection` - `true`/`false` (optional) - If `true` the GUI won't allow the player to continue without selecting an option from the list.
- `requireSelectionRejectMessage` - `string` (optional) - The message that's displayed if they don't make a selection while `requireSelection` is `true`. If not provided, a default message will be used instead.
#### Label
- `GenerateLabel` - `function` (optional) - If present, the function will be run to determine what text to display as the message's label (the text above the list). The first argument given is the chain data. Whatever is returned is used as the label.
- `label` - `string` (optional) - If `GenerateLabel` isn't present, this string will be used for the message's label.

*If both are absent, will default to a blank label.*
#### Choices
- `GenerateChoices` - `function` (optional) - If present, the function will be run to create the GUI's choice list. The first argument given is the chain data. Whatever is returned is used as the choice list (See Choice Data).
- `OnSelectOption` - `function` (required if a choice lacks callback) - If a choice is selected that lacks a callback function in its data, this function is run instead. The first argument is the chain data, the second is the choice's data.

## Notes
Most of what is here is entirely subject to change. See the example file (`generalGuiExample.lua`) for a passable example of the resource in action :P
