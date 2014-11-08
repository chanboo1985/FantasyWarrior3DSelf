Actor = class("Actor",function()
	local node = cc.Node:create()
	node:setCascadeColorEnabled(true)
	return node
end)

function Actor:ctor()
    self._action = {}
    print("self type:",type(self))
    copyTable(ActorDefaultValues,self)
    copyTable(ActorCommonValues,self)
    
    self._hpCounter = HPCounter:create()
    self:addChild(self._hpCounter)
    self._effectNode = cc.Node:create()
    self._monsterHeight = 70
    self._heroHeight = 150
    if uiLayer then
    	currentLayer:addChild(self._effectNode)
    end
end

function Actor:create()
    return Actor.new()
end

function Actor:initShadow()
    self._circle = cc.Sprite:createWithSpriteFrameName("shadow.png")
    self._circle:setScale(self._shadowSize/16)
    self._circle:setOpacity(255*0.7)
    self:addChild(self._circle)
end

function Actor:addEffect(effect)
    effect:setPosition(cc.pAdd(getPosTable(self),getPosTable(effect)))
    if self._racetype ~= EnumRaceType.MONSTER then
        effect:setPositionZ(self:getPositionZ()+self._heroHeight)
    else
        effect:setPositionZ(self:getPositionZ()+self._monsterHeight+effect:getPositionZ())
    end
    currentLayer:addChild(effect)
end

function Actor:initPuff()
    local puff = cc.BillboardParticleSystem:create(ParticleManager:getInstance():getPlistData("walkpuff"))
    local puffFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("walkingPuff.png")
    puff:setTextureWithRect(puffFrame:getTexture(), puffFrame:getRect())
    puff:setScale(1.5)
    puff:setGlobalZOrder(-self:getPositionY()+FXZorder)
    puff:setPositionZ(10)
    self._puff = puff
    self._effectNode:addChild(puff)
end

--getter & setter

-- get hero type
function Actor:getRaceType()
    return self._racetype
end

function Actor:setRaceType(type)
    self._racetype = type
end

function Actor:getStateType()
    return self._statetype
end

function Actor:setStateType(type)
    self._statetype = type
    --add puff particle
    if self._puff then
        if type == EnumStateType.WALKING then
            self._puff:setEmissionRate(5)
        else
            self._puff:setEmissionRate(0)
        end
    end
end

function Actor:setTarget(target)
    if self._target ~= target then
        self._target = target
    end
end
function Actor:setFacing(degrees)
    self._curFacing = DEGREES_TO_RADIANS(degrees)
    self._targetFacing = self._curFacing
    self:setRotation(degrees)
end

function Actor:getAIEnabled()
    return self._AIEnabled
end

function Actor:setAIEnabled(enable)
    self._AIEnabled = enable
end

function Actor:hurtSoundEffects()
-- to override
end

function Actor:hurt(collider, dirKnockMode)
    if self._isalive then
    	local damage = collider.damage
        --calculate the real damage
        local critical = false
        local knock = collider.knock
        if math.random() < collider.criticalChance then
        	damage = damage*1.5
            critical = true
        	knock = knock*2
        end
        damage = damage+ damage* math.random(-1,1)*0.15
        damage = damage - self._defense
        damage = math.floor(damage)
        if damage <= 0 then
        	damage = 1
        end
        self._hp = self._hp - damage
        if self._hp > 0 then
        	if collider.knock and damage ~= 1 then
        		self:knockMode(collider,dirKnockMode)
        		self:hurtSoundEffects()
        	else
                self:hurtSoundEffects()
        	end
        else
            self._hp = 0
            self._isalive = false
            self:dyingMode(getPosTable(collider), knock)
        end
        
        --three param judge if crit
        local blood = self._hpCounter:showBloodLossNum(damage,self,critical)
        self:addEffect(blood)
        return damage
    end
    return 0
end

function Actor:normalAttackSoundEffects()
-- to override
end

function Actor:specialAttackSoundEffects()
-- to override
end

--attacking collision check
function Actor:normalAttack()
    BasicCollider.create(self._myPos, self._curFacing, self._normalAttack)
    self:normalAttackSoundEffects()
end

function Actor:specialAttack()
    BasicCollider.create(self._myPos, self._curFacing, self._specialAttack)
    self:specialAttackSoundEffects()
end

function Actor:baseUpdate(dt)

end

function Actor:stateMachineUpdate(dt)

end

function Actor:movementUpdate(dt)

end

function Actor:walkMode()
    self:setStateType(EnumStateType.WALKING)
    self:playAnimation("walk", true)
end

function Actor:idleMode()
    self:setStateType(EnumStateType.IDLE)
    self:playAnimation("idle", true)
end

function Actor:attackMode()
    self:setStateType(EnumStateType.ATTACKING)
    self:playAnimation("idle", true)
    self._attackTimer = self._attackFrequency*3/4
end

function Actor:knockMode(collider,dirKnockMode)
    self:setStateType(EnumStateType.KNOCKING)
    self:playAnimation("knocked", true)
    self._timeKnocked = self._aliveTime
    local p = self._myPos
    local angle
    if dirKnockMode then
    	angle = collider.facing
    else
        angle = cc.pToAngleSelf(cc.pSub(p,getPosTable(collider)))
    end
    local newPos = cc.pRotateByAngle(cc.pAdd({x=collider.knock,y=0},p),p,angle)
    self:runAction(cc.EaseCubicActionOut:create(cc.MoveTo:create(self._action.knocked:getDuration()*3,newPos)))
end

function Actor:playAnimation(name,loop)
    if self._curAnimation ~= name then
        self._sprite3D:stopAllActions()
    	if loop then
            self._curAnimation3d = cc.RepeatForever:create(self._action[name]:clone())
    	else
    	   self._curAnimation3d = self._action[name]:clone()
    	end
    	self._sprite3D:runAction(self._curAnimation3d)
    	self._curAnimation = name
    end
end