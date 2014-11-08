
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("src/actors")
cc.FileUtils:getInstance():addSearchPath("src/cocos")
cc.FileUtils:getInstance():addSearchPath("src/util")
cc.FileUtils:getInstance():addSearchPath("src/views")
cc.FileUtils:getInstance():addSearchPath("src/manager")
cc.FileUtils:getInstance():addSearchPath("res")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"
require("util/table")
require("util/util")

require("LoadingScene")
require("CommonConfig")


-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    director:setDisplayStats(true)
    
    local openGLView = cc.Director:getInstance():getOpenGLView()
    
    local frameSize = openGLView:getFrameSize()
    local winSize = {width = 1136, height = 640}
    
    local widthRate = frameSize.width / winSize.width
    local heightRate = frameSize.height / winSize.height
    resolutionRate = nil
   
    if widthRate > heightRate then
    	resolutionRate = heightRate / widthRate
    	openGLView:setDesignResolutionSize(winSize.width,winSize.height*resolutionRate,cc.ResolutionPolicy.NO_BORDER)
    else
        resolutionRate = widthRate / heightRate
        openGLView:setDesignResolutionSize(winSize.width*resolutionRate,winSize.height,cc.ResolutionPolicy.NO_BORDER)
    end
    
    visible_size = cc.Director:getInstance():getVisibleSize()
    visible_origin = cc.Director:getInstance():getVisibleOrigin()
    win_size = cc.Director:getInstance():getWinSize()
    
    print("visible_size  width:"..visible_size.width.."   height:"..visible_size.height)
    print("win_size  width:"..win_size.width.."   height:"..win_size.height)
    print("visible_origin  x:"..visible_origin.x.."   height:"..visible_origin.y)
    
    --create scene 
    local scene = require("LoadingScene"):create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
