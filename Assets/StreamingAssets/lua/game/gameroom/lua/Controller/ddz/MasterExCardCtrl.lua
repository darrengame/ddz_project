--
-- Author: jinda.w
-- Date: 2017-09-29 09:42:59
--

local M = class("MasterExCardCtrl")

function M:ctor(parent)
	-- body
	self.parent = parent
	self.card_poss = 
	{
		Vector3.New(-65, 0),
		Vector3.New(0, 0),
		Vector3.New(65, 0),
	}
end

function M:show( ncards )
	-- body
	self.ncards = ncards
	resMgr:LoadPrefab('DdzRoom', { 'MasterExCard' }, function( objs )
		self:showObj(objs)
	end)
end

function M:showObj( objs )
	-- body
	log("show prefab:"..objs[0].name)
	
	self.game_object = newObject(objs[0])
	log("show obj:"..self.game_object.name)
	self.transform = self.game_object.transform
	self.transform:SetParent(self.parent)
	self.transform.localScale = Vector3.one
	self.transform.anchoredPosition = Vector3.New(0, -40)
	
	self.poker = {}
	local poker_ctrl = require("Controller.PokerCtrl")
	for k,v in pairs(self.ncards) do
		self.poker[k] = poker_ctrl:create()
		self.poker[k]:show(v, function()
			self.poker[k]:setParent(self.transform)
			
			self.poker[k]:setPos(self.card_poss[k])
			self.poker[k]:setScale(Vector3.New(0.4, 0.4))
			self.poker[k]:setName(string.format("poker_%02x", v))
		end)
	end
end

function M:close(bdestroy)
	-- body
	if bdestroy then
		destroy(self.game_object)
	else
		self.game_object:SetActive(false)
	end
end

return M