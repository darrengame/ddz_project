-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

MsgBoxPanel = {}
local self = MsgBoxPanel

local transform, game_object

function MsgBoxPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function MsgBoxPanel.Start()
	-- body
end

function MsgBoxPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.text_msg = transform:Find("Text"):GetComponent('Text')
end

function MsgBoxPanel.setText( str_text )
	-- body
	dump(str_text)
	self.text_msg.text = str_text
end

function MsgBoxPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end