local Lode = {}

function Lode:New(nodeName, blockID, minHeight, maxHeight,scale, threshold, noiseOffset)
	local attr = {}
	attr.nodeName = nodeName
	attr.blockID = blockID
	attr.minHeight = minHeight
	attr.maxHeight = maxHeight
	attr.scale = scale
	attr.threshold = threshold
	attr.noiseOffset = noiseOffset
	setmetatable(attr,self)
	self.__index = self
	return attr
end


return Lode
