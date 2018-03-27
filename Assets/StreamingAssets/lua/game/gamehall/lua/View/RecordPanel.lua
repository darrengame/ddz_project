-- loading
-- Author: jinda.w
-- Date: 2017-06-16 16:34:01
--

RecordPanel = {}
local self = RecordPanel

local transform, game_object

function RecordPanel.Awake( obj )
	-- start awake
	logWarn("awake lua -->>".. obj.name)
	game_object = obj
	transform = obj.transform

	self.initPanel()
end

function RecordPanel.Start()
	-- body
end

function RecordPanel.initPanel()
	self.btn_close = transform:Find("Button_close").gameObject
	self.tab_buttons = {self.btn_close}
end

function RecordPanel.setRecord( trf, index, data )
	-- body
	local recore_trf = trf
	local text_index =  recore_trf:Find("Text_index"):GetComponent("Text")
	text_index.text = index

	local text_roomnum =  recore_trf:Find("Text_roomnum"):GetComponent("Text")
	text_roomnum.text = "房号:"..data.room_number

	local text_time =  recore_trf:Find("Text_time"):GetComponent("Text")
	text_time.text = os.date("%Y-%m-%d %H:%M:%S", data.create_ts)

	local score_content = recore_trf:Find("Scroll_View/Viewport/Content")
	resMgr:LoadPrefab('Common', {"Text_player_record"}, function( objs )
		for k,v in pairs(data.scores) do
			local obj = newObject(objs[0])
			local transform = obj.transform
			transform:SetParent(score_content)
			transform.localScale = Vector3.one
			transform.localPosition = Vector3.zero
			local text_msg = transform:GetComponent('Text')
			text_msg.text = string.format("%s:%d", v.name, v.score)
		end
	end)

	local btn_details =  recore_trf:Find("Button_details").gameObject
	btn_details.name = "details_"..index
	table.insert(self.tab_buttons, btn_details)

end

function RecordPanel.OnDestroy()
	logWarn("on destroy -->>"..game_object.name)
end