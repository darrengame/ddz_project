--
-- Author: jinda.w
-- Date: 2017-09-13 19:44:39
--

local M = class("PokerCtrl")

function M:ctor()
	-- body
end

function M:show(ncard, func)
	-- body
	log("PokerCtrl show")
	self.ncard = ncard
	resMgr:LoadPrefab('Poker', { 'PokerPanel' }, function( objs )
		self:showObj(objs)
		if func then
			func()
		end
	end)
end

function M:close(bdestroy)
	-- body
	if bdestroy then
		destroy(self.game_object)
		-- panelMgr:ClosePanel("Poker")
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

	self.cardview = require("View.PokerView"):create(self.game_object, self.transform)

	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")

	-- for k,v in pairs(self.cardview.tab_buttons) do
	-- 	self.lua_behaviour:AddClick(v, function( obj )
	-- 		self:onBtnCallback(obj)
	-- 	end)
	-- end
	self:setData(self.ncard)
end

function M:onBtnCallback(obj)
	-- body
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_avatar" then
		
	end
end

function M:setData( ncard )
	-- body
	self.ncard = ncard
	local value = ncard%16
	local color = math.floor(ncard/16)
	local image_name_card = string.format("poker_%x.png", value)
	local image_name_color = string.format("poker_color_%d.png", color)
	local bjoker = ncard>=0x41
	if bjoker then
		image_name_card = string.format("poker_%02x.png", ncard)
	end
	-- log("image_name_card file name:"..image_name_card)
	-- log("image_name_color file name:"..image_name_color)
	self.cardview:setData(image_name_card, image_name_color, color, bjoker)
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

function M:setPos( vector3 )
	-- body
	self.transform.anchoredPosition = vector3
end

function M:setSiblingIndex( index )
	-- body
	self.transform:SetSiblingIndex(index)
end

function M:getPos()
	-- body
	return self.transform.anchoredPosition
end

function M:setScale( vector3 )
	-- body
	self.transform.localScale = vector3
end

function M:setBackgroud()
	-- body
	self.cardview:setBackgroud("bg_backpoker")
end

function M:move( poss )
	-- body
end

return M