-- 更新逻辑
-- Author: jinda.w
-- Date: 2017-06-21 11:42:52
--

UpdateCtrl = {}

local self = UpdateCtrl

function UpdateCtrl.init()
	-- body
	log("update start")
	self.unload()
	Event.AddListener(DISPATCH_MSG.UPDATE_CHECK, function( msg )
		self.updateCheck(msg)
	end)
	Event.AddListener(DISPATCH_MSG.UPDATE_EXTRACT, function( msg )
		self.updateExtract(msg)
	end)
	Event.AddListener(DISPATCH_MSG.UPDATE_DOWNLOAD, function( msg )
		self.updateDownload(msg)
	end)
end

function UpdateCtrl.unload()
	-- body
	Event.RemoveListener(DISPATCH_MSG.UPDATE_CHECK)
	Event.RemoveListener(DISPATCH_MSG.UPDATE_EXTRACT)
	Event.RemoveListener(DISPATCH_MSG.UPDATE_DOWNLOAD)
end

function UpdateCtrl.onUpdateMsg( key, value )
	-- body
	Event.Brocast(tostring(key), value);
end

function UpdateCtrl.updateCheck( msg )
	-- 更新消息
	log("updateMsg:"..tostring(msg))
	local str_msg = ""
	local tab_msgs = string.split(msg, "|")
	if tab_msgs[1] == "begin" then
		--todo
	elseif tab_msgs[1] == "end" then
		--todo
	elseif tab_msgs[1] == "progressing" then
		--todo
	end
	if self._func then self._func("check", str_msg) end
end

function UpdateCtrl.updateExtract( msg )
	-- 解压消息
	log("updateExtract:"..tostring(msg))
	local str_msg = ""
	local tab_msgs = string.split(msg, "|")
	if tab_msgs[1] == "begin" then
		--todo
	elseif tab_msgs[1] == "end" then
		--todo
	elseif tab_msgs[1] == "progressing" then
		--todo
	end
	if self._func then self._func("extract", str_msg) end
end

function UpdateCtrl.updateDownload( msg )
	-- 下载消息
	log("updateDownload:"..tostring(msg))
	local str_msg = ""
	local tab_msgs = string.split(msg, "|")
	if tab_msgs[1] == "begin" then
		--todo
	elseif tab_msgs[1] == "end" then
		--todo
	elseif tab_msgs[1] == "progressing" then
		--todo
	end
	if self._func then self._func("download", str_msg) end
end

function UpdateCtrl.checkUpdate(func)
	-- body
	self._func = func
	-- updateMgr:CheckExtractResource()
end

return UpdateCtrl