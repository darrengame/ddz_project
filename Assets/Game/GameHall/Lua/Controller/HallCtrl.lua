-- 大厅控制
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("HallCtrl")

function M:ctor()
	-- body
	return self
end

function M:show()
	-- body
	log("HallCtrl show")
	require("View.HallPanel")
	
	local nsound_volume = PlayerPrefs.GetFloat("sound_volume", 1.0)
	local nmusic_volume = PlayerPrefs.GetFloat("music_volume", 1.0)
	soundMgr:SetSoundVolume(nsound_volume)
	soundMgr:SetBacksoundVolume(nmusic_volume)

	if self.game_object then
		self.game_object:SetActive(true)
	else
		panelMgr:CreatePanel("Hall", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("Hall")
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

	for k,v in pairs(HallPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end
end

function M:onBtnCallback( obj )
	local name = obj.name
	log("on click------->>" .. name)
	if name == "Button_avatar" then
		HallManager:showPanel("playerinfo")
	elseif name == "Button_diamond" then
		MsgBoxCtrl:show("购买钻石")
	elseif name == "Button_notice" then
		local noticectrl = HallManager:showPanel("notice")
		noticectrl:setTitle("公告")
		noticectrl:setContent("通知", "祝您游戏愉快！！！\n")
	elseif name == "Button_record" then
		HallManager:showPanel("record")
	elseif name == "Button_help" then
		HallManager:showPanel("help")
	elseif name == "Button_set" then
		HallManager:showPanel("set")
	elseif name == "Button_invite" then
		HallManager:showPanel("invite")
	elseif name == "Button_msg" then
	elseif name == "Button_createroom" then
		HallManager:showPanel("createroom")
	elseif name == "Button_joinroom" then
		HallManager:showPanel("joinroom")
	elseif name == "Button_roomlist" then
	elseif name == "Button_sharepy" then
	elseif name == "Button_sharepyq" then
	end
end

return M