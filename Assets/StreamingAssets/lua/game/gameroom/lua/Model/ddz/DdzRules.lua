--
-- Author: jinda.w
-- Date: 2017-11-06 19:53:53
--

-- local bit = require("bit")
-- 数值掩码
local	MASK_COLOR = 0xF0		-- 花色掩码
local	MASK_VALUE = 0x0F		-- 数值掩码
local	MASK       = 16			-- 数值掩码

local M = class("DdzRules")

function M:ctor(config)
	-- body
	self.config = config
	self.tab_cards = {}
	self.grade = 0
	
	assert(self:getCardType({3}) == self.config.CT_SINGLE)
	assert(self:getCardType({65,66}) == self.config.CT_BOMB_KING)
	assert(self:getCardType({3,3}) == self.config.CT_DOUBLE)
	assert(self:getCardType({3,3,4,4,5,5}) == self.config.CT_SHUN_ZI_DOUBLE)
	assert(self:getCardType({3,3,3,4,4,4,5,5,5}) == self.config.CT_FEIJI)
	assert(self:getCardType({3,4,5,6,7}) == self.config.CT_SHUN_ZI)
	assert(self:getCardType({13,3,4,5,6,7,8,9,10,11,12,1}) == self.config.CT_SHUN_ZI)
	assert(self:getCardType({3,3,3,3}) == self.config.CT_BOMB)
	assert(self:getCardType({3,3,3,3,1,1}) == self.config.CT_FOUR_DOUBLE)
	assert(self:getCardType({3,3,3,3,4,4,4,4}) == self.config.CT_FEIJI_ONE)
	assert(self:getCardType({3,4,5,6,7,8,9}) == self.config.CT_SHUN_ZI)
	assert(self:getCardType({3,3,3,4,4,4,5,5,5}) == self.config.CT_FEIJI)
	assert(self:getCardType({3,3,3,1,4,4,4,2,5,5,5,7}) == self.config.CT_FEIJI_ONE)
	assert(self:getCardType({3,3,3,1,1,4,4,4,2,2,5,5,5,7,7}) == self.config.CT_FEIJI_DOUBLE)
	assert(self:getCardType({3,3,3}) == self.config.CT_THREE)
	assert(self:getCardType({3,3,3,4}) == self.config.CT_THREE_ONE)
	assert(self:getCardType({3,3,3,4,4}) == self.config.CT_THREE_DOUBLE)
	assert(self:getCardType({3,3,3,3,4,4,5,5}) == self.config.CT_FOUR_FOUR)
end

function M:getValue( ncard )
	-- local nvalue = bit.band(ncard, MASK_COLOR)
	local nvalue = ncard%MASK
	return nvalue
end

function M:getColor( ncard )
	-- local ncolor = bit.band(ncard, MASK_VALUE)
	local ncolor = math.floor(ncard/MASK)
	return ncolor
end

function M:getGrade( ncard )
	-- 逻辑值
	local ncolor = self:getColor(ncard)
	local nvalue = self:getValue(ncard)

	if ncolor == 4 then
		return nvalue + 15
	end
	if nvalue == 1 or nvalue == 2 then
		return nvalue + 13
	end
	return nvalue
end

function M:getGradeCounts( ncards )
	-- body
	local grade_counts = {}
	for i,v in ipairs(ncards) do
		local grade = self.tab_cards[v].grade
		if grade_counts[grade] == nil then
			grade_counts[grade] = {count=0, ncard=v}
		end
		grade_counts[grade].count = grade_counts[grade].count+1
	end
	return grade_counts
end

function M:sortByGrade( ncards )
	-- 按逻辑值排序
	ncards = ncards or {}
	
	local bSorted = false
	local nLast = #ncards

	repeat
		bSorted = true
		for i=1,nLast-1 do
			if self:getGrade(ncards[i]) < self:getGrade(ncards[i+1]) 
				or (self:getGrade(ncards[i]) == self:getGrade(ncards[i+1]) 
					and self:getColor(ncards[i]) < self:getColor(ncards[i+1])) then
				--todo
				ncards[i], ncards[i+1] = ncards[i+1], ncards[i]
				bSorted = false
			end
		end
		nLast = nLast-1
	until (bSorted)

	return ncards
end

function M:sortByValue( ncards )
	-- 按牌面值排序
	ncards = ncards or {}
	table.sort(ncards, function( a, b )
		return self:getValue(a) > self:getValue(b)
	end)
	return ncards
end

function M:setCardItems( ncards )
	-- 牌型数据结构
	for i,v in ipairs(ncards) do
		self.tab_cards[v] = 
		{
			id    = i,
			ncard = v,
			grade = self:getGrade(v), 
			color = self:getColor(v),
			value = self:getValue(v),
		}
	end
end

function M:isOne( ncards )
	-- body
	if #ncards ~= 1 then
		return false
	end
	self.grade = self.tab_cards[ncards[1]].grade
	return true
end

