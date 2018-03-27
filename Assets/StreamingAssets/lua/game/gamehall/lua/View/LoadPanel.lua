-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

LoadPanel = {}
local self = LoadPanel

local transform, game_object

function LoadPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function LoadPanel.Start()
	-- body
end

function LoadPanel.initPanel()

	self.btn_wxlogin = transform:Find("btn_wechat").gameObject
	self.tg_protocol = transform:Find("tg_protocol").gameObject
	self.btn_user    = transform:Find("tg_protocol/btn_user").gameObject
	self.tab_buttons = {self.btn_wxlogin, self.btn_user}
end

function LoadPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end