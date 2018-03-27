-- loading controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("LoadCtrl")

function M:ctor()
	-- body
	-- UpdateCtrl:onUpdateMsg("1", "1")
	return self
end

function M:show()
	-- body
	log("M show")
	
	if self.game_object == nil then
		panelMgr:CreatePanel("Loading", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:showPanel( obj )
	-- body
	log("show panel:"..obj.name)
	require("View.LoadingPanel")
	self.game_object = obj
	self.transform = obj.transform
	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
end

function M:onBtnCallback( obj )
end

return M