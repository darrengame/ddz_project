-- 斗地主提示
-- Author: jinda.w
-- Date: 2017-11-16 19:42:00
--

local DdzRule = require("Model.ddz.DdzRules")

local M = class("DdzPromt", DdzRule)

function M:create(config)
	-- body
	self:ctor(config)
	return self
end

function M:promt( ncards, outcards )
	-- 提示
	assert("table" == type(ncards), "promt ncards must be table")
	-- assert("table" == type(outcards), "promt outcards must be table")

	self.promt_cards = {}
	self.out_type, self.out_grade = self:getCardType(outcards)
	self:anlyzeCard(ncards)
	if outcards == nil or 
		(outcards and #outcard == 0) then
		self:anlyzeMinCard(ncards)
		return self.promt_cards
	end

	self.out_count = #outcards
	log("out_count:"..self.out_count)
	if self.out_type == self.config.CT_ERROR
		or self.out_type == self.config.CT_BOMB_KING then
		return self.promt_cards
	end

	if self.out_type == self.config.CT_SINGLE then
		self:anlyzeOne()
	elseif self.out_type == self.config.CT_DOUBLE then
		self:anlyzeDouble()
	elseif self.out_type == self.config.CT_THREE then
		self:anlyzeThree()
	elseif self.out_type == self.config.CT_THREE_ONE then
		self:anlyzeThreeOne()
	elseif self.out_type == self.config.CT_THREE_DOUBLE then
		self:anlyzeThreeDouble()
	elseif self.out_type == self.config.CT_SHUN_ZI then
		self:anlyzeShunZi()
	elseif self.out_type == self.config.CT_SHUN_ZI_DOUBLE then
		self:anlyzeDoubleShunZi()
	elseif self.out_type == self.config.CT_FOUR_FOUR then
		self:anlyzeFourFour()
	elseif self.out_type == self.config.CT_FEIJI then
		self:anlyzeFeiJi()
	elseif self.out_type == self.config.CT_FEIJI_ONE then
		self:anlyzeFeiJiOne()
	elseif self.out_type == self.config.CT_FEIJI_DOUBLE then
		self:anlyzeFeiJiDouble()
	elseif self.out_type == self.config.CT_FOUR_DOUBLE then
		self:anlyzeFourDouble()
	end
	self:anlyzeBomb()
	self:anlyzeBombKing()

	return self.promt_cards
end

function M:anlyzeMinCard(ncards)
	-- body
	table.insert(self.promt_cards, ncards[#ncards])
end

function M:anlyzeCard( ncards )
	-- body
	self._ncards = self:sortByGrade(ncards)
	self.card_datas = {}

	local nstart, nround, nnext = 0, 0, 1
	while nnext <= #ncards do
		local i = 1
		nstart = nnext
		while nnext < #ncards 
			and self:getGrade(ncards[nnext]) == self:getGrade(ncards[nnext+1]) do
			i = i+1
			nnext = nnext+1
		end
		nround = nround+1
		nnext = nnext+1
		self.card_datas[nround] = 
		{
			count = i,
			index = nstart,
			grade = self:getGrade(ncards[nstart]),
			nCardValue = ncards[nstart]
		}
	end

	table.sort(self.card_datas, function( a, b )
		return a.grade > b.grade
	end)
end

function M:reverse( datas )
	local datas = datas or {}
	local len = #datas
	for i=1,math.floor(len/2) do
		datas[i], datas[len-i-1] = datas[len-i-1], datas[i]
	end
end

function M:anlyzeSame(count)
	-- 相同张数
	local cards = {}
	for k,v in pairs(self.card_datas) do
		if v.grade > self.out_grade
		 and v.count == count then
		 	local indexs = {}
		 	for i=1, count do
		 		table.insert(indexs, v.index+i-1)
		 	end
			local card = {count=v.count, indexs=indexs}
			table.insert(cards, card)
		end
	end
	return cards
end

function M:anlyzeLink(count_type)
	-- count_type:1:连续单张，2：连续二张，3：连续三张
	log("cout_type:"..count_type)
	local cards = {}
	for i=1, #self.card_datas do
		if self.card_datas[i].grade < 15 
		and self.card_datas[i].grade > self.out_grade 
		and self.card_datas[i].count >= count_type then
			local count = 1
			local indexs = {}
			for k=1,count_type do
				table.insert(indexs, self.card_datas[i].index+k-1)
			end
			for j=i+1,#self.card_datas do
				if self.card_datas[i].grade == self.card_datas[j].grade+(j-i)
				and self.card_datas[j].count >= count_type then
					count = count+1
					for l=1,count_type do
						table.insert(indexs, self.card_datas[j].index+l-1)
					end
					if count == self.out_count then
						local card = {count=count, indexs=indexs}
						table.insert(cards, card)
						break
					end
				end
			end
		end
	end
	dump(cards, "anlyzeLink")
	return cards
end

function M:anlyzeOne()
	-- 单张
	local cards = self:anlyzeSame(1)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeDouble()
	-- 对子
	local cards = self:anlyzeSame(2)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeThree()
	-- 三条
	local cards = self:anlyzeSame(3)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeBomb()
	-- 炸弹
	local cards = self:anlyzeSame(4)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeShunZi()
	-- 顺子
	local cards = self:anlyzeLink(1)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeDoubleShunZi()
	-- 连对
	local cards = self:anlyzeLink(2)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeFeiJi()
	-- 飞机（三连）
	local cards = self:anlyzeLink(3)
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeThreeOne()
	-- 三带一
	for k,v in pairs(self.card_datas) do
		if v.grade > self.out_grade
		 and v.count == 3 then
		 for k_2,v_2 in pairs(self.card_datas) do
		 	if v_2.count == 1 then
			 	local indexs = {}
			 	for i=1, 3 do
			 		table.insert(indexs, v.index+i-1)
			 	end
		 		table.insert(indexs, v_2.index)
				local card = {count=4, indexs=indexs}
				table.insert(self.promt_cards, card)
		 	end
		 end
		end
	end
end

function M:anlyzeThreeDouble()
	-- 三带二
	for k,v in pairs(self.card_datas) do
		if v.grade > self.out_grade
		 and v.count == 3 then
			for k_2,v_2 in pairs(self.card_datas) do
				if v_2.count == 2 then
				 	local indexs = {}
				 	for i=1, 3 do
				 		table.insert(indexs, v.index+i-1)
				 	end
				 	for i=1, 2 do
				 		table.insert(indexs, v_2.index+i-1)
				 	end
					local card = {count=5, indexs=indexs}
					table.insert(self.promt_cards, card)
				end
			end
		end
	end
end

function M:anlyzeFeiJiOne()
	-- 飞机带一
	local cards = self:anlyzeLink(3)
	if #cards > 0 then
		local one_cards = self:anlyzeSame(1)
		local two_cards = self:anlyzeSame(2)
		if #one_cards > 2 then
			self:reverse(one_cards)
			for k,v in pairs(cards) do
				table.merge(v.indexs, one_cards[1].indexs)
				table.merge(v.indexs, one_cards[2].indexs)
			end
		elseif #one_cards == 1 and two_cards > 1 then
			self:reverse(two_cards)
			for k,v in pairs(cards) do
				table.merge(v.indexs, one_cards[1].indexs)
				table.insert(v.indexs, two_cards[1].indexs[1])
			end
		elseif #one_cards == 0 and two_cards > 1 then
			self:reverse(two_cards)
			for k,v in pairs(cards) do
				table.merge(v.indexs, two_cards[1].indexs)
			end
		end
	end
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeFeiJiDouble()
	-- 飞机带对
	local cards = self:anlyzeLink(3)
	if #cards > 0 then
		local two_cards = self:anlyzeSame(2)
		local three_cards = self:anlyzeSame(2)
		if #one_cards > 2 then
			self:reverse(one_cards)
			for k,v in pairs(cards) do
				table.merge(v.indexs, one_cards[1].indexs)
				table.merge(v.indexs, one_cards[2].indexs)
			end
		elseif #one_cards == 1 and two_cards > 1 then
			self:reverse(two_cards)
			for k,v in pairs(cards) do
				table.merge(v.indexs, one_cards[1].indexs)
				table.insert(v.indexs, two_cards[1].indexs[1])
			end
		elseif #one_cards == 0 and two_cards > 1 then
			self:reverse(two_cards)
			for k,v in pairs(cards) do
				table.merge(v.indexs, two_cards[1].indexs)
			end
		end
	end
	for k,v in pairs(cards) do
		table.insert(self.promt_cards, v)
	end
end

function M:anlyzeFourDouble()
	-- 四带二
	local indexs = {}
	for k,v in pairs(self.card_datas) do
		if v.grade > self.out_grade
		and v.count == 4 then
			for k_2,v_2 in pairs(self.card_datas) do
				if v_2.count == 1 then
					for k_3,v_3 in pairs(self.card_datas) do
						if v_3.count == 1 and v_3.index ~= v_2.index then
							for i=1,v.count do
								table.insert(indexs, v.index+i-1)
							end
							table.insert(indexs, v_2.index)
							table.insert(indexs, v_3.index)
						elseif v_3.count >= 2 then
							for i=1,v.count do
								table.insert(indexs, v.index+i-1)
							end
							table.insert(indexs, v_2.index)
							table.insert(indexs, v_3.index)
						end
					end
				elseif v_2.count >= 2 and v_2.count <= 3 then
					for i=1,v.count do
						table.insert(indexs, v.index+i-1)
					end
					table.insert(indexs, v_2.index)
					table.insert(indexs, v_2.index+1)
				end
				if #indexs ~= 0 then
					local card = {count=6, indexs=indexs}
					table.insert(self.promt_cards, card)
				end
			end
		end
	end
end

function M:anlyzeFourFour()
	-- 四带两对
	local indexs = {}
	local nums = #self.card_datas
	for k,v in pairs(self.card_datas) do
		if v.grade > self.out_grade
		and v.count == 4 then
			for i=1,nums-1 do
				if self.card_datas[i].count == 2 then
					for j=i,nums do
						if self.card_datas[j].count == 2 then
							for i=1,v.count do
								table.insert(indexs, v.index+i-1)
							end
							table.insert(indexs, self.card_datas[i].index)
							table.insert(indexs, self.card_datas[i].index+1)
							table.insert(indexs, self.card_datas[j].index)
							table.insert(indexs, self.card_datas[j].index+1)
						end
					end
				end
			end
			if #indexs > 0 then
				local card = {count=8, indexs=indexs}
				table.insert(self.promt_cards, card)
			end
		end
	end
end

function M:anlyzeBombKing()
	-- 王炸
	for k,v in pairs(self.card_datas) do
		if v.grade > 15
		and v.count == 2 then
			local indexs = {v.index, v.index+1}
			local card = {count=2, indexs=indexs}
			table.insert(self.promt_cards, card)
		end
	end
end

return M