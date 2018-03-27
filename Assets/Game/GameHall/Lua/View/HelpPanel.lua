-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

HelpPanel = {}
local self = HelpPanel

local transform, game_object

function HelpPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function HelpPanel.Start()
	-- body
end

function HelpPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.help_content = transform:Find("ScrollView_content/Viewport/Content/Text_content"):GetComponent("Text")
	self.tab_buttons = {self.btn_close}
end

function HelpPanel.setRule( str )
	-- body
	self.help_content.text = str
end

function HelpPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end