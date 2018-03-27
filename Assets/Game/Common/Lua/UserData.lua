--
-- Author: Your Name
-- Date: 2017-06-16 17:02:24
--
UserData = {}

function UserData:init()
	self._data = {}
end

function UserData:setValue( key, value )
	self._data[key] = value
end

function UserData:getValue( key )
	return self._data[key]
end

function UserData:getData()
	return self._data
end

UserData:init()