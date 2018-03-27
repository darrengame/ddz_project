-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

InvitePanel = {}
local self = InvitePanel

local transform, game_object

function InvitePanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function InvitePanel.Start()
	-- body
end

function InvitePanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.btn_sure = transform:Find("Button_sure").gameObject
	self.tab_buttons = {self.btn_close, self.btn_sure}
end

function InvitePanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end