function M:isDouble( ncards )
	-- 对子
	if #ncards == 2
		and self.tab_cards[ncards[1]].grade == self.tab_cards[ncards[2]].grade then
		self.grade = self.tab_cards[ncards[1]].grade
		return true
	end
	return false
end

function M:isThree( ncards )
	-- 三张
	if #ncards == 3
		and self.tab_cards[ncards[1]].grade == self.tab_cards[ncards[2]].grade
		and self.tab_cards[ncards[2]].grade == self.tab_cards[ncards[3]].grade then
		self.grade = self.tab_cards[ncards[1]].grade
		return true
	end
	return false
end

function M:isThreeOne( ncards )
	-- 三带一
	if #ncards ~= 4 then return false end
	-- dump(self.tab_cards)
	if self.tab_cards[ncards[1]].grade ~= self.tab_cards[ncards[2]].grade then
		ncards[1], ncards[4] = ncards[4], ncards[1]
	end

	if self.tab_cards[ncards[1]].grade == self.tab_cards[ncards[2]].grade then
		if self.tab_cards[ncards[1]].grade == self.tab_cards[ncards[3]].grade
			and self.tab_cards[ncards[1]].grade ~= self.tab_cards[ncards[4]].grade then
			self.grade = self.tab_cards[ncards[1]].grade
			return true
		end
	else
		return false
	end

	return false
end

function M:isThreeDouble( ncards )
	-- 三带对
	if #ncards ~= 5 then return false end

	if self.tab_cards[ncards[1]].grade ~= self.tab_cards[ncards[3]].grade then
		ncards[1], ncards[4] = ncards[4], ncards[1]
		ncards[2], ncards[5] = ncards[5], ncards[2]
	end

	if self.tab_cards[ncards[1]].grade == self.tab_cards[ncards[2]].grade then
		if self.tab_cards[ncards[1]].grade == self.tab_cards[ncards[3]].grade
			and self.tab_cards[ncards[1]].grade ~= self.tab_cards[ncards[4]].grade
			and self.tab_cards[ncards[4]].grade == self.tab_cards[ncards[5]].grade then

			self.grade = self.tab_cards[ncards[1]].grade
			return true
		end
	else
		return false
	end

	return false
end

function M:isShunZi( ncards )
	-- 顺子
	if #ncards < 5 then return false end

	if self.tab_cards[ncards[1]].grade > 14 then
		return false
	end

	for i=1, #ncards-1 do
		if self.tab_cards[ncards[i]].grade ~= self.tab_cards[ncards[i+1]].grade+1 then
			return false
		end
	end
	self.grade = self.tab_cards[ncards[1]].grade
	return true
end

function M:isDoubleShunZi( ncards )
	-- 连对
	if #ncards < 6 then return false end
	if #ncards%2 == 1 then return false end  

	if self.tab_cards[ncards[1]].grade > 14 then
		return false
	end

	for i=0,#ncards/2-1 do
		if self.tab_cards[ncards[i*2+1]].grade ~= self.tab_cards[ncards[i*2+2]].grade then
			return false
		end
		if i < #ncards/2-1
			and self.tab_cards[ncards[(i+1)*2]].grade ~= self.tab_cards[ncards[(i+2)*2]].grade+1 then
			return false
		end
	end
	self.grade = self.tab_cards[ncards[1]].grade
	return true
end

function M:isFeiJi( ncards )
	-- 飞机不带
	if #ncards < 6 then return false end
	if #ncards%3 == 1 then return false end

	if self.tab_cards[ncards[1]].grade > 14 then
		return false
	end

	for i=0,#ncards/3-1 do
		if self.tab_cards[ncards[i*3+1]].grade ~= self.tab_cards[ncards[i*3+3]].grade then
			return false
		end
		if i < #ncards/3-1
			and self.tab_cards[ncards[(i+1)*3]].grade ~= self.tab_cards[ncards[(i+2)*3]].grade+1 then
			return false
		end
	end
	self.grade = self.tab_cards[ncards[1]].grade

	return true
end

