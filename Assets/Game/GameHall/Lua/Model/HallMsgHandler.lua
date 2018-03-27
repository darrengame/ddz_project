-- 大厅网络消息处理
-- Author: jinda.w
-- Date: 2017-06-09 15:28:06
--

local M = class("HallMsgHandler")

function M:ctor( net, root )
	-- body
	self._net = net
	self._root = root
end

function M:status( status )
	-- body
	print("receive data status:", status)
end

function M:receive( data )

end

function M:send( msg_text )
	-- body
	-- self._net:send(msg_text.."\n")
end

return M