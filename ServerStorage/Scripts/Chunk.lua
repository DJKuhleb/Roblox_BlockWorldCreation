local VoxelData = require(game.ServerStorage.Scripts.VoxelData)
local Blocks = game.ServerStorage.Blocks
local BlockTypes = require(game.ServerStorage.Scripts.BlockTypes)
local List = require(game.ServerStorage.Scripts.List)
local Chunk = {}



function roundToNearest( number, multiple )
	if number %  multiple == 0 then
		return number
	end
	
	local half = multiple/2
	return number-half - (number-half) % multiple;
end

function Chunk:New( _chunkCoord, World)
	local newChunk = {}
	newChunk.modifications = {}
	newChunk.chunks = {}
	newChunk.World = World
	newChunk.ChunkBlock = nil
	newChunk.ChunkCoord = _chunkCoord
	newChunk.Position = Vector3.new(_chunkCoord.x * VoxelData.ChunkWidth,0,_chunkCoord.z * VoxelData.ChunkWidth)
	newChunk.name = "Chunk " .. tostring(_chunkCoord.x) .. ", ".. tostring(_chunkCoord.z)
	--newChunk.ChunkBlock.Name =  "Chunk " .. tostring(_chunkCoord.x) .. ", ".. tostring(_chunkCoord.z)
	newChunk.isActive = false
	newChunk.isVoxelMapPopulated = false
	setmetatable(newChunk,self)
	self.__index = self
	return newChunk
end



function Chunk:IsVoxelInChunk(x , y, z)
	if x < 0 or x > VoxelData.ChunkWidth-1 or y < 0 or y > VoxelData.ChunkHeight -1 or z < 0 or z > VoxelData.ChunkWidth - 1 then
		return false
	end 
	if self.voxelMap[x][y][z] == 0 then
		return false
	end
	return BlockTypes[self.voxelMap[x][y][z]].isSolid
end

function Chunk:IsChunkInWorld(chunkCoord)
	if (chunkCoord.x > 0 and chunkCoord.x < VoxelData.WorldSizeInChunks - 1 and chunkCoord.z > 0 and chunkCoord.z < VoxelData.WorldSizeInChunks - 1)
	then
		return true
	else
		return false
	end
end

function Chunk:Position()
	return self.Position
end

function Chunk:IsActive()
	return self.isActive
end

function Chunk:_CheckVoxel(pos)
	local x = math.floor(pos.X + 0.5)
	local y = math.floor(pos.Y + 0.5)
	local z = math.floor(pos.Z + 0.5)
	if not self:IsVoxelInChunk(x,y,z) then
		return BlockTypes[self.World.GetVoxel(pos + self.Position)].isSolid
	end 
	return BlockTypes[self.voxelMap[x][y][z]].isSolid
end

function Chunk:PopulateVoxelMap(world)
	local voxelMap = {}
	for x=0,VoxelData.ChunkWidth-5 do	
		if x % 5 == 0 then
			voxelMap[x] = {}
	  		for y=0,VoxelData.ChunkHeight do	
				if y % 5 == 0 then
					voxelMap[x][y] = {}
		     			for z=0,VoxelData.ChunkWidth-5 do
						if z % 5 == 0 then
							voxelMap[x][y][z] = world.GetVoxel(Vector3.new(x,y,z) + self.Position)
		         				
						end
		      			end
				end
	  		 end
		end
	end
	self.voxelMap = voxelMap
	return voxelMap
end


