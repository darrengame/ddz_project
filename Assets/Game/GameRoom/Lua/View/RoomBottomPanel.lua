--
-- Author: jinda.w
-- Date: 2017-09-13 19:04:40
--

RoomBottomPanel = {}
local self = RoomBottomPanel

local transform, game_object

function RoomBottomPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function RoomBottomPanel.Start()
	-- body
end

function RoomBottomPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function RoomBottomPanel.initPanel()
	-- body
	-- self.btn_back = transform:Find("Button_back").gameObject
	-- self.btn_auto = transform:Find("Button_auto").gameObject
	-- self.btn_set = transform:Find("Button_set").gameObject

	self.tab_buttons = {}
end
