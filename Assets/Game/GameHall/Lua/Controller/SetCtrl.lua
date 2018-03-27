-- set controller
-- Author: jinda.w
-- Date: 2017-06-16 17:11:36
--

local M = class("SetCtrl")

function M:ctor()
	-- body
	self.nsound_volume = PlayerPrefs.GetFloat("sound_volume", 1.0)
	self.nmusic_volume = PlayerPrefs.GetFloat("music_volume", 1.0)
	return self
end

function M:show()
	-- body
	log("M show")
	require("View.SetPanel")

	if self.game_object then
		self.game_object:SetActive(true)
		SetPanel.setVolume(self.nsound_volume, self.nmusic_volume)
	else
		panelMgr:CreatePanel("Set", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close( bdestroy )
	if bdestroy then
		panelMgr:ClosePanel("Set")
		self.game_object = nil
	else
		self.game_object:SetActive(false)
	end
	PlayerPrefs.SetFloat("sound_volume", self.nsound_volume)
	PlayerPrefs.SetFloat("music_volume", self.nmusic_volume)
end

function M:showPanel( obj )
	-- body
	log("show panel:"..obj.name)
	self.game_object = obj
	self.transform = obj.transform
	self.lua_behaviour = self.transform:GetComponent("LuaBehaviour")
	for k,v in pairs(SetPanel.tab_buttons) do
		self.lua_behaviour:AddClick(v, function( obj )
			self:onBtnCallback(obj)
		end)
	end
	for k,v in pairs(SetPanel.tab_slider) do
		self.lua_behaviour:AddSliderClick(v, function( obj, value )
			self:onBtnCallback(obj, value)
		end)
	end
	for k,v in pairs(SetPanel.tab_toggle) do
		self.lua_behaviour:AddToggleClick(v, function( obj, bcheck )
			self:onBtnCallback(obj, bcheck)
		end)
	end
	SetPanel.setVolume(self.nsound_volume, self.nmusic_volume)
end

function M:onBtnCallback( obj, value )
	local name = obj.name
	log("on click------->>" .. name..", value:"..tostring(value))
	if name == "Button_close" then
		self:close()
	elseif name == "Button_logout" then
		
	elseif name == "Button_update" then
		
	elseif name == "Slider_sound" then
		self.nsound_volume = value
		soundMgr:SetSoundVolume(value)
	elseif name == "Slider_music" then
		self.nmusic_volume = value
		soundMgr:SetBacksoundVolume(value)
	elseif name == "single_toggle_1" then
		
	elseif name == "single_toggle_2" then
	end
end

return M