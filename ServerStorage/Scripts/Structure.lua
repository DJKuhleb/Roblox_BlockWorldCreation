local Structure = {}
local Noise = require(game.ServerStorage.Scripts.Noise)
local VoxelMod = require(game.ServerStorage.Scripts.VoxelMod)

local PlainTrees  = game.ServerStorage.Configs.BiomeAttributes.Biomes.Default.Structures.Trees.Plain



function Structure:MakeTree(pos, vmodList, minTrunkHeight, maxTrunkHeight)
	
	local height = (maxTrunkHeight * Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),250, 3))
	
	if height < minTrunkHeight then
		height = minTrunkHeight
	end
	
	
	for i = 1,  height do
		table.insert(vmodList,VoxelMod:New(Vector3.new(pos.x,pos.y + (i*5), pos.z), 6))
	end
	
	
	
	local startY = pos.y + height * 5
	local endY = startY +  (PlainTrees.leafMaxHeight.Value * Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),0,3))
	if endY < startY + PlainTrees.leafMinHeight.Value then
		endY = startY + PlainTrees.leafMinHeight.Value
	end
	local prevRadius
	for y = startY, endY do
		if y % 5 == 0 then
			local rModifier = math.random(1,20)
			local radius = (rModifier + PlainTrees.leafMaxRadius.Value) * Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),0,PlainTrees.leafPlacementScale.Value) * 5
			if not prevRadius then
				prevRadius = radius
			else
--				while radius == prevRadius do
--					print('stuck')
--					rModifier = math.random(1,20)
--					print(rModifier)					
--					radius = (rModifier + PlainTrees.leafMaxRadius.Value) * Noise:Get2DPerlin(Vector2.new(pos.x,pos.z),0,PlainTrees.leafPlacementScale.Value) * 5
--					wait()
--				end		
--				prevRadius = radius		
			end
			radius = math.floor(radius)
			for x = pos.x - radius, pos.x + radius do
				if x % 5 == 0 then
					for z  = pos.z - radius , pos.z + radius do
						if z % 5 == 0 then
							table.insert(vmodList,VoxelMod:New(Vector3.new(x,y, z), 7))
						end
						
					end
				end
				
			end
		end
	end
	
	
	--table.insert(vmodList,VoxelMod:New(Vector3.new(pos.x,pos.y + (height*5), pos.z), 7))
	return vmodList
end

return Structure
