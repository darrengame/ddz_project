-- 登陆网络消息处理
-- Author: jinda.w
-- Date: 2017-06-09 15:28:06
--

local luacrypt = require "crypt"
local snapshot = require "snapshot"

local M = class("LoginMsgHandler")
local challenge = ""
local secret = ""

function M:ctor( net, root )
	-- body
	self._net = net
	self._root = root
	print("LoginMsgHandler:", luacrypt.base64encode("LoginMsgHandler"))
end

function M:status( status )
	-- body
	print("receive data status:", status)
end

function M:send( msg_text )
	-- body
	self._net:send(msg_text.."\n")
end

function M:receive( data )
	if challenge == "" then
		print("encode challenge:"..data)
		challenge = luacrypt.base64decode(data)
		self.clientkey = luacrypt:randomkey()
		self:send(luacrypt.base64encode(luacrypt.dhexchange(self.clientkey)))
	elseif secret == "" then
		secret = luacrypt.dhsecret(luacrypt.base64decode(data), self.clientkey)
		print("encode secret:", crypt.hexencode(secret))
		local hmac = luacrypt.hmac64(challenge, secret)
		self:send(luacrypt.base64encode(hmac))
	else
		print("encode result:"..data)
		local code = tonumber(string.sub(data, 1, 3))
		assert(code == 200)
		self._net:close()
	end
end

function M:unpack_line( text )
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

function M:encode_token( token )
	return string.format("%s@%s:%s",
		luacrypt.base64encode(token.user),
		luacrypt.base64encode(token.server),
		luacrypt.base64encode(token.pass)
		)
end

function M:send_token( token )
	-- body
	local etoken = luacrypt.desencode(secret, self:encode_token(token))
	self:send(luacrypt.base64encode(etoken))
end

function M:receive_result(result)
	local code = tonumber(string.sub(result, 1, 3))
	print("receive_result code:"..tostring(code))
	if code == 200 then
		--todo
		local subid = luacrypt.base64decode(string.sub(result, 5))
		print("receive_result subid:"..tostring(subid))
	end
end

return M