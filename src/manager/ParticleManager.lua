ParticleManager = {}

function ParticleManager:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self._plistMap = {}
	return o
end

function ParticleManager:getInstance()
	if not self.instance then
		self.instance = self:new()
	end
	return self.instance
end

function ParticleManager:addPlistData(fileName,keyName)
	if not fileName or not keyName then return end
	if fileName == "" or keyName == "" then return end
	for k in pairs(self._plistMap) do
	   if k == keyName then
	   	   return
	   end
	end
	local plistData = cc.FileUtils:getInstance():getValueMapFromFile(fileName)
    self._plistMap[keyName] = plistData
end

function ParticleManager:getPlistData(keyName)
	if not keyName or keyName == "" then
		return
	end
	for key,val in pairs(self._plistMap) do
		if key == keyName then
			return val
		end
	end
    cclog("can't find plistData by the specified keyName.")
end