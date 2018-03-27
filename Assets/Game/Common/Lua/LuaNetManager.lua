-- luasocket manager
-- Author: jinda.w
-- Date: 2017-05-11 14:33:51
--
local LuaNetManager = class("LuaNetManager")

local luasocket = require("socket")
-- local sproto = require "3rd/sproto/sproto"
-- local luacrypt  = require "crypt"

local STATUS_CLOSED            = "closed"
local STATUS_NOT_CONNECTED     = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"

local SOCKET_TCP_CLOSE      = "SOCKET_TCP_CLOSE"
local SOCKET_TCP_CLOSED     = "SOCKET_TCP_CLOSED"
local SOCKET_TCP_CONNECTING = "SOCKET_TCP_CONNECTING"
local SOCKET_TCP_CONNECTED  = "SOCKET_TCP_CONNECTED"
local SOCKET_TCP_FAIL       = "SOCKET_TCP_FAIL"

local RETRY_TIME = 3
local DELAY_TIME = 5
local CHECK_TIME = 5

function LuaNetManager:ctor(name)
	-- body
	self._name         = name
	self._bconnected   = false
	self._tb_send_task = {}
	self._socket = nil
	-- self._socket:setoption("tcp-nodelay", true) -- 去掉优化
end

function LuaNetManager:register_handler( handler )
	-- 
	self._handler = handler
end

function LuaNetManager:connect( addr, port )
	-- body
	self.addr = addr or self.addr
	self.port = port or self.port
	self:_connect()
end

function LuaNetManager:_connect()
	-- body
	print("connect:", self.addr, self.port)

	local isIPV6_only = false
	local addrifo, err = luasocket.dns.getaddrinfo(self.addr)
	-- dump(addrifo)
	if addrifo ~= nil then
		for k,v in pairs(addrifo) do
			if v.family == "inet6" then
				isIPV6_only = true
				break
			end
		end
	end

	if isIPV6_only then
		self._socket = luasocket.tcp6()
	else
		self._socket = luasocket.tcp()
	end
	self._socket:settimeout(0)

	-- TODO: 循环获取数据
	-- threadMgr:AddThreadEvent(self._name, function()
	-- 	-- body
	-- 	self:processSocketIO()
	-- end)
	self.recv_coroutine = coroutine.create(function()
		while self._bconnected do
			coroutine.wait(1)
			print("get time:", luasocket.gettime())
			self:processSocketIO()
			if self._bconnected == false then
				coroutine.yield(self._bconnected)
			end
		end
	end)

	-- 循环检查连接
	local check_times = 0
	self.check_coroutine = coroutine.create(function()
		while self._bconnected == false do
			coroutine.wait(1)
			self:checkConnect()
			check_times = check_times + 1
			print("process_check:", self._bconnected, check_times)
			if self._bconnected then
				self:status(SOCKET_TCP_CONNECTED)
				coroutine.yield(self._bconnected)
			end
			if check_times > CHECK_TIME and (not self._bconnected) then
				self:status(SOCKET_TCP_FAIL)
				coroutine.yield(self._bconnected)
			end
		end
	end)
	coroutine.resume(self.check_coroutine)
end

function LuaNetManager:checkConnect()
	-- body
	if self:isConnect() then
		print("------- connected -------")
		self._bconnected = true
		-- print("1 receive time:", luasocket.gettime())
		-- local recvt, sendt, status = luasocket.select({self._socket}, ti)
		-- print("input:", #recvt, sendt, status)
		
		-- local buffer, err = self._socket:receive("*a")
		-- print("input receive:", buffer, err)
		-- print("2 receive time:", luasocket.gettime())

		coroutine.resume(self.recv_coroutine)
		-- threadMgr:StartThreadEvent(self._name)
	end
end

function LuaNetManager:stop()
	-- body
	print("------- stop -------")
	self._bconnected = false
end

function LuaNetManager:close()
	-- body
	print("------- close -------")
	self:status(SOCKET_TCP_CLOSE)
	self:stop()
	self._socket:close()
end

function LuaNetManager:shutdown()
	-- body
	print("------- shutdown -------")
	self:status(SOCKET_TCP_CLOSE)
	self:stop()
	self._socket:shutdown()
end

function LuaNetManager:isConnect()
	-- body
	local __succ, __status = self._socket:connect(self.addr, self.port)
		-- print("SocketTCP._connect:", __succ, __status)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function LuaNetManager:processSocketIO(ti)
	-- body
	if not self._bconnected then
		return
	end
	self:processInput(ti)
	-- self:processOutput(ti)
end

function LuaNetManager:processInput(ti)
	-- 检测是否有可读的socket
	print("1 receive time:", luasocket.gettime())
	local recvt, sendt, status = luasocket.select({self._socket}, ti)
	print("processInput:"..#recvt)
	print("2 receive time:", luasocket.gettime())
	if #recvt <= 0 then
		return;
	end
	print("input:", #recvt, sendt, status)

	local buffer, err = self._socket:receive()
	-- local ok, buffer, n = pcall(string.unpack, ">s2", data)

	print("input receive:", buffer, err)
	if err == STATUS_CLOSED or err == STATUS_NOT_CONNECTED then
		self:close()
		if self._bconnected then
			self:status(SOCKET_TCP_CLOSED)
		else
			self:status(SOCKET_TCP_FAIL)
		end
		return
	end

	if buffer then
		-- TODO:解析包
		if pcall(self._handler.receive, self._handler, buffer) then
			print("LuaNetManager call receive succeful")
		else
			print("LuaNetManager call receive error")
		end
	end
end

function LuaNetManager:processOutput(ti)
	-- body
	if self._tb_send_task and #self._tb_send_task > 0 then
		local data = self._tb_send_task[#self._tb_send_task]
		if data then
			print("processOutput:", data)
			local pack_data = self:pack_msg(data)
			-- print("pack_data:", pack_data)
			-- local len, err = self._socket:send(pack_data), 
			repeat
				local len, err = self._socket:send(pack_data)
				print("socket send:", #data, "len:", len, "error:", err)
				if not len then
					error(self._socket.error)
				end
				pack_data = pack_data:sub(len+1)
			until pack_data == ""
			--发送长度不为空，且发送长度==数据长度
			if pack_data == "" then
				table.remove(self._tb_send_task)
			end
		end
	end
end

function LuaNetManager:send( data )
	table.insert(self._tb_send_task, 1, data)
end

function LuaNetManager:status( name )
	-- body
	print("Socket status:", name)
	-- self._str_status = name
	local ok, err = pcall(self._handler.status, self._handler, name)
	if ok then
		print("call status succeful")
	else
		error("LuaNetManager call status error"..err)
	end
	-- local func = self._handler["status"]
	-- if func then
	-- 	print("send status:", self._str_status)
	-- 	self._handler:status(self._str_status)
	-- end
end

function LuaNetManager:pack_msg( data )
	-- body
	if _VERSION ~= "lua 5.3" then
		local len = string.len(data)
		local len_info = string.pack("bb", math.floor(len/256), len%256)
		return string.pack("A", len_info .. data)
	else
		return string.pack(">s2", data)
	end
end

return LuaNetManager