function M:isFeiJiOne( ncards )
	-- 飞机带单张
	if #ncards < 8 then return false end
	if #ncards%4 ~= 0 then return false end

	local grade_counts = self:getGradeCounts(ncards)

	local hand_count = 0
	local grades = {}
	for k,v in pairs(grade_counts) do
		if v.count >= 3 then
			hand_count = hand_count+1
			table.insert(grades, k)
		end
	end
	table.sort(grades, function( a, b )
		return a < b
	end)
	-- dump(grades, "grades")
	if hand_count >= 2 then
		for i=1,#grades-1 do
			if grades[i] ~= grades[i+1]-1 then
				return false
			end
		end
		self.grade = grades[#grades]
		return true
	end
	return false
end

function M:isFeiJiDouble( ncards )
	-- 飞机带对
	if #ncards < 10 then return false end
	if #ncards%5 ~= 0 then return false end

	local grade_counts = self:getGradeCounts(ncards)
	local three_count = 0
	local two_count = 0
	local grade = 0
	for k,v in pairs(grade_counts) do
		if v.count == 3 then
			three_count = three_count+1
			if k > grade then grade = k end
		elseif v.count == 2 then
			two_count = two_count+1
		end
	end
	if three_count > 2 
		and three_count == two_count then
		self.grade = grade
		return true
	end

	return false
end

function M:isFourBouble( ncards )
	-- 四带二
	if #ncards ~= 6 then return false end
	local grade_counts = self:getGradeCounts(ncards)
	for k,v in pairs(grade_counts) do
		if v.count == 4 then
			self.grade = k
			return true
		end
	end
	return false
end

function M:isFourFour( ncards )
	-- 四带两对
	if #ncards ~= 8 then return false end
	local grade_counts = self:getGradeCounts(ncards)
	local bright = false
	for k,v in pairs(grade_counts) do
		if v.count == 4 then
			self.grade = k
			bright = true
		elseif v.count ~= 2 then
			return false
		end
	end
	return bright
end

function M:isBomb( ncards )
	-- 炸弹
	if #ncards ~= 4 then return false end

	for i=1,3 do
		if self.tab_cards[ncards[i]].grade ~= self.tab_cards[ncards[i+1]].grade then
			return false
		end
	end
	self.grade = self.tab_cards[ncards[1]].grade
	return true
end

function M:isBombKing( ncards )
	-- 火箭
	if #ncards == 2
		and self.tab_cards[ncards[1]].color == 4
		and self.tab_cards[ncards[2]].color == 4 then
		self.grade = self.tab_cards[ncards[1]].grade
		return true
	end
	return false
end

function M:getCardType( ncards )
	-- 获取牌型
	ncards = ncards or {}
	self:sortByGrade(ncards)
	self:setCardItems(ncards)
	local temp_ncards = table.values(ncards)
	local ncard_count = #temp_ncards
	self.grade = 0

	if ncard_count == 1 then
		if self:isOne(temp_ncards) then
			return self.config.CT_SINGLE, self.grade
		end
	elseif ncard_count == 2 then
		if self:isBombKing(temp_ncards) then
			return self.config.CT_BOMB_KING, self.grade
		elseif self:isDouble(temp_ncards) then
			return self.config.CT_DOUBLE, self.grade
		end
	elseif ncard_count == 3 then
		if self:isThree(temp_ncards) then
			return self.config.CT_THREE, self.grade
		end
	elseif ncard_count == 4 then
		if self:isBomb(temp_ncards) then
			return self.config.CT_BOMB, self.grade
		elseif self:isThreeOne(temp_ncards) then
			return self.config.CT_THREE_ONE, self.grade
		end
	elseif ncard_count == 5 then
		if self:isShunZi(temp_ncards) then
			return self.config.CT_SHUN_ZI, self.grade
		elseif self:isThreeDouble(temp_ncards) then
			return self.config.CT_THREE_DOUBLE, self.grade
		end
	elseif ncard_count == 7 or ncard_count == 11 then
		if self:isShunZi(temp_ncards) then
			return self.config.CT_SHUN_ZI, self.grade
		end
	elseif ncard_count == 14 then
		if self:isDoubleShunZi(temp_ncards) then
			return self.config.CT_SHUN_ZI_DOUBLE, self.grade
		end
	elseif ncard_count == 15 then
		if self:isFeiJiDouble(temp_ncards) then
			return self.config.CT_FEIJI_DOUBLE, self.grade
		end
	else
		if self:isShunZi(temp_ncards) then
			return self.config.CT_SHUN_ZI, self.grade
		elseif self:isFeiJi(temp_ncards) then
			return self.config.CT_FEIJI, self.grade
		elseif self:isFourBouble(temp_ncards) then
			return self.config.CT_FOUR_DOUBLE, self.grade
		elseif self:isDoubleShunZi(temp_ncards) then
			return self.config.CT_SHUN_ZI_DOUBLE, self.grade
		elseif self:isFeiJiOne(temp_ncards) then
			return self.config.CT_FEIJI_ONE, self.grade
		elseif self:isFeiJiDouble(temp_ncards) then
			return self.config.CT_FEIJI_DOUBLE, self.grade
		elseif self:isFourFour(temp_ncards) then
			return self.config.CT_FOUR_FOUR, self.grade
		end
	end

	return self.config.CT_ERROR, self.grade
end

function M:check( precards, curcards )
	-- body
	local curtype, crugrade = self:getCardType(curcards)
	log("check curtype:"..curtype)
	if curtype == self.config.CT_ERROR then
		return false
	end
	if precards == nil then
		return true
	else
		local pretype, pregrade = self:getCardType(precards)
		if curtype == self.config.CT_BOMB_KING then
			return true
		elseif curtype == self.config.CT_BOMB then
			if pretype == self.config.CT_BOMB_KING then
				return false
			elseif pretype == self.config.CT_BOMB  then
				if crugrade > pregrade then
					return true
				else
					return false
				end
			else
				return true
			end
		elseif curtype ~= pretype then
			return false
		elseif #precards ~= #curcards then
			return false
		else
			if crugrade > pregrade then
				return true
			else
				return false
			end
		end
	end
end

return M