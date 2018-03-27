-- 控制
-- Author: jinda.w
-- Date: 2017-09-15 16:56:14
--

-- mode
-- scale
-- add 
-- remove
-- show
-- select
-- gethandCard

-- createCard

local M = class("PokerHandModel")

function M:ctor(pokerctrl, parent, name)
	-- 属性
	self.pokerctrl = pokerctrl

	self.nmodel = 1
	self.nscale = 1
	self.vector3  = Vector3.zero
	self.ninterval = 50

	self.card_sizes = {width=142, height=185}
	self.ncards = {}

	self.game_object = UnityEngine.GameObject.New()
	self.game_object:AddComponent(typeof(UnityEngine.RectTransform))
	self.game_object:AddComponent(typeof(UnityEngine.UI.HorizontalLayoutGroup))
	self.game_object:AddComponent(typeof(UnityEngine.UI.ContentSizeFitter))
	self.game_object.name = name or "pokerlayer"
	self.transform = self.game_object.transform
	self.transform:SetParent(parent)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero
	self.transform.sizeDelta = Vector2.zero
	-- self.game_object.anchoredPosition = Vector3.New(0.5, 0.5, 0);
	local hor_layout = self.game_object:GetComponent(typeof(UnityEngine.UI.HorizontalLayoutGroup))
	hor_layout.spacing = -92
	hor_layout.childForceExpandWidth = false
	hor_layout.childForceExpandHeight = false
	hor_layout.childAlignment = UnityEngine.TextAnchor.MiddleCenter

	local content_size = self.game_object:GetComponent(typeof(UnityEngine.UI.ContentSizeFitter))
	content_size.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize
	-- content_size.horizontalFit = 3 --PreferredSize
	return self
end

-- 牌模式 nmodel -> 1:正面， 2:背面
function M:setMode( nmodel )
	self.nmodel = nmodel
end

function M:setScale( vector3 )
	self.nscale = vector3
	self.transform.localScale = self.nscale
end

function M:setPos( vector3 )
	self.vector3 = vector3
	self.transform.anchoredPosition = self.vector3
end

function M:getCardSize()
	-- body
	return {width=self.card_sizes.width*self.nscale, height=self.card_sizes.height*self.nscale}
end

function M:add( ncards )
	-- body
	for k,v in pairs(ncards) do
		self:createCard(v)
	end
end

function M:addIndex( ncard, index )
	-- body
	self:createCard(ncard, index)
end

function M:remove( ncards )
	-- body
	for k_card,v_card in pairs(ncards or {}) do
		for k_data,v_data in pairs(self.ncards) do
			if v_card == v_data.ncard then
				local ncard_datas = table.remove(self.ncards, k_data)
				self:removeCard(ncard_datas)
				break
			end
		end
	end
	self:sort()
end

function M:show( ncards )
	-- body
	for i,v in ipairs(ncards) do
		self:createCard(v)
	end
end

function M:getHandCards()
	-- body
	local nhand_cards = {}
	for k,v in pairs(self.ncards) do
		table.insert(nhand_cards, v.ncard)
	end
	return nhand_cards
end

function M:clearAll()
	-- body
	self:remove(self:getHandCards())
end

function M:createCard( ncard, index )
	-- body
	local sprite = self.pokerctrl:create()
	sprite:show(ncard, function()
		sprite:setParent(self.transform)
		
		local cur_num = #self.ncards
		-- local vector3 = Vector3.zero
		-- vector3.x = self.ninterval * cur_num
		-- -- vector3.y = vector3.y
		
		-- -- dump(self.vector3)
		-- sprite:setPos(vector3)
		sprite:setName(string.format("poker_%02x", ncard))
		if index then
			sprite:setSiblingIndex(index)
		end
		if self.nmodel == 2 then
			sprite:setBackgroud()
		end
		local ncard_datas = {
			ncard = ncard,
			sprite = sprite,
			index = cur_num,
			bselect = false,
		}
		table.insert(self.ncards, ncard_datas)
	end)

	return sprite
end

function M:removeCard( ncard_datas )
	-- body
	if ncard_datas.sprite then
		ncard_datas.sprite:close(true)
	end
end

function M:sort(ddz_rule)
	-- 排序
	if ddz_rule then
		local bSorted = false
		local nLast = #self.ncards
		repeat
			bSorted = true
			for i=1,nLast-1 do
				if ddz_rule:getGrade(self.ncards[i].ncard) < ddz_rule:getGrade(self.ncards[i+1].ncard) 
					or (ddz_rule:getGrade(self.ncards[i].ncard) == ddz_rule:getGrade(self.ncards[i+1].ncard) 
						and ddz_rule:getColor(self.ncards[i].ncard) < ddz_rule:getColor(self.ncards[i+1].ncard)) then
					--todo
					self.ncards[i], self.ncards[i+1] = self.ncards[i+1], self.ncards[i]
					bSorted = false
				end
			end
			nLast = nLast-1
		until (bSorted)
	end
	for i,v in ipairs(self.ncards) do
		v.index = i-1
		-- local vector3 = Vector3.zero
		-- vector3.x = self.ninterval * (i-1)
		v.sprite:setSiblingIndex(v.index)
	end
end

return M