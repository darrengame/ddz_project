-- loading controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("ProtocolCtrl")

function M:ctor()
	return self
end

function M:show()
	-- body
	log("ProtocolCtrl show")
	require("View.ProtocolPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("Protocol", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close(bdestroy)
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

function M:setTitle( str_title )
	-- 标题
	ProtocolPanel.setTitle(str_title)
end

function M:setContent( str_title, str_content )
	-- 内容
	ProtocolPanel.setContent(str_title, str_content)
end

return M