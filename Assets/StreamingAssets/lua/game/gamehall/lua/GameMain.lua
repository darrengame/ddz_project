-- lua主入口
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local function requireCommonLua()
	-- body
	print("requireCommonLua")
	require("define")
	require("functions")
	require("AppData")
	require("UserData")
	Event         = require("events")
	LuaNetManager = require("LuaNetManager")
	SocketMgr     = require("SocketMgr")

	MsgBoxCtrl  = require("Controller.MsgBoxCtrl"):create()
	HallManager = require("Controller.HallManager"):create()
	RoomManager = require("Controller.RoomManager"):create()
end

--主入口函数。从这里开始lua逻辑
function Main()					
	requireCommonLua()
	log("主入口函数。从这里开始lua逻辑")

	require("Controller/LoadCtrl"):create():show()
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    if logError then
	    logError(msg)
	else
		print(msg)
    end
    return msg
end

local status, msg = xpcall(Main, __G__TRACKBACK__)
if not status then
    if logError then
	    logError(msg)
	else
		print(msg)
    end
end