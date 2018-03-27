--
-- Author: jinda.w
-- Date: 2017-09-13 19:44:39
--

local M = class("RoomCtrl")

function M:ctor()
	-- body

	return self
end

function M:show()
	-- body
	log("RoomCtrl show")
	require("View.ddz.RoomPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("Room", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close()
	-- body
	if bdestroy then
		panelMgr:ClosePanel("Room")
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

	for k,v in pairs(RoomPanel.tab_buttons) do
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