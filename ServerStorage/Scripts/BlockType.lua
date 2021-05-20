local M = {}
local VoxelData = require(game.ServerStorage.Scripts.VoxelData)

function M:New(blockName,isSolid,backTexture,frontTexture,topTexture,bottomTexture,rightTexture,leftTexture)
	local meta = {}
	meta.BlockName = blockName
	meta.backFaceTexture = backTexture
	meta.frontFaceTexture = frontTexture
	meta.topFaceTexture = topTexture
	meta.bottomFaceTexture = bottomTexture
	meta.leftFaceTexture = leftTexture
	meta.rightFaceTexture = rightTexture
	meta.isSolid = isSolid
	setmetatable(meta,self)
	self.__index = self
	return meta
end

function M:Name()
	return self.BlockName
end

function M:IsSolid()
	return self.isSolid
end
--M.faces = {
--	Back = Vector3.new(0,0,-5), --Back
--	Front = Vector3.new(0,0,5), -- Front
--	Top = Vector3.new(0,5,0), -- Up
--	Bottom  = Vector3.new(0,-5,0), -- Down
--	Right = Vector3.new(-5,0,0), -- Right
--	Left =Vector3.new(5,0,0) -- Left
--}
function M:GetTextureID(faceIndex)
	local face = faceIndex
	if face ==0  then
		return self.backFaceTexture
	elseif face == 1 then
		return self.frontFaceTexture
	elseif face == 2 then
		return self.topFaceTexture
	elseif face == 3 then
		return self.bottomFaceTexture
	elseif face == 4 then
		return self.leftFaceTexture
	elseif face == 5 then
		return self.rightFaceTexture
	else
		error("Error in textureID" ..tostring(faceIndex))
		return false
	end
end

return M
