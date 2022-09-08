-- ===============================================
-- Features included:
-- Zone and source discovery
-- Two-way communication of: processor state, volume, zone power and source selection
-- 12v trigger control
-- ===============================================

function EDRV_Init() --Init including a "power on" command for process incoming to get us brand/model/FW info. Not super necessary, but nice
	ELAN_DisconnectTCP()
	ELAN_ConnectTCP()
	local sCmd = "ssp.power.on"
	ELAN_SendHTTP(sCmd)
	proc = 1 --Not sure what this does. Could be part of earlier experimentation. Too scared to delete this at this point.
	source_num = 0 --Global variable to track number of sources for discovery
	zone_num = 0 --Global variable to track number of zones for discovery
	preset_num = 0 --Global variable to tracker number of preset for discovery
	source_list = {} --Global table which will hold all source names for discovery
	zone_list = {} --Global table which will hold all zone names for discovery
	preset_list = {} --Globa table which will hold all preset names
	preset_id_list = {} --Globa table which will hold all preset names
	volstop = 0 --Not relevant, used only if we want RELATIVE volume setting
	
	ip = ELAN_GetIPString()
	port = ELAN_GetIPPort()

	connection = ELAN_CreateTCPClientSocket(ip,port)
	
	ELAN_ConnectTCPSocket(connection)

	ELAN_Trace('\n  ')
	ELAN_Trace([[                          _._       _,._]])
	ELAN_Trace([[                        _."   `. " ."   _`.')
	ELAN_Trace([[                ,"""/`""-.-.,/. ` V"\-,`.,--/"""."-..]])
	ELAN_Trace([[              ,"    `...," . ,\-----._|     `.   /   \]])
	ELAN_Trace([[            `.            .`  -"`"" .._   :> `-"   `.]])
	ELAN_Trace([[           ,"  ,-.  _,.-"| `..___ ,"   |"-..__   .._ L]])
	ELAN_Trace([[          .    \_ -"   `-"     ..      `.-" `.`-."_ .|]])
	ELAN_Trace([[          |   ,",-,--..  ,--../  `.  .-.    , `-.  ``.]])
	ELAN_Trace([[          `.," ,  |   |  `.  /"/,,.\/  |    \|   |]])
	ELAN_Trace([[               `  `---"    `j   .   \  .     "   j]])
	ELAN_Trace([[             ,__`"        ,"|`"\_/`."\"        |\-"-, _,.]])
	ELAN_Trace([[      .--...`-. `-`. /    "- ..      _,    /\ ," .--""  ,"".]])
	ELAN_Trace([[    _"-""-    --  _`"-.../ __ "."`-^,_`-""""---....__  " _,-`]])
	ELAN_Trace([[  _.----`  _..--."        |  "`-..-" __|"""         .""-. """--.._]])
	ELAN_Trace([[ /        "    /     ,  _.+-."  ||._"   """". .          `     .__\]])
	ELAN_Trace([[ `---    /        /  / j"       _/|..`  -. `-`\ \   \  \   `.  \ `-..]])
	ELAN_Trace([[," _.-" /    /` ./  /`_|_,-"   ","|       `. | -"`._,   L  \ .  `.   |]])
	ELAN_Trace([[`"" /  /  / ,__...-----| _.,  ,"            `|----.._`-.|" |. .` ..  .]])
	ELAN_Trace([[  /  "| /.,/   \--.._ `-," ,          .  "`."  __,., "  ""``._ \ \`,"]])
	ELAN_Trace([[ /_,"---  ,     \`._,-` \ //  / . \    `._,  -`,  / / _   |   `-L -]])
	ELAN_Trace([[  /       `.     ,  ..._ " `_/ "| |\ `._"       "-."   `.,"     |]])
	ELAN_Trace([[ "         /    /  ..   `.  `./ | ; `."    ,"" ,.  `.    \      |]])
	ELAN_Trace([[  `.     ,"   ,"   | |\  |       "        |  ,"\ |   \    `    ,L]])
	ELAN_Trace([[  /|`.  /    "     | `-| "                  /`-" |    L    `._/  \]])
	ELAN_Trace([[ / | .`|    |  .   `._."                   `.__,"   .  |     |  (`]])
	ELAN_Trace([["-""-"_|    `. `.__,._____     .    _,        ____ ,-  j     ".-"""]])
	ELAN_Trace([[       \      `-.  \/.    `"--.._    _,.---"""\/  "_,."     /-"]])
	ELAN_Trace([[        )        `-._ "-.        `--"      _.-".-""        `.]])
	ELAN_Trace([[       ./            `,. `".._________...""_.-"`.          _j]])
	ELAN_Trace([[      /_\.__,"".   ,."  "`-...________.---"     ."".   ,__./_\]])
	ELAN_Trace([[             \_/"""-"                           "-"""\_/`"`-`]])
	ELAN_Trace('\n  ')
	ELAN_Trace('\n  ')
	ELAN_Trace('\n  ')
end

function EDRV_ZoneSetActiveSource(zone_index, source_index) --Sending zone/source activation commands based on ELAN UI selection
		if zone_index == 0  then
			local sCmd = string.format("ssp.input.[%d] \n", source_index+1) --Elan works off base 0 source index, Focal is base 1
			ELAN_ConnectTCP()
			ELAN_SendTCP(connection, sCmd)
			ELAN_Trace("Command sent: " .. sCmd)
			ELAN_Trace(string.format("Turned on source number %d", source_index+1))
		elseif zone_index == 1 then
			local sCmd = string.format("ssp.inputZone2.[%d] \n", source_index+1)
			ELAN_ConnectTCP()
			ELAN_SendTCP(connection, sCmd)
			ELAN_Trace("Command sent: " .. sCmd)
			ELAN_Trace(string.format("Turned on source number %d", source_index+1))
		end
end

function EDRV_SetIPConfig(a,b) --Trigger information dump from processor so ProcessIncoming function can populate Brand/Model/FW fields in configurator on pressing the apply button
	ELAN_ConnectTCP()
	local sCmd = "ssp.power.on"
	ELAN_SendHTTP(sCmd)
end

function EDRV_ExecuteConfigProc(CONFIG_BUTTON_1) --Discovery button to add sources and zones and presets
	ELAN_ResetNumZoneCtlrZones(1)
	ELAN_ResetNumZoneCtlrSources(1)
	local sCmd = "ssp.power.on"
	ELAN_SendTCP(connection, sCmd)
	for i=1, source_num do
		if i == 1 then
			sSource = source_list[1]
			ELAN_SetZoneCtlrSourceName(0, sSource)
		else 
			sSource = source_list[i]
			ELAN_AddZoneCtlrSource(sSource)
		end
	end
	
	for j=0, zone_num do
		if j == 0 then
			sZone = zone_list[1]
			ELAN_SetZoneCtlrZoneName(0, "Main Theatre")
		else
			sZone = zone_list[j]
			ELAN_AddZoneCtlrZone(sZone)
		end
	end

	for h=1, preset_num do
		sCmd = string.format("Preset %d",h)
		sPreset = preset_list[h]
		ELAN_RegisterCommandText(sCmd,sPreset)
	end
end

function EDRV_ZonePower(zone_index, turn_on_off) --Sending power on/off commands based on zone turning on/off. Thinking of removing the off, might cause issues if we have multiple zones.
	if turn_on_off ~= 0 then	
		local sCmd = "ssp.power.on \n"
		ELAN_SendTCP(connection, sCmd)
		ELAN_Trace(string.format("Sent: %s", sCmd))
	--[[else
		ELAN_ConnectTCP()
		local sCmd = "ssp.power.off \n"
		ELAN_SendTCP(connection, sCmd)
		ELAN_Trace(string.format("Sent: %s", sCmd))--]]
	end
end

function EDRV_ProcessIncoming(data)    -- process data sent from the device
	local sMsg = string.format("Incoming Astral message = %s", data)
	ELAN_Trace(sMsg)
	
	if (string.find(data, "ssp.procstate.%[0%]")) then --change status colour in configurator based on procstate
		ELAN_RegisterZoneOn(1,0)
		ELAN_RegisterZoneOn(0,0)
		ELAN_SetDeviceState("RED", "Processor is off")
	elseif (string.find(data, "ssp.procstate.%[2%]")) then
		ELAN_RegisterZoneOn(0,1)
		ELAN_SetDeviceState("GREEN", "Processor Online")
	elseif (string.find(data, "ssp.procstate.%[1%]")) then
		ELAN_SetDeviceState("Yellow", "Processor initialising - Please Wait")
	end
	
	if string.find(data, "ssp.power.off") or string.find(data, "ssp.procstate.[0]") then
		ELAN_RegisterZoneOn(1,0)
		ELAN_RegisterZoneOn(0,0)
	end

	if string.find(data, "ssp.input.%[") then --source registration for two-way comms, zone 1
		sInput = GetBracketsText(data)
		nInput = tonumber(sInput)
		ELAN_RegisterZoneSource(0, nInput-1)
	end

	if string.find(data, "ssp.inputZone") then --source registration for two-way comms, other zones
		sLen = string.len(data)
		sZone = string.sub(data, 14, sLen-5)
		sInput = GetBracketsText(data)
		nInput = tonumber(sInput)
		ELAN_RegisterZoneSource(sZone-1, nInput-1)
	end


	if string.find(data, "brand") then --Enter brand info in configurator field
		sBrand = GetQuotesText(data)
		local sTag = "CFG_Brand"
		ELAN_SetConfigurationString(sTag, sBrand)
	end

	if string.find(data, "model") then --Enter model info in configurator field
		sBrand = GetQuotesText(data)
		local sTag = "CFG_Model"
		ELAN_SetConfigurationString(sTag, sBrand)
	end

	if string.find(data, "version") then --Enter FW version info in configurator field
		sLen = string.len(data)
		sBrand = string.sub(data, 14, sLen-2)
		local sTag = "CFG_FW"
		ELAN_SetConfigurationString(sTag, sBrand)
	end

	if string.find(data, "ssp.input.list") then --find the input list, increment the source number variable and add source name to table
		source_num = source_num + 1
		sInput = GetQuotesText(data)
		table.insert(source_list, sInput)
	end

	if string.find(data, "ssp.zones.list") then --find the zones list, increment the zone number variable and add zone name to table
		zone_num = zone_num + 1
		sZone = GetQuotesText(data)
		table.insert(zone_list, sZone)
	end

	if string.find(data, "ssp.preset.list") then --find the preset list and add preset name to table
		preset_num = preset_num+1
		sPreset= GetQuotesText(data)
		sPresetID = GetCommasText(data)
		sPresetID = string.sub(sPresetID, 2)
		table.insert(preset_list, sPreset)
		table.insert(preset_id_list, sPresetID)
	end

	if string.find(data, "ssp.vol.[-100.0]") then --2-way mute feedback
		sCmd = "ssp.mute.on"
		ELAN_SendTCP(connection, sCmd)
		ELAN_Trace("Muted")
	end

	if string.find(data, "ssp.vol.[-99.0]") then --2-way mute feedback
		sCmd = "ssp.mute.off"
		ELAN_SendTCP(connection, sCmd)
		ELAN_Trace("Unmuted")
	end
	
	if string.find(data, "ssp.zones.mute") then --mute 2-way comms
		sLen = string.len(data)
		sZone = string.sub(data, 17, sLen-5)
		sMute = string.sub(data, 20, sLen-2)
		ELAN_RegisterZoneMute(sZone-1, sMute)
	end
	
	if string.find(data, "ssp.mute.on") then --2-way mute feedback
		ELAN_RegisterZoneMute(0,1)
	elseif string.find(data, "ssp.mute.off") then
		ELAN_RegisterZoneMute(0,0)
	end
end

function EDRV_ExecuteFunction(fName)
	sfName = string.len(fName)
	sNum = string.sub(fName, 8, sLen)
	sNum = tonumber(sNum)
	sCmd = string.format("ssp.preset.[%d]\n", sNum)
	ELAN_SendTCP(connection, sCmd)
	ELAN_Trace(sCmd)
end

function EDRV_StopExecuteFunction(fName) --This is just so i don't get an error message in Trace

end


function EDRV_ZoneSetMute(zone_index, mute_on_off) --mute control
	if mute_on_off == 1 then
		sCmd = string.format("ssp.mute.on")
		ELAN_SendTCP(connection, sCmd)
		ELAN_Trace(sCmd)
	else
		sCmd = "ssp.mute.off"
		ELAN_SendTCP(connection, sCmd)
	end
end


 -- ===============================================
-- Volume commands for RELATIVE volume setting ONLY
-- ===============================================

function EDRV_ZoneVolumeUp()
	volCmd = "up";
	ELAN_SetTimer(0, 100)
	EDRV_OnTimer(0)
end

function EDRV_ZoneVolumeDown()
	volCmd= "down";
	ELAN_SetTimer(0, 100)
	EDRV_OnTimer(0)
end

function EDRV_ZoneVolumeStop()
	ELAN_KillTimer(0)
end

function EDRV_OnTimer(timerID)
	sCmd = string.format("ssp.vol.%s", volCmd)
	ELAN_SendTCP(connection, sCmd)
	ELAN_Trace(sCmd)
end


-- ===============================================
-- Volume commands for ABSOLUTE volume setting ONLY
-- ===============================================

function EDRV_ZoneSetMute(zone_index, mute_on_off) --mute control FOR ABSOLUTE ONLY
	--[[sCmd = string.format("ssp.zones.mute.[%d,%d]", zone_index, mute_on_off)
	if mute_on_off then
		ELAN_SendHTTP("ssp.mute.on")
		ELAN_Trace(sCmd)
	else
		ELAN_SendHTTP("ssp.mute.off")
		ELAN_Trace(sCmd)

	end--]]
end

function EDRV_ZoneSetVolume(zone_index, volume_level) --For ABSOLUTE volume setting ONLY. 
	rVol = 100 - volume_level --Processor uses negative numbers to represent volume, -100 to 0
	sCmd = string.format("ssp.zones.volume.[1, -%d]", rVol)
	ELAN_SendHTTP(sCmd)
	ELAN_Trace(string.format("Vol command sent: %s", sCmd))
end

-- ===============================================
-- Custom functions
-- ===============================================

function GetQuotesText(sData) --All zone and source names are within quotes, this function takes the text and grabs part of the string within quotes
	str2 = sData
	res2 = string.match(str2, '%b""')
	res2 = string.gsub(res2, '"', "")
	return res2
end

function GetBracketsText(sData) --input number data is within straight brackets. This function take the incoming text and grabs part of the string within brackets
	str = sData
	res = str:match("%[(%d+)%]")
	return res
end

function GetCommasText(sData) --input number data is within commas. This function take the incoming text and grabs part of the string within brackets
	str = sData
	res = str:match("%,(.-)%,")
	return res
end














