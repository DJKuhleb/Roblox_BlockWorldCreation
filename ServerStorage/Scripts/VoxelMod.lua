local VoxelMod = {}


function VoxelMod:New(pos,id)
	local m = {}
	m.Position = pos
	m.id = id
	setmetatable(m,self)
	self.__index = self
	return m
end



return VoxelMod
