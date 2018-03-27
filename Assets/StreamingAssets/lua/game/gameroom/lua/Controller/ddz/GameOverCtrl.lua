-- 游戏结束
-- Author: jinda.w
-- Date: 2017-11-28 19:02:32
--

local M = class("GameOver")

function M:ctor()
	-- body
end

function M:show(data, func)
	log("GameOver show")
	require("View.ddz.DdzOverPanel")
	self.data = data
	self.func  = func
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("DdzOver", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close(bdestroy)
	-- body
	if bdestroy then
		panelMgr:ClosePanel("DdzOver")
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

	for k,v in pairs(DdzOverPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end

	self:initData(self.data)
end

function M:onBtnCallback(obj)
	-- body
	local name = obj.name
	log("on click------->>" .. name)
	if self.func then
		self.func(name)
	end
	self:close(true)
end

function M:initData(data)
	-- body
	DdzOverPanel.setData(data.master_seatid, data.farmerwin)
	
	for i,v in ipairs(data.game_score) do
		DdzOverPanel.setPlayerData(i, v, data.seatid)
	end
end

return M