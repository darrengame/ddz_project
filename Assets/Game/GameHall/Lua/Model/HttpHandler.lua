-- http网络消息处理
-- Author: jinda.w
-- Date: 2017-06-09 15:28:06
--
local cjson = require 'cjson'
local luacrypt = require "crypt"

local M = class("HttpHandler")

local HTTP_SERVER_ADDR = "http://127.0.0.1:8005/"
-- local HTTP_SERVER_ADDR = "http://www.baidu.com/"


function M:ctor()
	-- body
end

function M.httpPost( url, param, func )
	-- http post
	coroutine.wait(0.02)
	local param = "param="..cjson.encode(param)
	print("post url:"..url)
	print("post param="..param)
	-- local form = UnityEngine.WWWForm.New();  
 --    form:AddField("body", param);
	local www = UnityEngine.WWW(url, param)
    coroutine.www(www)
    print('yield(www) end time: '.. UnityEngine.Time.time)
    if www.error ~= nil then
    	print("error:"..www.error)
    	coroutine.yield(www.error)
    end
    
    local str = tolua.tolstring(www.bytes)
    print("result str:"..str)
    local err = pcall(func, cjson.decode(str))
    print("callback err:"..tostring(err))
    coroutine.yield(str)
end

function M.httpGet( url, param, func )
	-- http get
	coroutine.wait(0.02)
	url = url.."?param="..cjson.encode(param)
	print("get url:"..url)
	local www = UnityEngine.WWW(url)
    coroutine.www(www)
    print('yield(www) end time: '.. UnityEngine.Time.time)
    if www.error ~= nil then
    	print("error:"..www.error)
    	coroutine.yield("error:"..www.error)
    end
    
    local str = tolua.tolstring(www.bytes)
	print("result str:"..str)
    local err = pcall(func, cjson.decode(str))
    print("callback err:"..tostring(err))
    coroutine.yield(-1)
end

function M:coroutineGet( url, param, callback )
	-- body
	local get_coroutine = coroutine.create(self.httpGet)
	coroutine.resume(get_coroutine, url, param, callback)
end

function M:coroutinePost( url, param, callback )
	-- body
	local get_coroutine = coroutine.create(self.httpPost)
	coroutine.resume(get_coroutine, url, param, callback)
end

function M:sendClientKey()
	-- body.."clientkey"
	print("sendClientKey")

	self.clientkey = luacrypt:randomkey()
	local handshake = luacrypt.base64encode(luacrypt.dhexchange(self.clientkey))

	self:coroutineGet(HTTP_SERVER_ADDR.."clientkey", {handshake=handshake}, function( data )
		-- body
		dump(data, "clientkey")
		self:sendSeverKey(data)
	end)
end

function M:sendSeverKey(data)
	-- body
	local secret = luacrypt.dhsecret(luacrypt.base64decode(data.serverkey), self.clientkey)
	local hmac = luacrypt.hmac64(data.challenge, secret)
	local enhmac = luacrypt.base64encode(hmac)

	self:coroutinePost(HTTP_SERVER_ADDR.."secretkey", {enhmac=enhmac}, function( data )
		-- body
		dump(data, "serverkey")
		self.secret = data.secret
	end)
end

function M:register( param, func )
	-- body
	-- self:httpGet(HTTP_SERVER_ADDR.."register", param, func)
	self:coroutinePost(HTTP_SERVER_ADDR.."register", param, func)
end
function M:login( param, func )
	-- body
	self:coroutinePost(HTTP_SERVER_ADDR.."login", param, func)
end

function M:getGamelist( param, func )
	-- body
	self:coroutinePost(HTTP_SERVER_ADDR.."gamelist", param, func)
end

return M