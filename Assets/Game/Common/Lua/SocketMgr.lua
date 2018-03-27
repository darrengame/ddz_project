-- 网络管理
-- Author: jinda.w
-- Date: 2017-06-26 11:16:28
--

local SocketMgr = class("SocketMgr")

local Protocal = {
	Exception  = 0,	-- 异常掉线
	Disconnect = 1,	-- 正常断线
	Connect    = 2,	-- 正常连接
	TimeOut    = 3,	-- 超时连接
	Close      = 4,	-- 服务器关闭
}

-- 协议类型
local ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 3,
	SPROTO = 2,
}
local ProtocalMsg = {
	Connect		= '101';	--连接服务器
	Exception   = '102';	--异常掉线
	Disconnect  = '103';	--正常断线   
	Message		= '104';	--接收消息
}

function SocketMgr:ctor( name )
	-- 创建一个socket
	self.blogging = false
	self.name = name
	-- self.socket = SocketClient.New()
	self.socket = networkMgr:CreateSocekt(self.name)
	self.socket:OnRegister(function( status, buffer )
		-- print("status:", status, " buffer:", buffer)
		if type(status) == 'number' then
			self.status = status
			if status == Protocal.Exception then
				self:onException()
			elseif status == Protocal.Disconnect then
				self:onDisconnect()
			elseif status == Protocal.Connect then
				self:onConnect()
			elseif status == Protocal.TimeOut then
				self:onTimeOut()
			elseif status == Protocal.Close then
				self:onClose()
			else
				print("error dot not know status"..self.status)
			end
		else
			self:onMessage(buffer)
		end
	end)
	return self
end

function SocketMgr:register_handler( handler )
	-- 接收消息主体
	self.handler = handler
end

function SocketMgr:connect( addr, port )
	-- 连接
	print("connect addr:", addr, "port:", port)
	self.addr = addr
	self.port = port
	self.socket:SendConnect(self.addr, self.port)
end

function SocketMgr:onConnect()
	-- connect start
	print("SocketMgr connected")
	self:recvStatus(self.status)
end

function SocketMgr:onException()
	-- connect 异常断线
	print("SocketMgr exception")
	blogging = false
	self:recvStatus(self.status)
end

function SocketMgr:onDisconnect()
	-- connect 连接中断
	print("SocketMgr disconnect")
	blogging = false
	self:recvStatus(self.status)
end

function SocketMgr:onTimeOut()
	-- 连接超时
	print("SocketMgr timeout")
	self:recvStatus(self.status)
end

function SocketMgr:onClose()
	-- 服务器关闭连接
	print("SocketMgr close")
	self:recvStatus(self.status)
end

function SocketMgr:onMessage( buffer )
	-- 网络消息
	-- print("SocketMgr code:", string.len(buffer), buffer)
	-- local msg, n = self:unpack_msg(buffer)
	local ok, err = pcall(self.handler.receive, self.handler, buffer)
	if ok then
		-- print("SocketMgr call receive succeful")
	else
		error("SocketMgr call receive error"..err)
	end
end

function SocketMgr:send(data)
	-- 发送消息
	-- data = "aaaaaaaaaa"
	-- print("SocketMgr data:", string.len(data), string.len(data)%256, data)
	local pack_data = self:pack_msg(data)
	local buffer = ByteBuffer.New()
	buffer:WriteBuffer(pack_data)
	self.socket:SendMessage(buffer)
end

function SocketMgr:recvStatus( name )
	-- body
	print("Socket status:", name)
	-- self._str_status = name
	local ok, err = pcall(self.handler.status, self.handler, name)
	if ok then
		print("SocketMgr call status succeful")
	else
		error("SocketMgr call status error"..err)
	end
end

function SocketMgr:pack_msg( data )
	-- body
	if _VERSION ~= "lua 5.3" then
		local len = string.len(data)
		local len_info = string.pack("bb", math.floor(len/256), len%256)
		-- return string.pack("A", len_info .. data)
		return string.pack("A", data)
	else
		return string.pack(">s2", data)
	end
end

function SocketMgr:unpack_msg( data )
	-- body
	if _VERSION ~= "lua 5.3" then
		return string.unpack(data, "A")
	else
		return string.unpack(">s2", data)
	end
end

function SocketMgr:close()
	-- body
	networkMgr:OnRemove(self.name)
end


return SocketMgr