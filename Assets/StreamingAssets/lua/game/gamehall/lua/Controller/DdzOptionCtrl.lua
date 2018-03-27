-- 斗地主选项
-- Author: jinda.w
-- Date: 2017-11-24 16:18:44
--

local M = class("DdzOptionCtrl")

function M:ctor(game_object, transform)
	-- body
	self.game_object = game_object
	self.transform = transform
	-- self.option = {game_num = 4, pay_type = 1, play_type = 1, multiple = 256}
	self.option = {4,1,1,256}
end

function M:getOption()
	-- body
	return self.option
end

-- {id=1, name="斗地主", game_num={{num=8, rmb=2}, {num=16, rmb=4}}, 
	-- rmb_aa=1, game_type=0, ip="127.0.0.1", port=9001, multiple={64, 128, 256}}
function M:setOption( data )
	-- body
	self.data = data
	self.game_num_index = 1
	self.pay_type_index = 1
	self.play_type_index = 1
	self.multiple_index = 3
	local toggles = {}

	local game_num = self.transform:Find("Viewport/Content/single_select_1")
	for k,v in pairs(data.game_num) do
		local label = game_num:Find(string.format("game_num_%d/Label", k)):GetComponent("Text")
		if v.rmb <= 0 then
			label.text = string.format("%d局(免费)", v.num)
		else
			label.text = string.format("%d局(钻石x%d)", v.num, v.rmb)
		end
		if k == self.game_num_index then
			local toggle = game_num:Find("game_num_"..k):GetComponent(typeof(Toggle))
			toggle.isOn = true
		end
		local obj = game_num:Find(string.format("game_num_%d", k)).gameObject
		table.insert(toggles, obj)
	end

	local pay_type = self.transform:Find("Viewport/Content/single_select_2")
	local toggle = pay_type:Find("pay_type_"..self.pay_type_index):GetComponent(typeof(Toggle))
	toggle.isOn = true
	for i=1,2 do
		local obj = pay_type:Find(string.format("pay_type_%d", i)).gameObject
		table.insert(toggles, obj)
	end

	local play_type = self.transform:Find("Viewport/Content/single_select_3")
	local toggle = play_type:Find("play_type_"..self.play_type_index):GetComponent(typeof(Toggle))
	toggle.isOn = true
	for i=1,2 do
		local obj = play_type:Find(string.format("play_type_%d", i)).gameObject
		table.insert(toggles, obj)
	end

	local multiple = self.transform:Find("Viewport/Content/single_select_4")
	for k,v in pairs(data.multiple) do
		local label = multiple:Find(string.format("multiple_%d/Label", k)):GetComponent("Text")
		label.text = string.format("%d分", v)
		if k == self.multiple_index then
			local toggle = multiple:Find("multiple_"..k):GetComponent(typeof(Toggle))
			toggle.isOn = true
		end
		local obj = multiple:Find(string.format("multiple_%d", k)).gameObject
		table.insert(toggles, obj)
	end

	-- dump(toggles, "toggles")
	local luabehaviour = self.transform.parent:GetComponent("LuaBehaviour")
	for k,v in pairs(toggles) do
		luabehaviour:AddToggleClick(v, function( obj, bcheck )
			self:onBtnCallback(obj, bcheck)
		end)
	end

	self:selectGameNum(self.game_num_index)
	self:selectPayType(self.pay_type_index)
	self:selectPlayType(self.play_type_index)
	self:selectMultiple(self.multiple_index)
end

function M:onBtnCallback(obj, bcheck)
	-- body
	local name = obj.name
	log("onclick:"..name)
	if name == "game_num_1" then
		--todo
		self:selectGameNum(1)
	elseif name == "game_num_2" and bcheck then
		self:selectGameNum(2)
	elseif name == "pay_type_1" and bcheck then
		self:selectPayType(1)
	elseif name == "pay_type_2" and bcheck then
		self:selectPayType(2)
	elseif name == "play_type_1" and bcheck then
		self:selectPlayType(1)
	elseif name == "play_type_2" and bcheck then
		self:selectPlayType(2)
	elseif name == "multiple_1" and bcheck then
		self:selectMultiple(1)
	elseif name == "multiple_2" and bcheck then
		self:selectMultiple(2)
	elseif name == "multiple_3" and bcheck then
		self:selectMultiple(3)
	end
end

function M:selectGameNum( select_index )
	-- 局数
	self.option[1] = self.data.game_num[select_index].num
end

function M:selectPayType( select_index )
	-- 支付方式
	self.option[2] = select_index
end

function M:selectPlayType( select_index )
	-- 玩法
	self.option[3] = select_index
end

function M:selectMultiple( select_index )
	-- 倍数
	self.option[4] = self.data.multiple[select_index]
end

return M