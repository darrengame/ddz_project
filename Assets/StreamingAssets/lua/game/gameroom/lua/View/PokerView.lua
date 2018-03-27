--
-- Author: jinda.w
-- Date: 2017-09-13 19:04:40
--

local M = class("PokerView")

function M:ctor( game_object, transform )
	-- body
	log("PokerView")
	self.game_object = game_object
	self.transform = transform

	self:initPanel()

	return self
end

function M:initPanel()
	-- body
	self.uimge_card = self.game_object:GetComponent('Image')

	self.uimge_top_num = self.transform:Find("Image_top_num"):GetComponent('Image')
	self.uimge_top_icon = self.transform:Find("Image_top_icon"):GetComponent('Image')
	self.uimge_bottom_num = self.transform:Find("Image_bottom_num"):GetComponent('Image')
	self.uimge_bottom_icon = self.transform:Find("Image_bottom_icon"):GetComponent('Image')
	self.uimge_joker_num = self.transform:Find("Image_joker"):GetComponent('Image')
	
	self.obj_top_num = self.transform:Find("Image_top_num").gameObject
	self.obj_top_icon = self.transform:Find("Image_top_icon").gameObject
	self.obj_bottom_num = self.transform:Find("Image_bottom_num").gameObject
	self.obj_bottom_icon = self.transform:Find("Image_bottom_icon").gameObject
	self.obj_joker_num = self.transform:Find("Image_joker").gameObject
end

function M:setData( image_name_card, image_name_color, ncolor, bjoker )
	-- body
	if bjoker then
		--大小王
		self.obj_top_num:SetActive(false)
		self.obj_top_icon:SetActive(false)
		self.obj_bottom_num:SetActive(false)
		self.obj_bottom_icon:SetActive(false)
		self.obj_joker_num:SetActive(true)
		resMgr:LoadSprite("poker_asset", {image_name_card}, function(objs)
			self.uimge_joker_num.sprite = objs[0]
		end)
	else
		resMgr:LoadSprite("poker_asset", {image_name_card, image_name_color}, function(objs)
			-- body
			self.uimge_top_num.sprite = objs[0]
			self.uimge_top_icon.sprite = objs[1]
			self.uimge_bottom_num.sprite = objs[0]
			self.uimge_bottom_icon.sprite = objs[1]
		end)
		if ncolor == 0 or ncolor == 2 then
			self.uimge_top_num.color = Color.red
			self.uimge_bottom_num.color = Color.red
		else
			self.uimge_top_num.color = Color.black
			self.uimge_bottom_num.color = Color.black
		end
	end
end

function M:setBackgroud(image_name_card)
	self.obj_top_num:SetActive(false)
	self.obj_top_icon:SetActive(false)
	self.obj_bottom_num:SetActive(false)
	self.obj_bottom_icon:SetActive(false)
	self.obj_joker_num:SetActive(false)
	resMgr:LoadSprite("poker_asset", {image_name_card}, function(objs)
		self.uimge_card.sprite = objs[0]
	end)
end

return M
