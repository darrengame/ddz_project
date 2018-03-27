-- CreateRoom
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

CreateRoomPanel = {}
local self = CreateRoomPanel

local transform, game_object

function CreateRoomPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function CreateRoomPanel.Start()
	-- body
end

function CreateRoomPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.tab_buttons = {self.btn_close, "create"}
end

function CreateRoomPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end