--
-- Author: jinda.w
-- Date: 2017-09-22 19:40:51
--

local M = class("PlayerManager")

function M:ctor(player_ctrl, parent)
	-- body
	self.player_ctrl = player_ctrl
	self.parent = parent
	self.seat_pos = 
	{
		Vector3.New(-540, -177, 0),
		Vector3.New(540, 100, 0),
		Vector3.New(-540, 100, 0),
	}
	self.status_pos = 
	{
		Vector3.New(0, -50, 0),
		Vector3.New(300, 95, 0),
		Vector3.New(-300, 95, 0),
	}

	self.obj_seat_texts = {}
	return self
end

function M:showSeat(player_num)
	self.player_seat = {}
	for i=1, player_num do
		self.player_seat[i] = self.player_ctrl:create()
		self.player_seat[i]:show()
		self.player_seat[i]:setParent(self.parent)
		self.player_seat[i]:setPos(self.seat_pos[i] or Vector3.zero)
		self.player_seat[i]:setName("player_seat_"..i)
	end
end

function M:showPlayerInfo( local_seatid, data )
	-- body
	if self.player_seat[local_seatid] then
		self.player_seat[local_seatid]:showPlayerInfo()
		self.player_seat[local_seatid]:setPlayerName(data.name)
		self.player_seat[local_seatid]:setPlayerDiamond(data.rmb)
		self.player_seat[local_seatid]:setPlayerAvatar(data.avatar)
	end
end

function M:hidePlaeyrInfo( local_seatid )
	-- body
	if self.player_seat[local_seatid] then
		self.player_seat[local_seatid]:resetPlayerInfo()
	end
end

function M:getObj( name, names, func )
	-- body
	resMgr:LoadPrefab(name, names, func)
end

function M:setSeatActionStatus( local_seatid, bshow, str_status )
	-- body
	str_status = str_status or ""
	if not self.obj_seat_texts[local_seatid] then
		self:getObj('DdzRoom', {'Text_status'}, function( objs )
			self.obj_seat_texts[local_seatid] = newObject(objs[0])
			local transform = self.obj_seat_texts[local_seatid].transform
			transform:SetParent(self.parent)
			transform.localScale = Vector3.one
			transform.localPosition = self.status_pos[local_seatid]
			self.obj_seat_texts[local_seatid].name = "status_"..local_seatid
			
			self.obj_seat_texts[local_seatid]:SetActive(bshow)
			local text_ready = self.obj_seat_texts[local_seatid]:GetComponent('Text')
			text_ready.text = str_status
		end)
	else
		self.obj_seat_texts[local_seatid]:SetActive(bshow)
		local text_ready = self.obj_seat_texts[local_seatid]:GetComponent('Text')
		text_ready.text = str_status
	end

end

function M:setMaster( local_seatid )
	-- body
	self.player_seat[local_seatid]:setPlayerMaster(true)
end

return M