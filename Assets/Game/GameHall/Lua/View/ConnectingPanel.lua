-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

LoadingPanel = {}
local self = LoadingPanel

local transform, game_object

function LoadingPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function LoadingPanel.Start()
	-- body
end

function LoadingPanel.initPanel()
	
end

function LoadingPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end