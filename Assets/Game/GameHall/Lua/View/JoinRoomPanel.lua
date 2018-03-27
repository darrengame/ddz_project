-- EnterRoom
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

JoinRoomPanel = {}
local self = JoinRoomPanel

local transform, game_object

function JoinRoomPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform
	self.room_number = ""
	self.initPanel()
end

function JoinRoomPanel.Start()
	-- body
end

function JoinRoomPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.btn_number_1 = transform:Find("Button_1").gameObject
	self.btn_number_2 = transform:Find("Button_2").gameObject
	self.btn_number_3 = transform:Find("Button_3").gameObject
	self.btn_number_4 = transform:Find("Button_4").gameObject
	self.btn_number_5 = transform:Find("Button_5").gameObject
	self.btn_number_6 = transform:Find("Button_6").gameObject
	self.btn_number_7 = transform:Find("Button_7").gameObject
	self.btn_number_8 = transform:Find("Button_8").gameObject
	self.btn_number_9 = transform:Find("Button_9").gameObject
	self.btn_number_0 = transform:Find("Button_0").gameObject
	self.btn_number_clear = transform:Find("Button_clear").gameObject
	self.btn_number_delete = transform:Find("Button_delete").gameObject
	self.tab_buttons = {self.btn_close, self.btn_number_1, self.btn_number_2, self.btn_number_3, 
		self.btn_number_4, self.btn_number_5, self.btn_number_6, self.btn_number_7, self.btn_number_8, 
		self.btn_number_9, self.btn_number_0, self.btn_number_clear, self.btn_number_delete}
		
	self.room_number = transform:Find("Image_roomnum/Text_roomnum"):GetComponent('Text')
end

function JoinRoomPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function JoinRoomPanel.setRoomNumber( room_number )
	-- body
	self.room_number.text = room_number
end