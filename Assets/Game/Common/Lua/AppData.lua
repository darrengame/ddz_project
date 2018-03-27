-- app data
-- Author: jinda.w
-- Date: 2017-06-16 16:56:02
--

AppData = {}

function AppData:init()
	-- 应用缓存数据
	self._data = {}
end

function AppData:setValue( key, value )
	-- 设置值
	self._data[key] = value
end

function AppData:getValue( key )
	-- 取值
	return self._data[key]
end

function AppData:getData()
	-- 整个数据
	return self._data
end

AppData:init()