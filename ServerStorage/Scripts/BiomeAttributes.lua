local BiomeAttributes = {}
local ServerStorage = game.ServerStorage

function BiomeAttributes:New()
	local attr = {}
	attr.biomeName = ""
	setmetatable(attr,self)
	self.__index = self
	return attr
end



return BiomeAttributes