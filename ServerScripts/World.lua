local Players = game.Players
local Chunk = require(game.ServerStorage.Scripts.Chunk)
local ChunkCoord = require(game.ServerStorage.Scripts.ChunkCoord)
local VoxelData = require(game.ServerStorage.Scripts.VoxelData)
local BlockType = require(game.ServerStorage.Scripts.BlockType)
local BlockTypes = require(game.ServerStorage.Scripts.BlockTypes)
local DefaultLodes = game.ServerStorage.Configs.BiomeAttributes.Biomes.Default.Lodes:GetChildren()
local VoxelMod = require(game.ServerStorage.Scripts.VoxelMod)
local Structure = require(game.ServerStorage.Scripts.Structure)

local ReplicatedStorage = game.ReplicatedStorage
local PlayerPing = ReplicatedStorage:WaitForChild('PlayerPing')
local RunService = game:GetService('RunService')
local Noise = require(game.ServerStorage.Scripts.Noise)
local Biomes = game.ServerStorage.Configs.BiomeAttributes.Biomes

local biome = game.ServerStorage.Configs.WorldAttributes.biome.Value

local WorldSpawnLocation = nil
local Rendering = false
local Init = false
local Seed = 1337666666
local BlockModifier = 5

local chunks = {}
local playerChunkCoords = {}
local playerLastChunkCoords = {}
local activeChunks = {}
local chunksToUpdate = {}

local modifications = {}


function deepcopy(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end

  local no
  if type(o) == 'table' then
    no = {}
    seen[o] = no

    for k, v in next, o, nil do
      no[deepcopy(k, seen)] = deepcopy(v, seen)
    end
    setmetatable(no, deepcopy(getmetatable(o), seen))
  else -- number, string, boolean, etc
    no = o
  end
  return no
end


function roundToNearest( number, multiple )
	if number % BlockModifier == 0 then
		return number
	end
	local half = multiple/2
	return number+half - (number+half) % multiple;
end



local World = {
		GetVoxel = function (pos)
			
			--math.randomseed(Seed)
			local yPos = math.floor(pos.y);
			
			-- IMMUTABLE PASS --
			
			if not (isVoxelInWorld(pos)) then return 0 end
			
			--Bottom Chunk, Bedrock
			if yPos == 0 then
				return 1
			end
			
			
			-- BASIC TERRAIN PASS --
			
			local terrainHeight = math.floor(biome.terrainHeight.value * Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),250,biome.terrainScale.Value,Seed) + biome.solidGroundHeight.Value)
			terrainHeight = roundToNearest(terrainHeight,BlockModifier)
			
			local voxelValue = 0
			
			if yPos == terrainHeight then
				voxelValue = 3 --grass
			elseif yPos < terrainHeight and yPos > terrainHeight - (BlockModifier * 4) then
				voxelValue = 2
			elseif yPos > terrainHeight then
				return 0
			else
				voxelValue = 4 -- stone
			end
			
			
			-- SECOND PASS --
			
			if voxelValue == 4 then
				for _,defalutLode in pairs(DefaultLodes) do
					if yPos > defalutLode.minHeight.Value and yPos < defalutLode.maxHeight .Value then
						if Noise:Get3DPerlin(pos,defalutLode.noiseOffset.Value, defalutLode.scale.Value, defalutLode.threshold.Value) then
							voxelValue = defalutLode.blockId.Value
						end
					end
					
				end
			end
			
			
			
			-- TREE PASS --
			
			
			if yPos == terrainHeight then
			
				if Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),0,biome.treeZoneScale.Value) > biome.treeZoneThreshold.Value then
					voxelValue = 3
					if Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),0,biome.treePlacementScale.Value) > biome.treePlacementThreshold.Value then
						voxelValue = 2
						local vm = VoxelMod:New(Vector3.new(pos.x,yPos + 5, pos.z),6)					
						modifications = Structure:MakeTree(pos,modifications,biome.minTreeHeight.Value,biome.maxTreeHeight.Value)
						
					end
				end
				
			end
			
			return voxelValue
		end,
		BlockTypes = BlockTypes
		
		
		
}








function Start()
	math.randomseed(Seed)
	GenerateWorld()
	--repeat wait() until Init

	WorldSpawnLocation = CFrame.new((VoxelData.WorldSizeInChunks * VoxelData.ChunkWidth) / 2, VoxelData.ChunkHeight + 10, (VoxelData.WorldSizeInChunks * VoxelData.ChunkWidth) / 2)
	print(WorldSpawnLocation)
	--Update()
end



function GenerateWorld()
	local Length = roundToNearest((VoxelData.WorldSizeInChunks / 2) + VoxelData.ViewDistanceInChunks,BlockModifier)
	for x=roundToNearest((VoxelData.WorldSizeInChunks / 2) - VoxelData.ViewDistanceInChunks,BlockModifier),Length  do	
		chunks[x] = {}
		for z=roundToNearest((VoxelData.WorldSizeInChunks / 2) - VoxelData.ViewDistanceInChunks,BlockModifier),Length do			
			CreateNewChunk(x,z)
			
			
		end
		
	end
	
	
	for _, v in pairs(modifications) do
		
		local c = GetChunkCoordFromPos(v.Position)
		
		if not chunks[c.x] then
			chunks[c.x] = {}
		end
		
		if not chunks[c.x][c.z] then
			CreateNewChunk(c.x,c.z)
		end
		
	
		
		table.insert(chunks[c.x][c.z].modifications,v)
		
		if not chunksToUpdate[c.x] then
			chunksToUpdate[c.x] = {}
		end
		
		if not chunksToUpdate[c.x][c.z] then
			chunksToUpdate[c.x][c.z] = chunks[c.x][c.z]
		end
		
	end
	
	for x, row in pairs(chunksToUpdate) do
		for z,chunk in pairs(row) do
			chunk:UpdateChunk()
		end
	end
	chunksToUpdate = {}
	modifications = {}
	
	Init = true
