local localScript = Instance.new("LocalScript")
localScript.Parent = game.StarterPlayer.StarterPlayerScripts
localScript.Name = "ChatFix"
localScript.Source = [[
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local function GetSafeValue(player, path)
	local current = player
	for _, part in ipairs(path) do
		current = current:FindFirstChild(part)
		if not current then return false end
	end
	return current.Value
end

local NAME_COLORS = {
	Color3.fromRGB(253, 41, 67), Color3.fromRGB(1, 162, 255),
	Color3.fromRGB(2, 184, 87), Color3.fromRGB(180, 128, 255),
	Color3.fromRGB(218, 133, 65), Color3.fromRGB(245, 205, 48),
	Color3.fromRGB(232, 186, 200), Color3.fromRGB(215, 197, 154),
}

local function GetNameValue(pName)
	local value = 0
	for i = 1, #pName do
		local c = string.byte(pName:sub(i, i))
		local ri = #pName - i + 1
		if #pName % 2 == 1 then ri -= 1 end
		if ri % 4 >= 2 then c = -c end
		value += c
	end
	return value
end

local function ComputeNameColor(pName)
	return NAME_COLORS[(GetNameValue(pName) % #NAME_COLORS) + 1]
end

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")

	if message.TextSource then
		local player = Players:GetPlayerByUserId(message.TextSource.UserId)
		if player then
			local tags = {}

			local chatTitle = player:GetAttribute("ChatTitle")
			if chatTitle and GetSafeValue(player,{"PlayerData", "Settings", "Privacy", "HideDevItems2"}) ~= true then
				local split = string.split(chatTitle, "||")
				local txt = split[1] or ""
				local colStr = split[2] or "255,255,255"

				if string.find(txt, "<font") then
					table.insert(tags, "[" .. txt .. "]")
				else
					local col = string.split(colStr, ",")
					local R, G, B = col[1] or 255, col[2] or 255, col[3] or 255
					table.insert(tags, string.format("<font color='rgb(%s,%s,%s)'>[%s]</font>", R, G, B, txt))
				end
			end

			local rank = player:GetAttribute("RankTitle")
			if rank and GetSafeValue(player, {"PlayerData", "Settings", "Game", "RankTitleEnabled"}) then
				local clean = rank:gsub("Forsaken ", "")
				local RankModule = require(ReplicatedStorage.Modules.Schematics.GroupRankTitleColors)
				local color = RankModule[clean] or Color3.new(1,1,1)
				table.insert(tags, string.format("<font color='rgb(%d,%d,%d)'>[%s]</font>",
					math.round(color.R*255), math.round(color.G*255), math.round(color.B*255), clean))
			end

			if player:GetAttribute("VIP") and GetSafeValue(player, {"PlayerData", "Settings", "Game", "VIPTitleEnabled"}) then
				table.insert(tags, "<font color='rgb(255,215,95)'>[VIP]</font>")
			end
			
			local pColor = ComputeNameColor(player.Name)
			local nameFormat = string.format("<font color='rgb(%d,%d,%d)'>%s</font>", 
				math.round(pColor.R*255), math.round(pColor.G*255), math.round(pColor.B*255), player.DisplayName)

			local finalPrefix = table.concat(tags, " ")
			if #tags > 0 then
				properties.PrefixText = finalPrefix .. " " .. nameFormat .. ":"
			else
				properties.PrefixText = nameFormat .. ":"
			end
		end
	end

	return properties
end
]]