function Chunk:UpdateChunk()
	
	if not self.isVoxelMapPopulated then
		local voxelMap = self:PopulateVoxelMap(self.World)
		self.voxelMap = voxelMap
		self.isVoxelMapPopulated = true
		
	end
	
	
	
	
	
	for _, v in pairs(self.modifications) do
		local pos = v.Position - self.Position
		
		if not self.voxelMap[pos.x][pos.y] then
			self.voxelMap[pos.x][pos.y] = {}
		end
		
		self.voxelMap[pos.x][pos.y][pos.z] = v.id
	
	end
	
	self.modifications = {}
	if self.ChunkBlock then
		
		self.ChunkBlock:Destroy()
		
	end
	self.ChunkBlock = Instance.new('Model')
	self.ChunkBlock.Name = self.name
	
	for x=0,VoxelData.ChunkWidth -5 do	
		if x % 5 == 0 then
	  		for y=0,VoxelData.ChunkHeight do
				if y % 5 == 0 then
		     			for z=0,VoxelData.ChunkWidth - 5 do
						if z % 5 == 0 then
							local blockId = self.voxelMap[x][y][z]
							if BlockTypes[blockId]:IsSolid() then
								self:_AddVoxelDataToChunk(Vector3.new(x,y,z))		
								
							end			
						end
		      			end
				end
	  		 end
		end
	end
	
	if self.ChunkBlock and #self.ChunkBlock:GetChildren() > 0 then
		self.ChunkBlock.Parent = game.Workspace
		
		if self.ChunkBlock.PrimaryPart then
			local x = roundToNearest(self.ChunkCoord.x * VoxelData.ChunkWidth,5)
			local z = roundToNearest(self.ChunkCoord.z * VoxelData.ChunkWidth,5)
			self.ChunkBlock:SetPrimaryPartCFrame(CFrame.new(x,0,z))
		end
		self.isActive = true
	else
		self.isActive = false
	end
	
end




function Chunk:DeactivateChunk()
	self.ChunkBlock.Parent = game.ServerStorage
	--self.ChunkBlock:Destroy()
	self.isActive = false
end




function Chunk:ActivateChunk()
	self.ChunkBlock.Parent = game.Workspace
	--self.ChunkBlock = Instance.new('Model')
	--self:Create(true)
	self.isActive = true
end


function Chunk:Create()
	
	
	
	self:UpdateChunk()
	
	
end



function Chunk:AddTexture(chunk,id)
	chunk.Back.Texture = BlockTypes[id]:GetTextureID(0)
	chunk.Front.Texture = BlockTypes[id]:GetTextureID(1)
	chunk.Top.Texture = BlockTypes[id]:GetTextureID(2)
	chunk.Bottom.Texture = BlockTypes[id]:GetTextureID(3)
	chunk.Left.Texture = BlockTypes[id]:GetTextureID(4)
	chunk.Right.Texture = BlockTypes[id]:GetTextureID(5)
	return chunk
end



function Chunk:_AddVoxelDataToChunk(pos)
	
	local createBlock = true
	local chunk = false
	
	
	
	for i = 1, 6 do
		
		if not self:_CheckVoxel(pos + VoxelData.faceChecks[i]) then
			if not chunk then
				chunk = Blocks.Block:Clone()
				
			
				
				
				chunk.Position = pos
				local blockId = self.voxelMap[pos.X][pos.Y][pos.Z]
				
				if blockId == 7 then
					chunk.BrickColor = BrickColor.Green()
					chunk.Transparency = 0.5
				end
				
				chunk.Name = BlockTypes[blockId]:Name()
				chunk = self:AddTexture(chunk,blockId)
				
			end
			local face = VoxelData.faceChecks[i]
			
			if face == VoxelData.faces.Back then
				chunk.Back.Transparency = 0
			elseif face == VoxelData.faces.Front then
				chunk.Front.Transparency = 0
			elseif face == VoxelData.faces.Left then
				chunk.Left.Transparency = 0
			elseif face == VoxelData.faces.Right then
				chunk.Right.Transparency = 0
			elseif face == VoxelData.faces.Top then
				chunk.Top.Transparency = 0
			elseif face == VoxelData.faces.Bottom then
				chunk.Bottom.Transparency = 0
			else
				chunk = false
				createBlock = false
			end
			
			
		end
	end
	
--	if Chunk and Chunk.Top.Transparency == 1 then
--		createBlock = false
--	end
	
	if chunk then
		chunk.Parent = self.ChunkBlock
		if not self.ChunkBlock.PrimaryPart then
			chunk.Name = "PrimaryPart"
			self.ChunkBlock.PrimaryPart = chunk
		end
	end
	
end



return Chunk
