--
-- Author: jinda.w
-- Date: 2017-09-13 19:04:40
--

RoomPanel = {}
local self = RoomPanel

local transform, game_object

function RoomPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function RoomPanel.Start()
	-- body
end

function RoomPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function RoomPanel.initPanel()
	-- body
	self.btn_back = transform:Find("Button_back").gameObject
	self.btn_auto = transform:Find("Button_auto").gameObject
	self.btn_set = transform:Find("Button_set").gameObject

	self.tab_buttons = {self.btn_back, self.btn_auto, self.btn_set}
end
