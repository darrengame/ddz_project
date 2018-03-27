-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

SetPanel = {}
local self = SetPanel

local transform, game_object

function SetPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>"..obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function SetPanel.Start()
	-- body
end

function SetPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.btn_logout = transform:Find("Button_logout").gameObject
	self.btn_update = transform:Find("Button_update").gameObject
	self.tab_buttons = {self.btn_close, self.btn_logout, self.btn_update}
	
	local slider_sound = transform:Find("Slider_sound").gameObject
	local slider_music = transform:Find("Slider_music").gameObject
	self.tab_slider = {slider_sound, slider_music}

	local toggle_global = transform:Find("single_select_language/single_toggle_1").gameObject
	local toggle_local = transform:Find("single_select_language/single_toggle_2").gameObject
	self.tab_toggle = {toggle_global, toggle_local}
end

function SetPanel.setVolume( nsound_volume, nmusic_volume )
	-- body
	log("nsound_volume nmusic_volume:"..nsound_volume..","..nmusic_volume)
	local slider_sound = transform:Find("Slider_sound"):GetComponent(typeof(Slider))
	slider_sound.value = nsound_volume
	local slider_music = transform:Find("Slider_music"):GetComponent(typeof(Slider))
	slider_music.value = nmusic_volume
end

function SetPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end