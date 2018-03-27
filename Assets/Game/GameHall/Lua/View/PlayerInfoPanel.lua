-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

PlayerInfoPanel = {}
local self = PlayerInfoPanel

local transform, game_object

function PlayerInfoPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function PlayerInfoPanel.Start()
	-- body
end

function PlayerInfoPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
end

function PlayerInfoPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end