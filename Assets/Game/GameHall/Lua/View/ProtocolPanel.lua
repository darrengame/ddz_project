-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

ProtocolPanel = {}
local self = ProtocolPanel

local transform, game_object

function ProtocolPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function ProtocolPanel.Start()
	-- body
	logWarn("Start")
end

function ProtocolPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function ProtocolPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
end

function ProtocolPanel.setTitle( str_title )
	-- body
	local text_title = transform:Find("Text_title"):GetComponent("Text")
	text_title.text = str_title
end

function ProtocolPanel.setContent( str_title, str_content )
	-- body
	local text_title = transform:Find("Scroll_View/Viewport/Content/Text_title"):GetComponent("Text")
	text_title.text = str_title
	local text_content = transform:Find("Scroll_View/Viewport/Content/Text_content"):GetComponent("Text")
	text_content.text = str_content
end