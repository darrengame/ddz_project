--
-- Author: jinda.w
-- Date: 2017-09-13 19:44:39
--

local M = class("PlayerSeatCtrl")

function M:ctor()
	-- body

	return self
end

function M:show()
	-- body
	log("PlayerSeatCtrl show")
	resMgr:LoadPrefab('PlayerSeat', { 'PlayerSeatPanel' }, function( objs )
		self:showObj(objs)
	end)
end

function M:close()
	-- body
	if bdestroy then
		destroy(self.game_object)
	else
		self.game_object:SetActive(false)
	end
end

function M:showObj(objs)
	-- body
	log("show prefab:"..objs[0].name)
	
	self.game_object = newObject(objs[0])
	log("show obj:"..self.game_object.name)
	self.transform = self.game_object.transform

	self.seat_view = require("View.PlayerSeatView"):create(self.game_object, self.transform)

	-- self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
	-- for k,v in pairs(self.seat_view.tab_buttons) do
	-- 	self.lua_behaviour:AddClick(v, function( obj )
	-- 		self:onBtnCallback(obj)
	-- 	end)
	-- end
end

function M:setParent( parent )
	self.transform:SetParent(parent)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero
end

function M:setName( name )
	-- body
	self.game_object.name = name
end

function M:setPos( pos )
	-- body
	self.transform.anchoredPosition = pos
end

function M:onBtnCallback(obj)
	-- body
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_avatar" then
		
	end
end

function M:setPlayerName( name )
	-- body
	self.seat_view:setPlayerName(name)
end

function M:setPlayerDiamond( diamond )
	-- body
	self.seat_view:setPlayerDiamond(diamond)
end

function M:setPlayerMaster( bmaster )
	-- body
	self.seat_view:setPlayerMaster(bmaster)
end

function M:setPlayerAvatar( url )
	-- body
	local sprite
	self.seat_view:setPlayerAvatar(sprite)
end

function M:showPlayerInfo()
	-- body
	self.seat_view:showPlayerInfo()
end

function M:resetPlayerInfo()
	-- body
	self.seat_view:resetPlayerInfo()
end

return M