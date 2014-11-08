require("Actor")

Slime = class("Slime",function() return Actor:create() end)

function Slime:ctor()
	copyTable(ActorCommonValues,self)
	copyTable(SlimeValues,self)
	self._angryFace = false
	self:init3D()
	self:initActions()
end

function Slime:create()
    local ret = Slime.new()
    ret._AIEnable = true
    local update = function(dt)
        ret:baseUpdate(dt)
        ret:stateMachineUpdate(dt)
        ret:movementUpdate(dt)
    end
    ret:scheduleUpdateWithPriorityLua(update,0.5)
    ret:play3DAnim()
    return ret
end

function Slime:reset()
	copyTable(ActorCommonValues,self)
	copyTable(SlimeValues,self)
	self:_findEnemy(self._racetype)
	self:walkMode()
	self:setPositionZ(0)
end

function Slime:init3D()
    self:initShadow()
    self._sprite3D = cc.EffectSprite3D:create(SLIME_C3B_PATH)
    self._sprite3D:setTexture(SLIME_JPG_PATH)
    self._sprite3D:setScale(17)
    self._sprite3D:addEffect(cc.vec3(0,0,0), CelLine, -1)
    self._sprite3D:setRotation(-90)
    self._sprite3D:setRotation3D({x = 90, y = 0, z = 0})
    self:addChild(self._sprite3D)
end

function Slime:play3DAnim()
    self._sprite3D:runAction(cc.RepeatForever:create(createAnimation(SLIME_C3B_PATH,0,22,0.7)))
end

--切换动画
function Slime:playAnimation(name, loop)
    --using name to check which animation is playing
    if self._curAnimation ~= name then
    	self._sprite3D:stopAction(self._curAnimation3D)
    	if loop then
    		self._curAnimation3D = cc.RepeatForever:create(self._action[name]:clone())
    	else
    	   self._curAnimation3D = self._action[name]:clone()
    	end
    	self._sprite3D:setPosition3D(cc.vec3(0,0,0))
    	self._sprite3D:setRotation3D(cc.vec3(90,0,-90))
    	self._sprite3D:runAction(self._curAnimation3D)
    	self._curAnimation = name
    end
end

function Slime:walkMode()
    self:angryFace(false)
    Actor.walkMode(self)
end

function Slime:attackMode()
    self:angryFace(true)
    Actor.attackMode(self)
end

function Slime:idleMode()
    self:angryFace(false)
    Actor.idleMode()
end

function Slime:knockMode(collider,dirKnockMode)
    self:angryFace(false)
    Actor.knockMode(self,collider,dirKnockMode)
end

function Slime:angryFace(isFace)
    if self._angryFace ~=isFace then
    	self._angryFace = isFace
    	if isFace then
            self._sprite3D:setTexture(SLIME_JPG_PATH_)
    	else
            self._sprite3D:setTexture(SLIME_JPG_PATH)
    	end
    end
end

-------------------init slime all animations----------------------
do
    local dur = 0.6
    local bsc = 17
    local walkAction = cc.Spawn:create(
        cc.Sequence:create(
            cc.DelayTime:create(dur/8),
            cc.JumpBy3D:create(dur*7/8, cc.vec3(0,0,0), 30, 1)
        ),
        cc.Sequence:create(
            cc.EaseSineOut:create(cc.ScaleTo:create(dur/8,bsc*1.4,bsc*1.4,bsc*0.75)),
            cc.EaseSineOut:create(cc.ScaleTo:create(dur/8,bsc*0.85,bsc*0.85,bsc*1.3)),
            cc.EaseSineOut:create(cc.ScaleTo:create(dur/8,bsc*1.2,bsc*1.2,bsc*0.9)),
            cc.EaseSineOut:create(cc.ScaleTo:create(dur/8,bsc*0.95,bsc*0.95,bsc*1.1)),
            cc.EaseSineOut:create(cc.ScaleTo:create(dur*4/8,bsc,bsc,bsc))
        )
    )
    walkAction:retain()
    local idleAction = cc.Sequence:create(
        cc.ScaleTo:create(dur/2,bsc*1.1,bsc*1.1,bsc*0.8),
        cc.ScaleTo:create(dur/2,bsc,bsc,bsc)
    )
    idleAction:retain()
    local attack1Action = cc.Spawn:create(
        cc.MoveBy:create(dur/2, cc.vec3(0,0,20)),
        cc.RotateBy:create(dur/2, cc.vec3(70,0,0)),
        cc.EaseBounceOut:create(cc.MoveTo:create(dur/2,cc.p(40,0)))
    )
    attack1Action:retain()
    local attack2Action = cc.Spawn:create(
        cc.MoveTo:create(dur, cc.vec3(0,0,0)),
        cc.RotateBy:create(dur*3/4, cc.vec3(-70,0,0)),
        cc.EaseBackOut:create(cc.MoveTo:create(dur, cc.p(0,0)))
    )
    attack2Action:retain()
    local dieAction = cc.Spawn:create(
        cc.Sequence:create(
            cc.JumpBy3D:create(dur/2, cc.vec3(0,0,0), 30, 1),
            cc.ScaleBy:create(dur,2,2,0.1)
        ),
        cc.RotateBy:create(dur, cc.vec3(-90,0,0))
    )
    dieAction:retain()
    local knockAction = cc.Sequence:create(
        cc.EaseBackInOut:create(cc.RotateBy:create(dur/3, cc.vec3(-60,0,0))),
        cc.RotateBy:create(dur/2, cc.vec3(60,0,0))
    )
    knockAction:retain()
    Slime._actions = {
        walk = walkAction,
        idle = idleAction,
        attack1 = attack1Action,
        attack2 = attack2Action,
        die = dieAction,
        knocked = knockAction
    }
end

function Slime:initActions()
    self._action = Slime._actions
end