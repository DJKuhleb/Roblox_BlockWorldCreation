local M = {}
local Perlin = require(game.ServerStorage.Scripts.Perlin)
local VoxelData = require(game.ServerStorage.Scripts.VoxelData)


function M:Get2DPerlin(pos, offset, scale,seed)
	local min,max = 0,1
	return min + (max-min) * math.abs(Perlin:noise((pos.x) / VoxelData.ChunkWidth * scale + offset, (pos.y ) / VoxelData.ChunkWidth * scale + offset))
end

function M:Get3DPerlin(pos , offset, scale, threshold)
	threshold = threshold
	local min,max = 0,1
	
	local x = (pos.x + offset) * scale
	local y = (pos.y + offset) * scale
	local z = (pos.z + offset) * scale
	local perlinTest = min + (max-min) * math.abs(Perlin:noise(x,y,z))
	
	

	if perlinTest > threshold then 
		return true
	else
		return false
	end
end

return M
