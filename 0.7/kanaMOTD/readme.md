# kanaMOTD
Displays a MOTD message (random vanilla lore information from several books) to every player who joins the server, whether on a new or existing character.<br>
Doesn't require server restart to generate a new message.<br>
For a list of the books included check `kanaMOTD.lua`.

*Currently written for a version of 0.7.0-alpha*<br>
Ported to 0.7.0-alpha and modified by inpv

## Installation:
a) Save `kanaMOTD.lua` in `server/scripts/custom`.<br>
b) Save the json files `MOTDMainMessage.json` and `MOTDTitle.json` in `server/data/custom`.<br>
c) Add a line `kanaMOTD = require("custom.kanaMOTD")` in `server/scripts/customScripts.lua`.<br>

## Configuration
Configuration can be done from within the file itself. Here is a list of all the current config options:
- **scriptConfig.loadFromFile** - If true, the script will load and use the contents of `kanaMOTD.json` for the message and titles. Use this if you plan on being able to change the server's MOTD without having to take it offline.
- **scriptConfig.showInChat** - If true, the MOTD message will be printed into the player's chat.
- **scriptConfig.showMessageBox** - If true, the MOTD will appear in a message box.
If `loadFromFile` is set to false, then the following are the strings that will be used for the MOTD:
- **scriptConfig.mainMessage** - The MOTD message
- **scriptConfig.motdWindowTitle** - The title that will appear before the MOTD in message boxes (only relevant if `showMessageBox` is `true`)

## Usage
The script itself works automatically, displaying the MOTD to all players who join. Depending on your configuration, there are different variables that you have to edit for your MOTD:
- If `loadFromFile` is enabled, you need to edit `mainMessage` and `title` inside `kanaMOTD.json`
- Otherwise, you need to edit `scriptConfig.mainMessage` and `scriptConfig.motdWindowTitle` inside `kanaMOTD.lua`
### Formatting
- The script includes its own method of coloring text. Use the color name as it appears in `color.lua` inside square brackets with a hash before it e.g. `[#red]`, to change the text's color. Alternatively you can just do the normal method of coloring and use the color codes themselves...
- Newlines can be made with `\n`.
- If you leave the title as a blank string (e.g. `""`), then the script won't try to use it in the message box.
- Depending on the format you're editing, you may have to escape certain characters for what you've entered to work properly, though I'll leave that for you to discover yourselves ;P

## Installation (deprecated)
### General
- Save `kanaMOTD.lua` into your `mp-stuff/scripts` folder
- Save `kanaMOTD.json` into your `mp-stuff/data` folder
### Edits to `serverCore.lua`
- Find the line `menuHelper = require("menuHelper")`. Add the following *beneath* it: ```kanaMOTD = require("kanaMOTD")```
- Find the line `function OnServerPostInit()`. Add the following *beneath* it: ``` kanaMOTD.Init()```
### Edits to `eventHandler.lua`
- Find the line `Players[pid]:EndCharGen()`. Add the following *beneath* it:  ```kanaMOTD.ShowMOTD(pid)```
- Find the line `Players[pid]:Message("You have successfully logged in.\n" .. config.chatWindowInstructions)`. Add the following *beneath* it: ```kanaMOTD.ShowMOTD(pid)```
