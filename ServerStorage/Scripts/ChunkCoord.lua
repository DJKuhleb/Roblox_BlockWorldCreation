local ChunkCoord = {}

function ChunkCoord:New(_x, _z)
	local newChunkCoord = {}
	newChunkCoord.x = _x
	newChunkCoord.z = _z
	setmetatable(newChunkCoord,self)
	self.__index = self
	return newChunkCoord
end


function ChunkCoord:GetX()
	return self.x
end

function ChunkCoord:GetZ()
	return self.z
end

function ChunkCoord:Equals(other)
	if not other then return false end
	
	if math.floor(other.x + 0.1) == math.floor(self.x + 0.1) and math.floor(other.z + 0.1) == math.floor(self.z + 0.1) then
		return true
	else 
		return false
	end
end
function ChunkCoord:Print()
	print(self.x .. ' ' .. self.z)
end

return ChunkCoord
