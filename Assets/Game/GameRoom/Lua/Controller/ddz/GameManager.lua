--
-- Author: jinda.w
-- Date: 2017-11-03 09:46:09
--

local M = class("GameManager")

function M:ctor()
	-- body
	
	return self
end

function M:connect( data )
	-- body
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))

	self.offest_time = 0
	self.beat_time = 0

	self.req_data = data
	-- self.req_data.ip = "127.0.0.1"
	-- self.req_data.port = 9001
	self.req_data.userid = string.format("%d", math.random(1, 100))
	self.req_data.secret = "fhfhhff"
	-- self.req_data.join_type = 1
	-- self.req_data.info = {game_num="4", pay_mode="1"}

	self.socket_mgr = SocketMgr:create("ddz_room")--LuaNetManager:create("ddzRoom")
	self.room_handler = require("Model.ddz.CommandHandler"):create(self.socket_mgr, self)
	local proto_dir = Util.DataPath.."/lua/game/proto/ddz_proto"
	log("-----------AppConst DebugMod----------:" .. tostring(AppConst.DebugMode))
	if AppConst.DebugMode then
		proto_dir = UnityEngine.Application.dataPath.."/Game/proto/ddz_proto"
	end
	log(proto_dir)
	self.room_handler:register(proto_dir)
	self.socket_mgr:register_handler(self.room_handler)
	self.socket_mgr:connect(self.req_data.ip, self.req_data.port)
end

function M:closeConnect()
	-- body
	self.socket_mgr:close()
end

function M:connectSucceed()
	-- body
	self:send("login", self.req_data)
end

function M:connectError()
	-- body
	log("connect error")
end

function M:send( name, data )
	-- body
	if name ~= "ping" then
		log("send name:"..name)
		dump(data, "send data")
	end
	
	local ok, err = pcall(self.room_handler[name], self.room_handler, data)
	if ok then
		-- log("send call name:"..name)
	else
		logError("send error call name:"..name..", error:"..err)
	end
end

function M:onlogin(resp)
	-- body
	if resp.ok then
		HallManager:closeAllPanel(true)
		self.data = require("Model.DataModel"):create()
		self.game_ctrl = require("Controller.ddz.RoomCtrl"):create(self)
		self.game_ctrl:show()
	else
		log("login error!")
	end
end

function M:getPingTime()
	-- body
	return self.offest_time
end
function M:heartbeat( resp )
	-- body
	self.offest_time = tostring(tolua.gettime()) - self.beat_time
	-- log("beat_time time:"..self.beat_time)
	self.beat_time = tostring(tolua.gettime())
	self:send("ping")
	-- log("beat_time time:"..self.beat_time)
	-- log("offest_time time:"..self.offest_time)
end

function M:ping( resp )
	-- body
end

function M:push( resp )
	-- body
	log("server push:"..resp.text)
end

function M:onroominfo( resp )
	-- body
	log("onroominfo")
	self.data:setValue("players", resp.player_info)
	self.data:setValue("room_number", resp.room_number)
	self.data:setValue("game_number", resp.info[1])
	self.data:setValue("game_start", false)

	self.game_ctrl:roomInfo(resp)
end

function M:onjoinroom( resp )
	-- body
	local players = self.data:getValue("players")
	table.insert(players, resp)
	self.data:setValue("players", players)
	self.game_ctrl:joinRoom(resp, #players)
end

function M:onleftroom( resp )
	-- body
	local players = self.data:getValue("players")
	for k,v in pairs(players) do
		if v.userid == resp.userid then
			table.remove(players, k)
			break
		end
	end
	self.data:setValue("players", players)

	self.game_ctrl:leftRoom(resp)
end

function M:onuserready( resp )
	-- body
	self.game_ctrl:userReady(resp)
end

function M:onrequestmaster( resp )
	-- body
	self.game_ctrl:reqMaster(resp)
end

function M:ongamestart( resp )
	-- body
	self.game_ctrl:gameStart(resp)
end

function M:onplay( resp )
	-- body
	self.game_ctrl:play(resp)
end

function M:ongameover( resp )
	-- body
	self.game_ctrl:gameOver(resp)
end

return M