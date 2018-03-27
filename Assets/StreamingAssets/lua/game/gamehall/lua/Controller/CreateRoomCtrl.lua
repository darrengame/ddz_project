-- loading controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("CreateRoomCtrl")

function M:ctor()
	-- body
	self.option_pos = Vector3.New(121, -33, 0)
	return self
end

function M:show()
	-- body
	log("M show")
	require("View.CreateRoomPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("CreateRoom", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("CreateRoom")
		self.game_object = nil
		self.cur_option = nil
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
	for k,v in pairs(CreateRoomPanel.tab_buttons) do
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
	elseif name == "Button_create" then
		local req_data = {}
		local vneues = self.game_list[self.select_id]
		local data = self.cur_option_ctrl:getOption()
		req_data.info = data
		req_data.join_type = 1
		req_data.ip = vneues.ip
		req_data.port = vneues.port
		req_data.id = vneues.id
		dump(req_data, "option_data")
		HallManager:showGame(req_data)
	else
		local str_id = string.match(name, "%d+")
		log("game_list name:"..str_id)
		for k,v in pairs(self.game_list) do
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
	self.options = {}
	self.select_games = {}
	self.select_options = {}

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
			table.insert(CreateRoomPanel.tab_buttons, obj)
		end
	end)
end

function M:initGame( id)
	-- body
	self.select_id = id
	local name = "ddz_option"
	local optionName = "DdzOptionCtrl"
	if self.select_id == 1 then
		name = "ddz_option"
		optionName = "DdzOptionCtrl"
	elseif self.seletc_id == 2 then
		name = "ddz_option"
		optionName = "DdzOptionCtrl"
	end

	if not self.options[id] then
		self.options[id] = {}
		resMgr:LoadPrefab('CreateRoom', {name}, function( objs )
			local obj = newObject(objs[0])
			obj.name = "option_"..id
			self.options[id].id = id
			self.options[id].name = obj.name
			self.options[id].game_object = obj
			self.options[id].transform = obj.transform
			self.options[id].transform:SetParent(self.transform)
			self.options[id].transform.localScale = Vector3.one
			self.options[id].transform.localPosition = self.option_pos

			self:setOption(id, optionName)
		end)
	else
		self:setOption(id, optionName)
	end
end

function M:setOption( id, name )
	self.btn_create = self.transform:Find(self.options[id].name.."/Viewport/Content/Button_create").gameObject
	if self.btn_create then
		if self.cur_option then
			self.cur_option:SetActive(false)
		end
		self.cur_option = self.options[id].game_object
		self.cur_option:SetActive(true)
		CreateRoomPanel.tab_buttons[2] = self.btn_create
	end

	if self.select_options[id] == nil then
		if id == 1 then
			self.select_options[id] = require("Controller."..name):create(self.options[id].game_object, self.options[id].transform)
		end
	end
	self.cur_option_ctrl = self.select_options[id]
	self.cur_option_ctrl:setOption(self.game_list[id])
end

return M