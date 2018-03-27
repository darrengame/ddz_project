--
-- Author: jinda.w
-- Date: 2017-09-13 19:04:40
--

DdzRoomPanel = {}
local self = DdzRoomPanel

local transform, game_object

function DdzRoomPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function DdzRoomPanel.Start()
	-- body
end

function DdzRoomPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function DdzRoomPanel.initPanel()
	-- body
	self.btn_back = transform:Find("Button_back").gameObject
	self.btn_auto = transform:Find("Button_auto").gameObject
	self.btn_set = transform:Find("Button_set").gameObject
	self.btn_playtype = transform:Find("Button_playtype").gameObject

	self.tab_buttons = {self.btn_back, self.btn_auto, self.btn_set, self.btn_playtype}

	self.uimage_sign = transform:Find("Image_sysinfo/Image_wifi"):GetComponent('Image')
	self.uitext_systime = transform:Find("Image_sysinfo/Text"):GetComponent('Text')
end

function DdzRoomPanel.setSysTime( time )
	self.uitext_systime.text = time
end

function DdzRoomPanel.setSign( image_sign )
	-- body
	resMgr:LoadSprite("ddzroom_asset", {image_sign}, function(objs)
			self.uimage_sign.sprite = objs[0]
		end)
end

function DdzRoomPanel.setRoomInfo( game_number, room_number )
	-- body
	if room_number then
		local uitext_roomnumber = transform:Find("Image_roomnumber/Text"):GetComponent('Text')
		uitext_roomnumber.text = string.format("房号:%s", room_number)
	end
	local uitext_gamenumber = transform:Find("Image_gamenumber/Text"):GetComponent('Text')
	uitext_gamenumber.text = string.format("剩余局数:%d", game_number)
end
