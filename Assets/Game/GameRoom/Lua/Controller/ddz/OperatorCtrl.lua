--
-- Author: jinda.w
-- Date: 2017-09-29 10:51:10
--

local M = class("OperatorCtrl")

function M:ctor(parent)
	-- body
	self.parent = parent
end

-- naction 1:抢地主， 2:加倍， 3：出牌操作, 4.叫地主, 5.准备 6.首轮出牌
function M:show(naction, func)
	-- body
	self.naction = naction
	self.func = func
	if self.obj_two then
		self:showAction()
	else	
		resMgr:LoadPrefab('DdzRoom', {'Button_short_green', 'MasterPanel', 'OperatorPanel' }, function( objs )
			self:showObj(objs)
		end)
	end
end

function M:showObj( objs )
	-- body
	log("show prefab:"..objs[0].name)
	log("show prefab:"..objs[1].name)
	log("show prefab:"..objs[2].name)
	
	self.tab_buttons = {}
	
	self.obj_one = newObject(objs[0])
	self.transform_one = self.obj_one.transform
	self.transform_one:SetParent(self.parent)
	self.transform_one.localScale = Vector3.one
	self.transform_one.anchoredPosition = Vector3.New(0, -40)
	table.insert(self.tab_buttons, self.obj_one)

	self.obj_two = newObject(objs[1])
	self.transform_two = self.obj_two.transform
	self.transform_two:SetParent(self.parent)
	self.transform_two.localScale = Vector3.one
	self.transform_two.anchoredPosition = Vector3.New(-105, -40)
	local button_1 = self.transform_two:Find("Button_short_green").gameObject
	local button_2 = self.transform_two:Find("Button_short_orange").gameObject
	table.insert(self.tab_buttons, button_1)
	table.insert(self.tab_buttons, button_2)

	self.obj_three = newObject(objs[2])
	self.transform_three = self.obj_three.transform
	self.transform_three:SetParent(self.parent)
	self.transform_three.localScale = Vector3.one
	self.transform_three.anchoredPosition = Vector3.New(0, -40)

	local button_1 = self.transform_three:Find("Button_outcard").gameObject
	local button_2 = self.transform_three:Find("Button_tips").gameObject
	local button_3 = self.transform_three:Find("Button_pass").gameObject
	table.insert(self.tab_buttons, button_1)
	table.insert(self.tab_buttons, button_2)
	table.insert(self.tab_buttons, button_3)

	self.obj_one:SetActive(false)
	self.obj_two:SetActive(false)
	self.obj_three:SetActive(false)
	self:showAction()

	self.lua_behaviour = self.parent:GetComponent("LuaBehaviour")

	for k,v in pairs(self.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			if self.func then
				self.func(obj.name)
			end
		end)
	end
end

function M:showAction()
	-- body
	if self.naction == 1 then
		self.obj_two:SetActive(true)
		self:setRequestMaster()
	elseif self.naction == 2 then
		self.obj_two:SetActive(true)
		self:setAddBouble()
	elseif self.naction == 3 then
		self.obj_three:SetActive(true)
		self:setOperator()
	elseif self.naction == 4 then
		self.obj_two:SetActive(true)
		self:setRobMaster()
	elseif self.naction == 5 then
		self.obj_one:SetActive(true)
		self:setReady()
	elseif self.naction == 6 then
		self.obj_two:SetActive(true)
		self:setOutCard()
	end
end

function M:hideAction(action)
	-- body
	if action == nil then
		self.obj_one:SetActive(false)
		self.obj_two:SetActive(false)
		self.obj_three:SetActive(false)
		return
	end
	if self.naction == 1 
		or self.naction == 2 
		or self.naction == 4
		or self.naction == 6 then
		self.obj_two:SetActive(false)
	elseif self.naction == 3 then
		self.obj_three:SetActive(false)
	elseif self.naction == 5 then
		self.obj_one:SetActive(false)
	end
end

function M:setReady()
	-- body
	log("setReady")
	self.tab_buttons[1].name = "ready"
	local text_ready = self.transform_one:Find("Text"):GetComponent('Text')
	text_ready.text = "准 备"
end

function M:setRequestMaster()
	-- body
	self.tab_buttons[2].name = "master"
	self.tab_buttons[3].name = "pass"
	local text_master = self.transform_two:Find("master/Text"):GetComponent('Text')
	text_master.text = "叫地主"
	local text_pass = self.transform_two:Find("pass/Text"):GetComponent('Text')
	text_pass.text = "不 叫"
end

function M:setRobMaster()
	-- body
	self.tab_buttons[2].name = "master"
	self.tab_buttons[3].name = "pass"
	local text_master = self.transform_two:Find("master/Text"):GetComponent('Text')
	text_master.text = "抢地主"
	local text_pass = self.transform_two:Find("pass/Text"):GetComponent('Text')
	text_pass.text = "不 抢"
end

function M:setOutCard()
	-- body
	self.tab_buttons[2].name = "outcard"
	self.tab_buttons[3].name = "tips"
	local text_master = self.transform_two:Find("outcard/Text"):GetComponent('Text')
	text_master.text = "出 牌"
	local text_pass = self.transform_two:Find("tips/Text"):GetComponent('Text')
	text_pass.text = "提 示"
end

function M:setAddBouble()
	-- body
	self.tab_buttons[2].name = "double"
	self.tab_buttons[3].name = "pass"
	local text_master = self.transform_two:Find("double/Text"):GetComponent('Text')
	text_master.text = "加 倍"
	local text_pass = self.transform_two:Find("pass/Text"):GetComponent('Text')
	text_pass.text = "不加倍"
end

function M:setOperator()
	-- body
	self.tab_buttons[4].name = "outcard"
	self.tab_buttons[5].name = "tips"
	self.tab_buttons[6].name = "pass"
	
	local text_pass = self.transform_three:Find("pass/Text"):GetComponent('Text')
	text_pass.text = "不 出"
	local text_tips = self.transform_three:Find("tips/Text"):GetComponent('Text')
	text_tips.text = "提 示"
	local text_outcard = self.transform_three:Find("outcard/Text"):GetComponent('Text')
	text_outcard.text = "出 牌"
end

return M