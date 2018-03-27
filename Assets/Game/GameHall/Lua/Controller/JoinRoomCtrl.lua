-- loading controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("JoinRoomCtrl")

function M:ctor()
	-- body
	-- UpdateCtrl:onUpdateMsg("1", "1")
	self.room_number = ""
	return self
end

function M:show()
	-- body
	log("M show")
	require("View.JoinRoomPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("JoinRoom", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("JoinRoom")
		self.game_object = nil
	else
		self.game_object:SetActive(false)
		self.room_number = ""
		JoinRoomPanel.setRoomNumber(self.room_number)
	end
end

function M:showPanel( obj )
	-- body
	log("show panel:"..obj.name)
	self.game_object = obj
	self.transform = obj.transform
	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
	for k,v in pairs(JoinRoomPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end
	self.room_number = ""
	JoinRoomPanel.setRoomNumber(self.room_number)
end

function M:onBtnCallback( obj )
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_close" then
		self:close()
	elseif name == "Button_clear" then
		self.room_number = ""
		JoinRoomPanel.setRoomNumber(self.room_number)
	elseif name == "Button_delete" then
		self.room_number = string.sub(self.room_number, 1, string.len(self.room_number)-1)
		JoinRoomPanel.setRoomNumber(self.room_number)
	else
		if string.len(self.room_number) < 6 then
			local number = string.sub(name, -1)
			self.room_number = self.room_number..number
			JoinRoomPanel.setRoomNumber(self.room_number)

			if string.len(self.room_number) == 6 then
				-- join room
				self:joinGame()
			end
		end
	end
end

function M:joinGame()
	-- body
	local id = tonumber(string.sub(self.room_number, -2))
	local game_list = AppData:getValue("gamelist")
	local game
	for k,v in pairs(game_list) do
		if v.id == id then
			--todo
			game = v
		end
	end
	if not game then
		log("no game id:"..id)
		return
	end
	local req_data = {}
	req_data.join_type = 2
	req_data.ip = game.ip
	req_data.port = game.port
	req_data.id = game.id
	req_data.room_number = self.room_number
	dump(req_data, "option_data")
	HallManager:showGame(req_data)
end

return M