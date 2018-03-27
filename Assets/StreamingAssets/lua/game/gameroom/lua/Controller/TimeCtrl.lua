--
-- Author: jinda.w
-- Date: 2017-09-13 19:44:39
--

local M = class("TimeCtrl")

function M:ctor()
	-- body
	self.total_time = 30
	return self
end

function M:show(pos, total_time)
	-- body
	log("TimeCtrl show")
	require("View.TimePanel")
	self.total_time = total_time
	self.pos = pos
	if self.game_object then
		self.game_object:SetActive(true)
		TimePanel.setTime(self.total_time)
		self.transform.anchoredPosition = self.pos
	else
		panelMgr:CreatePanel("Time", function( obj )
			self:showPanel(obj)
		end)
	end
end

function M:close(bdestroy)
	-- body
	if bdestroy then
		panelMgr:ClosePanel("Time")
		self.game_object = nil
	else
		self.game_object:SetActive(false)
	end
end

function M:showPanel(obj)
	-- body
	log("show panel:"..obj.name)
	self.game_object = obj
	self.transform = obj.transform
	self.transform.anchoredPosition = self.pos
	TimePanel.setTime(self.total_time)

	self.tick_time = DOTween.Sequence()
	:AppendInterval(1)
	:SetLoops(-1)
	:AppendCallback(function()
		self:update()
	end)
end

function M:start( total_time, func )
	-- body
	self.total_time = total_time or self.total_time
	self.cur_time = self.total_time
	self.func = func
	TimePanel.setTime(self.total_time)
	
	-- self.transform:DOMoveZ(0.1, self.total_time):OnUpdate(function()
	-- 	self:update()
	-- end)
	self.tick_time:Pause()
	self.tick_time:Play()
end

function M:stop()
	-- body
	-- self.transform:DOPause()
	-- coroutine.pause(self.tick_time)
	-- DOTween:Pause("tick_time")
	self.tick_time:Pause()
end

function M:pause()
	-- body
	-- coroutine.pause(self.tick_time)
	-- self.transform:DOPause()
	-- DOTween:Pause("tick_time")
	self.tick_time:Pause()
end

function M:resume()
	-- body
	self.tick_time:Play()
	-- self.transform:DOMoveX(0, self.cur_time):OnUpdata(function()
	-- 	-- body
	-- 	self:update()
	-- end)
end

function M:update()
	-- body
	if self.game_object == nil 
		or self.game_object.activeSelf == false then
		--todo
		self:stop()
		return true
	end
	log("time update:"..self.cur_time)
	if self.cur_time > 0 then
		self.cur_time = self.cur_time - 1
		TimePanel.setTime(self.cur_time)
	else
		self:stop()
		if self.func then
			self.func()
		end
		return true
	end
	return false
end

return M