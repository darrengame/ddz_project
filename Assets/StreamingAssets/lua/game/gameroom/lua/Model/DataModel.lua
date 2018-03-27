--
-- Author: jinda.w
-- Date: 2017-09-28 16:10:30
--

local M = class("DataModel")

function M:ctor()
	-- body
	self.data = {}
end

function M:setValue( key, value )
	-- body
	self.data[key] = value
end

function M:getValue( key )
	-- body
	return self.data[key]
end

return M