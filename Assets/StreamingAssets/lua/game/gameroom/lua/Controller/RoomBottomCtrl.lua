--
-- Author: jinda.w
-- Date: 2017-09-13 19:44:39
--

local M = class("RoomBottomCtrl")

function M:ctor()
	-- body

	return self
end

function M:show()
	-- body
	log("RoomBottomCtrl show")
	require("View.RoomBottomPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("RoomBottom", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close(bdestroy)
	-- body
	if bdestroy then
		panelMgr:ClosePanel("RoomBottom")
		self.game_object = nil
	else
		self.game_object:SetActive(false)
	end
end

function M:showPanel(obj)
	-- body
	log("show panel:"..obj.name)
	self.game_object = obj
	self.transform = obj.transform
	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")

	log(string.format("dpi:%d, width:%d, height:%d", Screen.dpi, Screen.width, Screen.height))
	-- vector3.y = -Screen.height/2+35
	self.transform.anchoredPosition = Vector3.New(0, -320, 0)
	
	for k,v in pairs(RoomBottomPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end
end

function M:onBtnCallback(obj)
	-- body
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_avatar" then
		
	end
end

return M