--
-- Author: jinda.w
-- Date: 2017-09-13 19:04:40
--

TimePanel = {}
local self = TimePanel

local transform, game_object

function TimePanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function TimePanel.Start()
	-- body
end

function TimePanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function TimePanel.initPanel()
	-- body
	self.fnt_time = transform:Find("Text"):GetComponent('Text')
end

function TimePanel.setTime( str_time )
	-- body
	self.fnt_time.text = str_time
end
