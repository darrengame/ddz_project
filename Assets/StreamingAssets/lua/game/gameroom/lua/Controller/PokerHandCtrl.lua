-- 手牌操控
-- Author: jinda.w
-- Date: 2017-11-08 15:06:56
--

local PokerModel = require("Model.PokerHandModel")

local M = class("PokerHandCtrl", PokerModel)

function M:init()
	-- init
	self.touch_time = os.time()
	self.select_cards = {}
end

function M:addTouch()
	-- 添加触摸
	self.touch_time = os.time()
	self.select_cards = {}

	touchMgr:RegisterTouchEvent("cardtouch", function( event )
		local localpos = event.uguiPoint
		local name = event.touchEvent
		log("touch name:"..name)
		dump(localpos, "touch pos")
		if name == "Began" then
			self:touchBegan(localpos)
		elseif name == "Moved" then
			self:touchMoved(localpos)
		elseif name == "Ended" then
			self:touchEnded(localpos)
		elseif name == "Canceled" then
			-- 取消
		end
	end)
end

function M:removeTouch()
	-- 移除触摸
	touchMgr:UnRegisterTouchEvent("cardtouch")
end

function M:touchBegan( localpos )
	-- 触摸开始
	self.card_item = self:select(localpos)
	if self.card_item then
		self:selectCard(self.card_item)
		dump(self.card_item, "card item")
		log(string.format("card_item:%02x", self.card_item.ncard))
	else
		-- log("os time:"..os.time()..", "..self.touch_time)
		-- log("os offest:"..os.time() - self.touch_time)
		if os.time() - self.touch_time <= 1 then
			self:resetAllSelect()
		end
		self.touch_time = os.time()
	end
end

function M:touchMoved( localpos )
	-- 触摸移动
	local card_item = self:select(localpos)
	if card_item and self.card_item ~= card_item then
		self.card_item = card_item
		self:selectCard(card_item)
	end
end

function M:touchEnded( localpos )
	-- 触摸结束
end

function M:select( pos )
	-- body
	local offest_y = pos.y - (self.vector3.y - self:getCardSize().height/2)
	if offest_y > self:getCardSize().height
		or offest_y < 0 then
		return nil
	end
	local offest_x = pos.x + ((#self.ncards/2)*self.ninterval - self.vector3.x + self.ninterval)
	log("offest_x:"..offest_x)
	
	local index = math.floor(offest_x/self.ninterval)
	log("select index:"..index..", "..#self.ncards)
	if index >= #self.ncards and index <= #self.ncards+1 then
		index = #self.ncards-1
	end

	for k,v in pairs(self.ncards) do
		if v.index == index then
			return v
		end
	end
	return nil
end

function M:selectByIndex( index )
	-- body
	if index > 0 and index <= #self.ncards then
		return self.ncards[index]
	end
end

function M:selectCard( card_item )
	-- body
	local pos = card_item.sprite:getPos()
	if card_item.bselect then
		card_item.bselect = false
		pos.y = pos.y - 30
		for k,v in pairs(self.select_cards) do
			if v.ncard == card_item.ncard then
				table.remove(self.select_cards, k)
				break
			end
		end
	else
		card_item.bselect = true
		pos.y = pos.y + 30
		table.insert(self.select_cards, card_item)
	end
	log(string.format("selectCard:%s", tostring(card_item.bselect)))
	card_item.sprite:setPos(pos)
end

function M:resetAllSelect()
	-- 重置所有的牌
	for k,v in pairs(self.ncards) do
		if v.bselect then
			self:selectCard(v)
		end
	end
end

function M:getSelectCards()
	-- body
	local ncards = {}
	dump(self.select_cards)
	for k,v in pairs(self.select_cards) do
		table.insert(ncards, v.ncard)
	end
	self.select_cards = {}
	return ncards
end

return M