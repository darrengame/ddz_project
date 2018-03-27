--
-- Author: jinda.w
-- Date: 2017-09-13 19:01:31
--

local M = class("RoomManager")

function M:ctor()
	-- body
	log("RoomManager")

	self.tab_roomui               = {}
	self.tab_roomui["roomBottom"] = require("Controller.RoomBottomCtrl"):create()
	self.tab_roomui["msgbox"]     = require("Controller.MsgBoxCtrl"):create()
	
	return self
end

function M:showPanel( str_name )
	-- body
	for k, uictrl in pairs(self.tab_roomui) do
		if k == str_name and uictrl then
			uictrl:show()
			return uictrl
		end
	end
end

function M:closePanel( str_name, bdestroy )
	-- body
	for k,ui_ctrl in pairs(self.tab_roomui) do
		if k == str_name and ui_ctrl then
			ui_ctrl:close(bdestroy)
		end
	end
	self.tab_roomui[str_name] = nil
end

function M:closeAllPanel( bdestroy )
	-- body
	for k,ui_ctrl in pairs(self.tab_roomui) do
		if ui_ctrl then
			ui_ctrl:close(bdestroy)
		end
	end
end

function M:connect( data )
	-- 连接
	self.game_manager = require("Controller.ddz.GameManager")
	self.game_manager:connect(data)
end

function M:closeConnect()
	-- body
	self.game_manager:closeConnect()
end

return M
