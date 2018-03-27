--
-- Author: jinda.w
-- Date: 2017-11-28 19:08:24
--

DdzOverPanel = {}
local self = DdzOverPanel

local transform, game_object

function DdzOverPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function DdzOverPanel.Start()
	-- body
end

function DdzOverPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end

function DdzOverPanel.initPanel()
	-- body
	self.master_pos = {
	Vector3.New(-258, 92, 0),
	Vector3.New(-258, -7, 0),
	Vector3.New(-258, -107, 0),}

	self.btn_back = transform:Find("Button_back").gameObject
	self.btn_ming = transform:Find("Button_ming").gameObject
	self.btn_continue = transform:Find("Button_continue").gameObject
	self.btn_table = transform:Find("Button_table").gameObject
	self.image_title = transform:Find("Image_title"):GetComponent('Image')
	self.image_bg = transform:Find("Image_bg"):GetComponent('Image')

	self.tab_buttons = {self.btn_back, self.btn_ming, self.btn_continue, self.btn_table}
end

function DdzOverPanel.setPlayerData( index, data, seatid )
	-- body
	local Text_name = transform:Find(string.format("player_score_%d/Text_name", index)):GetComponent('Text')
	Text_name.text = data.name

	local Text_minscore = transform:Find(string.format("player_score_%d/Text_minscore", index)):GetComponent('Text')
	Text_minscore.text = data.minscore

	local Text_mutile = transform:Find(string.format("player_score_%d/Text_mutile", index)):GetComponent('Text')
	Text_mutile.text = string.format("x%d", data.mutiple)

	local Text_score = transform:Find(string.format("player_score_%d/Text_score", index)):GetComponent('Text')
	Text_score.text = data.score

	if seatid == index then
		local color         = Color.New(242, 229, 96)
		Text_name.color     = color
		Text_minscore.color = color
		Text_mutile.color   = color
		Text_score.color    = color
	end
end

function DdzOverPanel.setData( master_seatid, bwin )
	-- body
	local Image_master = transform:Find("Image_master")
	Image_master.anchoredPosition = self.master_pos[master_seatid]
	
	if not bwin then
		resMgr:LoadSprite("ddzover_asset", {"icon_lose", "bg_loser"}, function(objs)
				self.image_title.sprite = objs[0]
				self.image_bg.sprite = objs[1]
			end)
	end
end

