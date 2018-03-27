-- 大厅面板
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

HallPanel = {}
local self = HallPanel

local transform, game_object

function HallPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function HallPanel.Start()
	-- body
end

function HallPanel.initPanel()

	self.btn_avatar     = transform:Find("Button_avatar").gameObject
	self.btn_diamond    = transform:Find("Button_diamond").gameObject
	self.btn_notice     = transform:Find("Button_notice").gameObject
	self.btn_record     = transform:Find("Button_record").gameObject
	self.btn_help       = transform:Find("Button_help").gameObject
	self.btn_set        = transform:Find("Button_set").gameObject
	self.btn_invite     = transform:Find("Button_invite").gameObject
	self.btn_msg        = transform:Find("Button_msg").gameObject
	self.btn_createroom = transform:Find("Button_createroom").gameObject
	self.btn_joinroom   = transform:Find("Button_joinroom").gameObject
	self.btn_roomlist   = transform:Find("Button_roomlist").gameObject
	self.btn_sharepy    = transform:Find("Button_sharepy").gameObject
	self.btn_sharepyq   = transform:Find("Button_sharepyq").gameObject
	
	self.tab_buttons    = {self.btn_avatar, self.btn_diamond, self.btn_notice, 
							self.btn_record, self.btn_help, self.btn_set, self.btn_invite, 
							self.btn_msg, self.btn_createroom, self.btn_joinroom, 
							self.btn_roomlist, self.btn_sharepy, self.btn_sharepyq}
end

function HallPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end