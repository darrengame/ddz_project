-- loading controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("LoadCtrl")

function M:ctor()
	-- body
	-- UpdateCtrl:onUpdateMsg("1", "1")
	self.protocolctrl = require("Controller.ProtocolCtrl"):create()
	self.hallctrl = require("Controller.HallCtrl"):create()
	self.httpHandler = require("Model.HttpHandler"):create()
	
	self.bagree = true

	return self
end

function M:show()
	-- body
	log("LoadCtrl show")
	require("View.LoadPanel")
	require("Controller.UpdateCtrl").init()

	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("Load", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("Load")
		self.game_object = nil
	else
		self.game_object:SetActive(false)
	end
end

function M:showPanel( obj )
	-- body
	log("show panel:"..obj.name)
	
	self.game_object = obj
	self.transform = obj.transform
	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
	for k,v in pairs(LoadPanel.tab_buttons or {}) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end
	self.lua_behaviour:AddToggleClick(LoadPanel.tg_protocol, function( obj, bcheck )
		-- bcheck
		log(string.format("toggle click name:%s, click:%s", obj.name, tostring(bcheck)))
		self.bagree = bcheck
	end)
	
	-- self.httpHandler:sendClientKey()

	-- 检查更新
	UpdateCtrl.checkUpdate(function( name, msg )
		log("check update msg:"..msg)
		if name == "check" then
			-- 检查
		elseif name == "extract" then
			-- 解压
		elseif name == "download" then
			-- 下载
		end
	end)
	
	PlayerPrefs.SetInt("cur_version", 100)

	-- self.lua_net_manager = LuaNetManager:create("login")
	-- self.loginHandler = require("Model.LoginMsgHandler"):create(self.lua_net_manager)
	-- self.lua_net_manager:register_handler(self.loginHandler)
	-- self.lua_net_manager:connect("127.0.0.1", 8002)
end

function M:onBtnCallback( obj )
	local name = obj.name
	log("on click------->>" .. name)
	if name == "btn_wechat" then
		-- wx
		if self.bagree then
			-- login
			-- local token = {
			-- 	server = "sample",
			-- 	user = "hello_unity",
			-- 	pass = "password",
			-- }
			-- self.loginHandler:send_token(token)

			-- self:close(true)
			-- self.protocolctrl:close(true)
			-- self:loadVenueList()
			-- HallManager:showPanel("hall")
			local account = ""	-- PlayerPrefs.GetString("account")
			local password = "" -- PlayerPrefs.GetString("password")
			if account ~= "" and password ~= "" then
				--todo
				self.httpHandler:login({account=account, password=password}, function(param)
					if param.ret == 0 then
						for k,v in pairs(param) do
							UserData:setValue(k, v)
						end
					else
						-- 登陆失败
						MsgBoxCtrl:show(string.format("登陆失败, 错误信息:%s", param.msg))
					end
				end)
			else
				self.httpHandler:register(nil, function( param )
					if param.ret == 0 then
						for k,v in pairs(param) do
							UserData:setValue(k, v)
						end
						PlayerPrefs.SetString("account", param.account)
						PlayerPrefs.SetString("password", param.password)

						self:loadGameList()
					else
						-- 注册失败
						MsgBoxCtrl:show(string.format("注册失败, 错误信息:%s", param.msg))
					end
				end)
			end
		else
			MsgBoxCtrl:show("请先同意《用户使用协议》后再登陆，谢谢！")
		end
	elseif name == "tg_protocol" then
		-- protocol
	elseif name == "btn_user" then
		-- user protocol
		self.protocolctrl:show()
	end
end

function M:loadConfig()
	-- 游戏配置
end

function M:loadGameList()
	-- 配置表
	-- local venue_list = {}
	-- local ddz_venue = {id=1, name="斗地主", game_num={{num=8, rmb=2}, {num=16, rmb=4}}, 
	-- rmb_aa=1, game_type=0, ip="127.0.0.1", port=9001, playtype={"抢地主", "叫分"}, multiple={64, 128, 256}}
	-- table.insert(venue_list, ddz_venue)
	-- UserData:setValue("venueList", venue_list)

	self.httpHandler:getGamelist(nil, function( param )
		if param.ret == 0 then
			AppData:setValue("gamelist", param.game_list)
			self:enterGame()
		else
			MsgBoxCtrl:show(string.format("获取游戏列表失败, 错误信息:%s", param.msg))
		end
	end)
end

function M:enterGame()
	
	self:close(true)
	self.protocolctrl:close(true)
	HallManager:showPanel("hall")
end

return M