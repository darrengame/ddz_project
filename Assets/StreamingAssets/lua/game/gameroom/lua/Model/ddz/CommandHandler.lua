-- 
-- Author: jinda.w
-- Date: 2017-09-15 14:06:49
--

local M = class("CommandHandler")
local luacrypt = require "crypt"

local sproto = require "sproto/sproto"

function M:ctor(socket_mgr, root)
	-- body
	self.socket_mgr = socket_mgr
	self.root = root

	self.var = {
		session_id = 0 ,
		session = {},
	}
	return self
end

function M:status( status )
	-- 状态
-- local SOCKET_TCP_CLOSE      = "SOCKET_TCP_CLOSE"
-- local SOCKET_TCP_CLOSED     = "SOCKET_TCP_CLOSED"
-- local SOCKET_TCP_CONNECTING = "SOCKET_TCP_CONNECTING"
-- local SOCKET_TCP_CONNECTED  = "SOCKET_TCP_CONNECTED"
-- local SOCKET_TCP_FAIL       = "SOCKET_TCP_FAIL"
	log("network:"..status)
	if status == 4 then
		-- 服务器关闭
		self.root:connectError()
	elseif status == 1 then
		-- 正常断线
	elseif status == 2 then
		-- 正常连接
		self.root:connectSucceed()
	elseif status == 3 then
		-- 超时连接
		self.root:connectError()
	elseif status == 0 then
		-- 异常掉线
		self.root:connectError()
	end
end

function M:register( name )
	local f = assert(io.open(name .. ".s2c.sproto"))
	local t = f:read "*a"
	f:close()
	self.var.host = sproto.parse(t):host "package"
	local f = assert(io.open(name .. ".c2s.sproto"))
	local t = f:read "*a"
	f:close()
	self.server_host = sproto.parse(t):host "package"
	self.var.request = self.var.host:attach(sproto.parse(t))

	local f = assert(io.open(name .. ".s2c.sproto"))
	local t = f:read "*a"
	f:close()
	self.server_sender = self.server_host:attach(sproto.parse(t))
end

-----------接收到数据开始-----------
function M:receive( data )
	-- 收到数据
	-- print("recvData:", data)
	local t, session_id, resp, err = self.var.host:dispatch(data)
	
	if t == "REQUEST" then
		if session_id ~= "heartbeat" then
			print("session id:", session_id)
			dump(resp)
		end
		self:pushMsg(session_id, nil, resp)
	else
		local session = self.var.session[session_id]
		self.var.session[session_id] = nil

		if err then
			print(string.format("session %s[%d] error(%s)", session.name, session_id, err))
		else
			if session.name ~= "ping" then
				print("session name:", session.name)
				dump(resp)			
			end
			
			if session.name == "signup" then
				self:reqsignup(session.req, resp)
			elseif session.name == "signin" then
				self:reqsignin(session.req, resp)
			else
				self:pushMsg(session.name, session.req, resp)
			end
		end
	end
end
-----------接收到数据结束-----------

-----------发送数据开始-----------

function M:send( name, data, session_id )
	-- body
	self.var.session_id = session_id--self.var.session_id + 1
	self.var.session[self.var.session_id] = { name = name, req = data }
	local data_buffer = self.var.request(name, data, self.var.session_id)
	self.socket_mgr:send(data_buffer)

	-- server data test
	if name ~= "ping" then
		print("send data:", name)
		local type, name, args, response = self.server_host:dispatch(data_buffer, string.len(data_buffer))
		print("server get data:", type, name, args, response)
		dump(data, "send server data")
		dump(args, "get server data")
		-- local server_data = self.server_sender("push", {text="welcome"})
		-- print("server_sender:", string.len(server_data), server_data)
		-- print("send client data:", self.var.host:dispatch(server_data))
	end
	
	return self.var.session_id
end

function M:ping( data )
	-- body
	self:send("ping", data, 1)
end

function M:signup( data )
	-- body
	self:send("signup", data, 2)
end

function M:signin( data )
	-- body
	self:send("signin", data, 3)
end

function M:login( data )
	-- body
	self:send("login", data, 4)
end

function M:command( data )
	-- body
	self:send("command", data, 5)
end

-----------发送数据开始-----------

-----------收到发送数据开始-----------

function M:reqsignup( name, req, data )
	if data.ok then
		self:signin({ userid = req.userid })
	else
		error "Can't signup"
	end
end

function M:reqsignin( name, req, data )
	-- body
	if data.ok then
		-- self:ping()
		self:login()
	else
		-- signin failed, signup
		self:signup({userid="bbb"})
	end
end

function M:pushMsg( name, req, resp )
	-- body
	local ok, err = pcall(self.root[name], self.root, resp, req)
	if ok then
		-- log("send call name:"..name)
	else
		logError("pushMsg error call name:"..name..", error:"..err)
	end
end

-----------收到发送数据结束-----------

return M