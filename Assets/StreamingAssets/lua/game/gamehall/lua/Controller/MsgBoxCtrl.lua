-- loading controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("MsgBoxCtrl")

function M:ctor()
	-- body
	return self
end

function M:show(str_text)
	-- body
	log("M show")
	require("View.MsgBoxPanel")
	
	self.str_text = str_text

	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("MsgBox", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("MsgBox")
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
	self.lua_behaviour:AddClick(MsgBoxPanel.btn_close, function( obj )
		self:onBtnCallback(obj)
	end)
	self:setText(self.str_text)
end

function M:setText( str_text )
	-- bod
	MsgBoxPanel.setText(str_text)
end

function M:onBtnCallback( obj )
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_close" then
		self:close()
	end
end

return M