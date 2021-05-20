local BlockType = require(game.ServerStorage.Scripts.BlockType)
-- blockName,isSolid,backTexture,frontTexture,topTexture,bottomTexture,rightTexture,leftTexture
local BedRockTexture = "http://www.roblox.com/asset/?id=152572095"
local DirtTexture = "http://www.roblox.com/asset/?id=57539447"
local GrassTopTexture = "http://www.roblox.com/asset/?id=2168256299"
local GrassSideTexture = "http://www.roblox.com/asset/?id=4722584885"
local StoneTexture = "http://www.roblox.com/asset/?id=3162897217"
local SandTexture = "http://www.roblox.com/asset/?id=152572215"
local OakWoodTexture = "http://www.roblox.com/asset/?id=3258599312"
local PlainLeavesTexture = "http://www.roblox.com/asset/?id=55320241"
local BlockTypes = {
	[0] = BlockType:New("Nil",false,"","","","","",""),
	[1] = BlockType:New("BedRock",true,BedRockTexture,BedRockTexture,BedRockTexture,BedRockTexture,BedRockTexture,BedRockTexture),
	[2] = BlockType:New("DirtBlock",true, DirtTexture,DirtTexture,DirtTexture,DirtTexture,DirtTexture,DirtTexture),
	[3] = BlockType:New("GrassBlock",true,GrassSideTexture,GrassSideTexture,GrassTopTexture,GrassSideTexture,GrassSideTexture,GrassSideTexture),
	[4] = BlockType:New("StoneBlock",true, StoneTexture, StoneTexture,StoneTexture,StoneTexture,StoneTexture,StoneTexture ),
	[5] = BlockType:New("SandBlock",true,SandTexture,SandTexture,SandTexture,SandTexture,SandTexture,SandTexture),
	[6] = BlockType:New("OakWoodBlock",true,OakWoodTexture,OakWoodTexture,OakWoodTexture,OakWoodTexture,OakWoodTexture,OakWoodTexture),
	[7] = BlockType:New("PlainLeaves",true,PlainLeavesTexture,PlainLeavesTexture,PlainLeavesTexture,PlainLeavesTexture,PlainLeavesTexture,PlainLeavesTexture)
	
}
return BlockTypes