end


function Update()
	while true do
		
		local players = game.Players:GetChildren()
		local playerChunkChange = false
		for i, player in pairs (players) do
			if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
				if playerLastChunkCoords[player.UserId] then
					playerChunkCoords[player.UserId] = GetChunkCoordFromPos(player.Character.HumanoidRootPart.CFrame)
					
					if not playerChunkCoords[player.UserId]:Equals(playerLastChunkCoords[player.UserId]) then
						playerChunkChange = true
						
						playerLastChunkCoords[player.UserId] = GetChunkCoordFromPos(player.Character.HumanoidRootPart.CFrame)
					else
						
					end
					
				end
			end
			
		end	
		
		if playerChunkChange then
			
			CheckViewDistance()
			
			
		else
			
			playerChunkChange = false
		end
		
		
		
		wait(5)
	
	end
end

game:GetService('Players').PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
           	wait(2)
		player:LoadCharacter()
		repeat wait() until player.Character:FindFirstChild('HumanoidRootPart')
		player.Character.HumanoidRootPart.CFrame = WorldSpawnLocation
		wait(1)
		playerLastChunkCoords[player.UserId] = GetChunkCoordFromPos(player.Character.HumanoidRootPart.Position)
        end)
    end)
end)

function OnPlayerJoin(player)
	
	repeat wait() until WorldSpawnLocation
	
	player:LoadCharacter()
	
	repeat wait() until player.Character
	repeat wait() until player.Character:FindFirstChild('HumanoidRootPart')
	player.Character.HumanoidRootPart.CFrame = WorldSpawnLocation
	playerLastChunkCoords[player.UserId] = GetChunkCoordFromPos(WorldSpawnLocation)

end

Players.PlayerAdded:Connect(OnPlayerJoin)

function GetChunkCoordFromPos(pos)

	local x = math.floor((pos.x + 0.1) / VoxelData.ChunkWidth)
	local z = math.floor((pos.z + 0.1) / VoxelData.ChunkWidth)
	return ChunkCoord:New(x,z)
end

function CheckViewDistance()
	
		Rendering = true
		local players = game.Players:GetChildren()
		local previouslyActiveChunks = deepcopy(activeChunks)
		for i, player in pairs (players) do			
			if player.Character and player.Character.HumanoidRootPart then
				local coord = GetChunkCoordFromPos(player.Character.HumanoidRootPart.CFrame)
				for x = coord.x - VoxelData.ViewDistanceInChunks, (coord.x + VoxelData.ViewDistanceInChunks)  do
					--if x % 5 == 0 then
						for z = coord.z - VoxelData.ViewDistanceInChunks, (coord.z + VoxelData.ViewDistanceInChunks)  do
							--if z % 5 == 0 then
								local thisChunk =  ChunkCoord:New(x,z)
								if Chunk:IsChunkInWorld(coord) then
									if not chunks[x] then
										chunks[x] = {}
									end
					
									if not chunks[x][z] then
										
										CreateNewChunk(x,z)
										
									elseif not chunks[x][z]:IsActive() then
										chunks[x][z]:ActivateChunk()
										activeChunks[x][z] = thisChunk
									end
									
								end
								
								for i,row in  pairs(previouslyActiveChunks) do
									for z,prevchunk in pairs(row) do
										if prevchunk then
											if prevchunk:Equals(thisChunk) then
												previouslyActiveChunks[i][z] = nil
											end
										end
									end	
									
								end
							--end
						end
						
						wait()
					end
				--end
			end
		end
		
		for _,row in pairs(previouslyActiveChunks) do
			for _,chunkCoord in pairs(row) do
				chunks[chunkCoord.x][chunkCoord.z]:DeactivateChunk()
				activeChunks[chunkCoord.x][chunkCoord.z] = nil
			end
			wait()
		end
		
		Rendering = false
	
		
	
end


local createWaitIndex = 0
function CreateNewChunk(x, z)
	local chunkCoord = ChunkCoord:New(x,z)
	local newChunk = Chunk:New(chunkCoord, World)
	
	newChunk:Create()
	
	chunks[x][z] = newChunk
	if not activeChunks[x] then
		activeChunks[x] = {}
	end
	activeChunks[x][z] = chunkCoord
	createWaitIndex = createWaitIndex + 1
	if createWaitIndex > 5 then
		createWaitIndex = 0
		wait()
	end
	
end


function isVoxelInWorld(pos)
	if pos.x >= 0 and pos.x < VoxelData.WorldSizeInVoxels-1 and pos.z >= 0 and pos.z < VoxelData.WorldSizeInVoxels-1  and pos.y >= 0 and pos.y < VoxelData.ChunkHeight-1 then
		return true
	end
	return false
end















Start()
Update()
