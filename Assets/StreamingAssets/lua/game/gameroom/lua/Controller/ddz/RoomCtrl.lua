--
-- Author: jinda.w
-- Date: 2017-09-13 19:44:39
--

local M = class("RoomCtrl")

function M:ctor(game_manager)
	-- body
	self.game_manager = game_manager

	self.card_pos = 
	{
		Vector3.New(100, -200, 0),
		Vector3.New(250, 200, 0),
		Vector3.New(-250, 200, 0),
	}

	self.out_card_pos = 
	{
		Vector3.New(0, 0, 0),
		Vector3.New(250, 95, 0),
		Vector3.New(-250, 95, 0),
	}
	self.time_pos = 
	{
		Vector3.New(-110, -40, 0),
		Vector3.New(410, 95, 0),
		Vector3.New(-300, 95, 0),
	}
	return self
end

function M:show()
	-- body
	log("RoomCtrl show")
	require("View.ddz.DdzRoomPanel")
	
	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("DdzRoom", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close(bdestroy)
	-- body
	if bdestroy then
		panelMgr:ClosePanel("DdzRoom")
		self.game_object = nil
		self.poker_hand[1]:removeTouch()
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

	for k,v in pairs(DdzRoomPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end

	DdzRoomPanel.setSysTime(os.date("%H:%M", os.time()))

	self:showWifi()

	self:initGame()
end

function M:onBtnCallback(obj)
	-- body
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_back" then
		self:closeRoom()
	elseif name == "Button_auto" then
		-- local overinfo = {}
		-- overinfo.farmerwin  = 2
		-- overinfo.master_seatid  = 1
		-- overinfo.seatid  = 1
		-- overinfo.game_score = {
		-- 	{name="111", minscore=10, mutiple=20, score=1000},
		-- 	{name="222", minscore=10, mutiple=20, score=1000},
		-- 	{name="333", minscore=10, mutiple=20, score=1000},}
		-- overinfo.user_cards = {}
		-- self:gameOver(overinfo, function()
		-- 	self:closeRoom()
		-- end)
		self.time:resume()
	elseif name == "Button_set" then
		-- HallManager:showPanel("set")
		self.time:pause()
	elseif name == "Button_playtype" then
		--todo
		self.time:start(math.random(10, 50))
	end
end

function M:showWifi()
	-- 网络信号
	local offest_time = self.game_manager:getPingTime()
	local sinal_shelves = 4
	if offest_time <= 30 then
		sinal_shelves = 4
	elseif offest_time <= 50 then
		sinal_shelves = 3
	elseif offest_time <= 100 then
		sinal_shelves = 2
	else
		sinal_shelves = 1
	end
	local wifi_name = string.format("wifi_%02d", sinal_shelves)
	DdzRoomPanel.setSign(wifi_name)
end

function M:closeRoom()
	RoomManager:closeConnect()
	RoomManager:closeAllPanel(true)
	self:close(true)
	self.time:close(true)
	self.room_bottom:close(true)
	HallManager:showPanel("hall")
end

function M:initGame()
	-- body
	self.room_bottom        = RoomManager:showPanel("roomBottom")
	self.config             = require("Controller.ddz.config")
	self.time               = require("Controller.TimeCtrl"):create()
	self.pokerctrl          = require("Controller.PokerCtrl")
	self.player_seat_ctrl   = require("Controller.PlayerSeatCtrl")
	self.player_manager     = require("Controller.PlayerManager"):create(self.player_seat_ctrl, self.transform)
	self.master_excard_ctrl = require("Controller.ddz.MasterExCardCtrl"):create(self.transform)
	self.operator_ctrl      = require("Controller.ddz.OperatorCtrl"):create(self.transform)
	self.game_logic         = require("Model.ddz.DdzPromt"):create(self.config)
	
	self.poker_hand = {}
	self.poker_out  = {}

	for i=1, #self.card_pos do
		if i == 1 then
			self.poker_hand[i] = require("Controller.PokerHandCtrl"):create(self.pokerctrl, self.transform, "hand_card_"..i)
			self.poker_hand[i]:addTouch()
		else
			self.poker_hand[i] = require("Model.PokerHandModel"):create(self.pokerctrl, self.transform, "hand_card_"..i)
			self.poker_hand[i]:setMode(2)
		end
		self.poker_hand[i]:setPos(self.card_pos[i])

		-- local cards = {0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,  -- 方块 A - K
		-- 			0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D, -- 梅花 A - K
		-- 			0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D, -- 红桃 A - K
		-- 			0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D, -- 黑桃 A - K
		-- 			0x41,0x42,}	-- 小王，大王
		-- -- shuffle(cards) 		--洗牌
		-- for i=1,#cards do
		-- 	local r = math.random(1,54)
		-- 	local t = cards[i]
		-- 	cards[i] = cards[r]
		-- 	cards[r] = t 
		-- end
		-- local ncards = {}
		-- ncards[1] = {0x12,0x13,0x14}
		-- ncards[2] = {}
		-- ncards[3] = {}
		-- for i=1,51 do 	--发牌51张
		-- 	table.insert(ncards[(i-1)%3+1], cards[i])
		-- end
		-- self.game_logic:sortByGrade(ncards[1])
		-- self.poker_hand[i]:show(ncards[1])

		-- self.poker_hand[i]:sort(self.game_logic)
		if i ~= 1 then
			self.poker_hand[i]:setScale(Vector3.New(0.35, 0.35, 0.35))
		end

		self.poker_out[i] = require("Model.PokerHandModel"):create(self.pokerctrl, self.transform, "out_card_"..i)
		self.poker_out[i]:setPos(self.out_card_pos[i])
		self.poker_out[i]:setScale(Vector3.New(0.5, 0.5, 0.5))
		-- self.poker_out[i]:show({0x01,0x02,0x13,0x14,0x25,0x26})
	end

	self.player_manager:showSeat(3)
	self.promt_index = 0
	self.promt_cards = {}

	-- self.operator_ctrl:show(5)
	-- self.operator_ctrl:show(1)
	-- self.operator_ctrl:show(3)

	-- self.master_excard_ctrl:show({0x01,0x02,0x13})

	-- self.time:show(self.time_pos[1], 30)
	-- self.time:start(30)

	-- self.operator_ctrl:show(3, function( name )
	-- 	local str_cards = string.char(0)
	-- 	local bcheck = false
	-- 	self.ncards = ncards
	-- 	if name == "outcard" then
	-- 		self.ncards = self.poker_hand[1]:getSelectCards()
	-- 		dump(self.ncards)
	-- 		bcheck = self.game_logic:check(outcards, self.ncards)
	-- 		if (not bcheck) then
	-- 			self.poker_hand[1]:resetAllSelect()
	-- 		end
	-- 		str_cards = string.char(unpack(self.ncards))
	-- 	elseif name == "tips" then
	-- 		local group_cards = {{3}, {3,3}, {3,3,4,4,5,5}, {3,3,3,4,4,4,5,5,5}, {3,4,5,6,7},
	-- 			{13,3,4,5,6,7,8,9,10,11,12,1}, {3,3,3,3}, {3,3,3,3,1,1}, {3,3,3,3,4,4,4,4}, {3,4,5,6,7,8,9},
	-- 			{3,3,3,4,4,4,5,5,5}, {3,3,3,1,4,4,4,2,5,5,5,7}, {3,3,3,1,1,4,4,4,2,2,5,5,5,7,7},
	-- 			{3,3,3}, {3,3,3,4}, {3,3,3,4,4}, {3,3,3,3,4,4,5,5}
	-- 		}
	-- 		local out_cards = group_cards[math.random(1, #group_cards)]
	-- 		self.poker_out[2]:clearAll()
	-- 		self.poker_out[2]:show(out_cards)
	-- 		local promt_cards = {}
	-- 		if self.promt_index == 0 then
	-- 			--todo
	-- 			local hand_cards = self.poker_hand[1]:getHandCards()
	-- 			promt_cards = self.game_logic:promt(hand_cards, out_cards)
	-- 		end
	-- 		dump(promt_cards, "promt_cards", 10)
	-- 		if #promt_cards > 0 then
	-- 			-- self.promt_index = 1
	-- 			if self.promt_index >= #promt_cards then
	-- 				self.promt_index = 1
	-- 			else
	-- 				self.promt_index = self.promt_index+1
	-- 			end

	-- 			for k,v in pairs(promt_cards[self.promt_index].indexs) do
	-- 				local card_item = self.poker_hand[1]:selectByIndex(v)
	-- 				if card_item then
	-- 					self.poker_hand[1]:selectCard(card_item)
	-- 				end
	-- 			end
	-- 		end
	-- 	elseif name == "pass" then
	-- 		self.poker_hand[1]:resetAllSelect()
	-- 		bcheck = true
	-- 	end
	-- 	if bcheck then
	-- 		self.poker_hand[1]:remove(self.ncards)
	-- 		self.poker_out[1]:show(self.ncards)
	-- 		-- self.game_manager:send("command", {cmd="play", cards=str_cards})
	-- 	end
	-- end)
end

function M:getLocalSeatid( seatid, player_num )
	player_num = player_num or 3
	local temp = seatid - self.seatid
	local id = (temp + player_num * 3) % player_num
	local local_seatid = id + 1
	return local_seatid
end

function M:roomInfo( data )
	-- body
	log(string.format("roomInfo player num:%d", #data.player_info))
	self.seatid = data.seatid
	for i,v in ipairs(data.player_info) do
		local local_seatid = self:getLocalSeatid(v.seatid)
		self.player_manager:showPlayerInfo(local_seatid, v)
	end
	if #data.player_info == 3 then
		self.operator_ctrl:show(5, function( name )
			-- 准备
			self.game_manager:send("command", {cmd="ready", ready="1"})
		end)
	end
	DdzRoomPanel.setRoomInfo(data.info[1], data.room_number)
end

function M:joinRoom( data, player_num )
	-- body
	-- dump(data, "joinRoom")
	local local_seatid = self:getLocalSeatid(data.seatid)
	self.player_manager:showPlayerInfo(local_seatid, data)

	if player_num == 3 then
		self.operator_ctrl:show(5, function( name )
			-- 准备
			self.game_manager:send("command", {cmd="ready", ready="1"})
		end)
	end
end

function M:leftRoom( data )
	-- body
	local local_seatid = self:getLocalSeatid(data.seatid)
	self.player_manager:hidePlaeyrInfo(local_seatid)
end

function M:userReady( data )
	-- body
	log("userReady")
	if data.seatid == self.seatid then
		self.operator_ctrl:hideAction()
	end
	
	local local_seatid = self:getLocalSeatid(data.seatid)
	self.player_manager:setSeatActionStatus(local_seatid, true, "准 备")
end

function M:heartbeat( data )
	-- body
end

function M:reqMaster( data )
	-- body

	if data.cards then
		self:clearTable()
		-- 发牌
		local mycards = {string.byte(data.cards, 1, -1)}
		self.game_logic:sortByGrade(mycards)
		self.poker_hand[1]:show(mycards)

		local othre_cards = {1,1,1,1,1,1,1,1,1,1,1,1,1}
		for i=2,3 do
			self.poker_hand[i]:show(othre_cards)
		end
	end

	local local_nextid = self:getLocalSeatid(data.next_seatid)
	local naction = 1
	if data.seatid then
		local local_seatid = self:getLocalSeatid(data.seatid)
		local action_status = (data.rate > 0 and "叫地主") or "不 叫"
		self.player_manager:setSeatActionStatus(local_seatid, true, action_status)
		naction = 4
		self.operator_ctrl:hideAction(naction)
	end

	if data.next_seatid == self.seatid then
		-- 自己叫地主
		self.operator_ctrl:show(naction, function( name )
			local rate = (name == "master" and 1) or 0
			self.game_manager:send("command", {cmd="master", rate=rate})
		end)
	else
		-- 别人叫地主
	end
	self.player_manager:setSeatActionStatus(local_nextid, false)
	self.time:show(self.time_pos[local_nextid], 15)
	self.time:start(15)
end

function M:gameStart( data )
	-- body
	DdzRoomPanel.setRoomInfo(data.remain_gamenum or 0)

	for i=1,3 do
		self.player_manager:setSeatActionStatus(i, false)
	end
	self.operator_ctrl:hideAction(1)

	local local_seatid = self:getLocalSeatid(data.master_seatid)
	self.player_manager:setMaster(local_seatid)
	local excards = {string.byte(data.excards, 1, -1)}
	self.master_excard_ctrl:show(excards)

	if data.master_seatid ~= self.seatid then
		excards = {1,1,1}
	end
	self.poker_hand[local_seatid]:add(excards)
	self.poker_hand[local_seatid]:sort(self.game_logic)

	self:showOperator(data.master_seatid, true)
	self.time:show(self.time_pos[local_seatid], 30)
	self.time:start(30)
end

function M:play( data )
	-- body
	local local_seatid = self:getLocalSeatid(data.seatid)
	local local_nextid = self:getLocalSeatid(data.next_seatid or 0)
	local ncards = {string.byte(data.cards, 1, -1)}
	dump(ncards, "play")
	if ncards[1] ~= 0 then
		self.outseatid = data.seatid
		self.outcards = ncards
		self.game_logic:sortByGrade(self.outcards)
		self.poker_out[local_seatid]:show(self.outcards)

		if data.seatid == self.seatid then
			-- 出牌是自己
			self.poker_hand[local_seatid]:remove(self.outcards)
			self.outcards = nil
			self.promt_index = 0
			self.promt_cards = {}
		else
			local outcard = {}
			for k,v in pairs(self.outcards) do
				table.insert(outcard, 1)
			end
			self.poker_hand[local_seatid]:remove(outcard)
		end
	else
		self.poker_out[local_seatid]:clearAll()
		self.player_manager:setSeatActionStatus(local_seatid, true, "不 出")
	end


	if data.next_seatid == nil then
		self.time:close()
		self.operator_ctrl:hideAction(3)
		return
	end
	
	if self.outseatid == data.next_seatid then
		for i=1,3 do
			self.poker_out[i]:clearAll()
			self.player_manager:setSeatActionStatus(i, false)
		end
	end
	
	self:showOperator(data.next_seatid)
	self.time:show(self.time_pos[local_nextid], 30)
	self.time:start(30)
end

function M:gameOver( data )
	-- body
	log("gameOver")
	local bloser = false
	if data.farmerwin ~= self.seatid then
		bloser = true
	end
	data.bloser = bloser
	require("Controller.ddz.GameOverCtrl"):create():show(data, function(name)
			self:overCallback(name)
		end)
	self.operator_ctrl:show(5, function( name )
			-- 准备
			self.game_manager:send("command", {cmd="ready", ready="1"})
		end)
end

function M:overCallback( name )
	self:clearTable()

	if name == "Button_back" then
		self:closeRoom()
	elseif name == "Button_ming" then
	elseif name == "Button_continue" then
		self.game_manager:send("command", {cmd="ready", ready="1"})
	elseif name == "Button_table" then
	end
end

function M:showOperator(seatid, first)
	-- body
	if seatid == self.seatid then
		-- 到自己
		self.poker_out[1]:clearAll()
		self.player_manager:setSeatActionStatus(1, false)

		local action = (first and 6) or 3
		self.operator_ctrl:show(action, function( name )
			local str_cards = string.char(0)
			local bcheck = false
			if name == "outcard" then
				local ncards = self.poker_hand[1]:getSelectCards()
				dump(ncards)
				bcheck = self.game_logic:check(self.outcards, ncards)
				if (not bcheck) then
					self.poker_hand[1]:resetAllSelect()
				end
				str_cards = string.char(unpack(ncards))
			elseif name == "tips" then
				self.poker_hand[1]:resetAllSelect()
				self:promt(self.outcards)
			elseif name == "pass" then
				self.poker_hand[1]:resetAllSelect()
				bcheck = true
			end
			if bcheck then
				self.game_manager:send("command", {cmd="play", cards=str_cards})
			end
		end)
	else
		-- 到别人
		local local_seatid = self:getLocalSeatid(seatid)
		self.poker_out[local_seatid]:clearAll()
		self.player_manager:setSeatActionStatus(local_seatid, false)
		self.operator_ctrl:hideAction(3)
	end
end

function M:promt( out_cards )
	
	if self.promt_index == 0 then
		log("promt_index:"..self.promt_index)
		local hand_cards = self.poker_hand[1]:getHandCards()
		self.promt_cards = self.game_logic:promt(hand_cards, out_cards)
	end
	dump(self.promt_cards, "promt_cards", 10)
	if #self.promt_cards > 0 then
		-- self.promt_index = 1
		if self.promt_index >= #self.promt_cards then
			self.promt_index = 1
		else
			self.promt_index = self.promt_index+1
		end

		for k,v in pairs(self.promt_cards[self.promt_index].indexs) do
			local card_item = self.poker_hand[1]:selectByIndex(v)
			if card_item then
				self.poker_hand[1]:selectCard(card_item)
			end
		end
	end
end

function M:clearTable()
	-- body
	for i=1,3 do
		self.poker_out[i]:clearAll()
		self.poker_hand[i]:clearAll()
		self.player_manager:setSeatActionStatus(i, false)
	end

	self.operator_ctrl:hideAction()
	self.promt_index = 0
	self.promt_cards = {}
end

return M