-- kanaMOTD - Release 1 - For tes3mp 0.7-prerelease
-- Adds a MOTD message.

-- modified by inpv for 0.7.0-alpha
-- currently pulls out lore entries from a list made of several not-so-obscure vanilla Morrowind lore books

--[[
BOOKS USED (in order):
Tamrielic Lore
The Alchemists Formulary
The Firmament
Special Flora of Tamriel
Tal Marog Ker's Researches
The Legendary Scourge
On Artaeum
Mysticism: The Unfathomable Voyage
The Anticipations
The Book of Daedra
The House of Troubles
Spirit of Nirn, God of Mortals
Varieties of Faith in the Empire
Mysterious Akavir
Provinces of Tamriel
Children of the Sky
The True Nature of Orcs
Great Houses of Morrowind
]]

--[[ INSTALLATION:
a) Save this file as "kanaMOTD.lua" in server/scripts/custom
b) Save the json files as "MOTDMainMessage.json" and "MOTDTitle.json" in server/data/custom
c) Add a line "kanaMOTD = require("custom.kanaMOTD")" in server/scripts/customScripts.lua
]]

local scriptConfig = {}

scriptConfig.loadFromFile = true -- If true, the script will load and use the contents of kanaMOTD.json for the message and titles
scriptConfig.showInChat = false -- If true, the message will be printed into the player's chat
scriptConfig.showMessageBox = true -- If true, the player will be shown a message box upon joining that displays the MOTD

-- The following are the string that'll be used if loadFromFile is set to false
scriptConfig.mainMessage = "This is a [#yellow]MOTD[#default] message"
scriptConfig.motdWindowTitle = "=== MOTD ==="

---------------------------------------------------------------------------------------
jsonInterface = require("jsonInterface")
require("color")
---------------------------------------------------------------------------------------
local Methods = {}

local MOTDmessage
local MOTDtitle

local lowerColors = {}

local random_num_init

-- Used to replace specialised color dealies with the actual color code
Methods.ProcessText = function(text)
	local function replacer(wildcard)
		local lc = string.lower(wildcard)
		if lowerColors[lc] then
			-- Was a valid color code
			return lowerColors[lc]
		else
			-- Just happened to be a string that matched the color code signifier we're using
			return ("[##" .. wildcard .. "]")
		end
	end
	
	return text:gsub("%[#(%w+)%]", replacer)	
end

Methods.Load = function()
	local loadedMainData = jsonInterface.load("custom/MOTDMainMessage.json")
  	local loadedTitleData = jsonInterface.load("custom/MOTDTitle.json")
  
  	math.randomseed(os.time())

	if random_num_init == nil then
		for i=1,100 do -- heating up the Wabbajack
			main_random_num = math.random(1,#loadedMainData)
			title_random_num = math.random(1,#loadedTitleData)
		end
	end
	
	MOTDmessage = loadedMainData[main_random_num].mainMessage
	MOTDtitle = loadedTitleData[title_random_num].title
end

Methods.ShowMOTD = function(pid)
	-- If configured to load from file, refresh the message in case the file has been changed
	if scriptConfig.loadFromFile then
		Methods.Load()
	end
	
	local processedMessage = Methods.ProcessText(MOTDmessage)
	local processedTitle = Methods.ProcessText(MOTDtitle)
	
	if scriptConfig.showInChat then
		tes3mp.SendMessage(pid, color.Warning .. "MOTD: " .. color.Default .. processedMessage .. color.Default .. "\n")
	end
	
	if scriptConfig.showMessageBox then
		local boxMessage = ""
		-- Only add the title in if it isn't blank
		if processedTitle ~= "" then
			boxMessage = boxMessage .. processedTitle .. color.Default .. "\n"
		end
		-- Add the main message
		boxMessage = boxMessage .. processedMessage
		
		tes3mp.CustomMessageBox(pid, -1, boxMessage, "Ok")
	end
end

Methods.Init = function()
	-- Load in the data for the messages
	-- That either means loading from the json, or porting in the messages from the config
	if scriptConfig.loadFromFile then
		Methods.Load()
	else
		MOTDmessage = scriptConfig.mainMessage
		MOTDtitle = scriptConfig.motdWindowTitle
	end
	
	-- Setup lowercase key colors
	for key, colorCode in pairs(color) do
		lowerColors[string.lower(key)] = colorCode
	end
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
        if eventStatus.validCustomHandlers then
                Methods.Init()
                tes3mp.LogMessage(enumerations.log.INFO, "[kanaMOTD] Init")
        end
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
        if eventStatus.validCustomHandlers then
                Methods.ShowMOTD(pid)
                tes3mp.LogMessage(enumerations.log.INFO, "[kanaMOTD] MOTD shown for " .. Players[pid].name)
        end
end)

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
        if eventStatus.validCustomHandlers then
                Methods.ShowMOTD(pid)
                tes3mp.LogMessage(enumerations.log.INFO, "[kanaMOTD] MOTD shown for " .. Players[pid].name)
        end
end)


---------------------------------------------------------------------------------------
return Methods

