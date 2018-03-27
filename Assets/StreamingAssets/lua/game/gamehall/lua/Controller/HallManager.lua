--
-- Author: jinda.w
-- Date: 2017-09-13 20:00:43
--
local M = class("HallManager")

function M:ctor()
	-- body
	log("HallManager")

	self.tab_hallui = {}

	self.tab_hallui["hall"] = require("Controller.HallCtrl"):create()
	self.tab_hallui["playerinfo"] = require("Controller.PlayerInfoCtrl"):create()
	self.tab_hallui["record"] = require("Controller.RecordCtrl"):create()
	self.tab_hallui["help"] = require("Controller.HelpCtrl"):create()
	self.tab_hallui["set"] = require("Controller.SetCtrl"):create()
	self.tab_hallui["invite"] = require("Controller.InviteCtrl"):create()
	self.tab_hallui["joinroom"] = require("Controller.JoinRoomCtrl"):create()
	self.tab_hallui["createroom"] = require("Controller.CreateRoomCtrl"):create()
	self.tab_hallui["notice"] = require("Controller.ProtocolCtrl"):create()
end

function M:showPanel( str_name )
	-- body
	for k,ui_ctrl in pairs(self.tab_hallui) do
		if k == str_name then
			ui_ctrl:show(data)
			return ui_ctrl
		end
	end
end

function M:closePanel( str_name, bdestroy )
	-- body
	for k,ui_ctrl in pairs(self.tab_hallui) do
		if k == str_name and ui_ctrl then
			ui_ctrl:close(bdestroy)
		end
	end
end

function M:closeAllPanel( bdestroy )
	-- body
	for k,ui_ctrl in pairs(self.tab_hallui) do
		if ui_ctrl then
			ui_ctrl:close(bdestroy)
		end
	end
end

function M:showGame( data )
	-- body
	local game_id = 1
	log("showGame"..game_id)
	if game_id == 1 then
		-- ddz
		RoomManager:connect(data)
	end
end

return M