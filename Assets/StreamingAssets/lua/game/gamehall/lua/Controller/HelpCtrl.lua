-- help controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("HelpCtrl")

function M:ctor()
	-- body
	return self
end

function M:show()
	-- body
	log("M show")
	require("View.HelpPanel")
	self.help_config = require("Model.HelpConfig")

	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("Help", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("Help")
		self.game_object = nil
	else
		self.game_object:SetActive(false)
	end
end

function M:showPanel( obj )
	-- body
	log("show panel:"..obj.name)
	self.game_object = obj
	self.transform = obj.transform

	self.game_list = AppData:getValue("gamelist")
	self.select_id = 1
	self:addGame(self.game_list)
	self:initGame(self.select_id)

	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
	for k,v in pairs(HelpPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end
end

function M:onBtnCallback( obj )
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_close" then
		self:close()
	else
		local str_id = string.match(name, "%d+")
		log("venue_list name:"..str_id)
		for k,v in pairs(self.venue_list) do
			if str_id == tostring(v.id)
			and v.id ~= self.select_id then
				self:initGame(v.id)
				break
			end
		end
	end
end

function M:addGame( game_list )
	-- body
	self.select_games = {}

	local game_content = self.transform:Find("ScrollView_game/Viewport/Content")
	resMgr:LoadPrefab('Common', {"Button_select"}, function( objs )
		dump(game_list, "game_list")
		for k,v in pairs(game_list) do
			self.select_games[v.id] = {}
			local obj = newObject(objs[0])
			obj.name = "select_game_"..v.id
			self.select_games[v.id].id = v.id
			self.select_games[v.id].game_object = obj
			self.select_games[v.id].transform = obj.transform
			self.select_games[v.id].transform:SetParent(game_content)
			self.select_games[v.id].transform.localScale = Vector3.one
			self.select_games[v.id].transform.localPosition = Vector3.zero
			local text_msg = self.select_games[v.id].transform:Find("Text"):GetComponent('Text')
			text_msg.text = v.name
			table.insert(HelpPanel.tab_buttons, obj)
		end
	end)
end

function M:initGame( id )
	-- body
	self.select_id = id
	HelpPanel.setRule(self.help_config[id] or "")
end

return M