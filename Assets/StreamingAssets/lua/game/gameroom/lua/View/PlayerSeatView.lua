--
-- Author: jinda.w
-- Date: 2017-09-13 19:04:40
--
local M = class("PlayerSeatView")

function M:ctor( game_object, transform )
	-- body
	self.game_object = game_object
	self.transform = transform

	self:initView()
end

function M:initView()
	-- body
	self.btn_avatar = self.transform:Find("Button_avatar").gameObject
	self.obj_frame = self.transform:Find("Button_avatar/Image_frame").gameObject
	self.text_name = self.transform:Find("PlayerseatInfo/Text_name"):GetComponent('Text')
	self.obj_name = self.transform:Find("PlayerseatInfo/Text_name").gameObject
	self.text_diamond = self.transform:Find("PlayerseatInfo/Text_coin"):GetComponent('Text')
	self.obj_diamond = self.transform:Find("PlayerseatInfo/Text_coin").gameObject
	self.obj_diamondicon = self.transform:Find("PlayerseatInfo/Image_icon").gameObject
	self.obj_banker = self.transform:Find("PlayerseatInfo/Image_banker").gameObject
	self.obj_icon = self.transform:Find("PlayerseatInfo/Image_banker").gameObject

	self.tab_buttons = {self.btn_avatar}
end

function M:setPlayerName( name )
	-- body
	self.text_name.text = name
end

function M:setPlayerDiamond( ndiamond )
	-- body
	self.text_diamond.text = ndiamond
end

function M:setPlayerMaster( bmaster )
	-- body
	self.obj_banker:SetActive(bmaster)
end

function M:setPlayerAvatar( sprite )
	-- body
	-- self.btn_avatar.sprite = sprite
	-- self.obj_banker:SetActive(true)
end

function M:showPlayerInfo()
	-- body
	self.obj_frame:SetActive(true)
	self.obj_name:SetActive(true)
	self.obj_diamond:SetActive(true)
	self.obj_diamondicon:SetActive(true)
	self.obj_icon:SetActive(true)
end

function M:resetPlayerInfo()
	-- body
	self.obj_frame:SetActive(false)
	self.obj_name:SetActive(false)
	self.obj_diamond:SetActive(false)
	self.obj_diamondicon:SetActive(false)
	self.obj_banker:SetActive(false)
	self.obj_icon:SetActive(false)
end

return M
