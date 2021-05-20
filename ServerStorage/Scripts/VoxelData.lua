local M = {}
M.ChunkWidth = script.ChunkWidth.Value;
M.ChunkHeight = script.ChunkHeight.Value;


M.WorldSizeInChunks = script.WorldSizeInChunks.Value

M.ViewDistanceInChunks = script.ViewDistanceInChunks.Value

M.WorldSizeInVoxels = M.WorldSizeInChunks * (M.ChunkWidth * 2)

M.BlockTextures = {
	Dirt  = "http://www.roblox.com/asset/?id=57539447"

}

M.faceChecks = {
	Vector3.new(0,0,-5), --Back
	Vector3.new(0,0,5), -- Front
	Vector3.new(0,5,0), -- Up
	Vector3.new(0,-5,0), -- Down
	Vector3.new(5,0,0), -- Right
	Vector3.new(-5,0,0) -- Left
}

M.faces = {
	Back = Vector3.new(0,0,-5), --Back
	Front = Vector3.new(0,0,5), -- Front
	Top = Vector3.new(0,5,0), -- Up
	Bottom  = Vector3.new(0,-5,0), -- Down
	Right = Vector3.new(-5,0,0), -- Right
	Left =Vector3.new(5,0,0) -- Left
}



return M