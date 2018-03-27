-- Bulletin controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("BulletinCtrl")

function M:ctor()
	-- body
	-- UpdateCtrl:onUpdateMsg("1", "1")
	return self
end

function M:show()
	-- body
	log("M show")
	require("View.ProtocolPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("Protocol", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("Protocol")
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
	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
	self.lua_behaviour:AddClick(ProtocolPanel.btn_close, function( obj )
		self:onBtnCallback(obj)
	end)
end

function M:onBtnCallback( obj )
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_close" then
		self:close()
	end
end

return M