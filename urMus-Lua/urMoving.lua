-- urMoving.lua
-- by Aaven, Jul 2011

FreeAllRegions()
DPrint("welcome to urMoving")

-------- user inputs ---------
speed = 10 -- 3 to 10, slow to fast
dir = math.pi/4 -- degree
bounding_list = {} -- bounding objects
boundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundaries {minx,maxx,miny,maxy}
signal = "OnTouchDown" -- start/stop signal

------------------------------------------------------------------
pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show()

------------------------------------------------
function TouchEdge(r,other)
    if r:Bottom() <= other:Top() and r:Top() >= other:Top() then
        DPrint("bottom"..other:Name())
        r.touch = "bottom"
    elseif r:Left() <= other:Right() and r:Right() >= other:Right()then
        DPrint("left"..other:Name())
        r.touch = "left"
    elseif r:Top() >= other:Bottom() and r:Bottom() <= other:Bottom()then
        DPrint("top"..other:Name())
        r.touch = "top"
    elseif r:Right() >= other:Left() and r:Left() <= other:Left()then
        DPrint("right"..other:Name())
        r.touch = "right"
    else
        r.touch = "none"
    end
end

function StartMoving(r,e)
    r.x = r.x + r.dx
    r.y = r.y + r.dy
    r:SetAnchor("CENTER",r.x,r.y)
    
    r.touch = "none"
    for k,v in pairs (r.list) do
        if r:RegionOverlap(v) then
            TouchEdge(r,v)
            break
        end
    end
    
    if r.touch == "top" then
        r.dy = -math.abs(r.dy)
    elseif r.touch == "right" then
        r.dx = -math.abs(r.dx)
    elseif r.touch == "bottom" then
        r.dy = math.abs(r.dy)
    elseif r.touch == "left" then
        r.dx = math.abs(r.dx)
    else
        if r:Bottom() <= r.bound[1] then
        DPrint("none bottom")
            r.dy = math.abs(r.dy)
        elseif r:Left() <= r.bound[3] then
        DPrint("none left")
            r.dx = math.abs(r.dx)
        elseif r:Top() >= r.bound[2] then
        DPrint("none top")
            r.dy = -math.abs(r.dy)
        elseif r:Right() >= r.bound[4] then
        DPrint("none right")
            r.dx = -math.abs(r.dx)
        end
    end
end

function StartOrStopMoving(self)
    self:Handle("OnUpdate",nil)
    if self.moving == 1 then
        self.moving = 0
        DPrint("stop")
    else
    	self.x,self.y = self:Center()
        self.moving = 1
        DPrint("start")
        self:Handle("OnUpdate",StartMoving)
    end
end


------------------------------------------------
function TouchDown(self)
  --  DPrint("touchdown")
    x,y = InputPosition()
    
    p1 = Region('region','red',UIParent)
    p1.t = p1:Texture(255,0,0,255)
    p1:SetWidth(30)
    p1:SetHeight(300)
    p1:SetAnchor("RIGHT",ScreenWidth(),ScreenHeight()/2)
    p1:EnableInput(true)
    p1:EnableMoving(true)
    --p1:Show()
    
    p2 = Region('region','blue',UIParent)
    p2.t = p2:Texture(0,0,255,255)
    p2:SetWidth(30)
    p2:SetHeight(300)
    p2:SetAnchor("LEFT",0,ScreenHeight()/2)
    p2:EnableInput(true)
    p2:EnableMoving(true)
    --p2:Show()
    
    region = Region()
    region.t = region:Texture(255,255,255,255)
    region:SetWidth(50)
    region:SetHeight(50)
    region:SetAnchor("CENTER",x,y)
    region:EnableInput(true)
    region:Show()
    
    region.dx = math.tan(dir)
    region.dy = speed/region.dx 
    region.dx = speed*region.dx
    region.list = bounding_list
    region.bound = boundary 
    region.moving = 0
    
    region:Handle(signal,StartOrStopMoving)
    
    self:Handle("OnTouchDown",nil)
end

function TouchUp(self)
--    DPrint("MU")
end

function DoubleTap(self)
--      DPrint("DT")
end

function Enter(self)
--    DPrint("EN")
end

function Leave(self)
--    DPrint("LV")
end

backdrop = Region('region', 'backdrop', UIParent)
backdrop:SetWidth(ScreenWidth())
backdrop:SetHeight(ScreenHeight())
backdrop:SetLayer("BACKGROUND")
backdrop:SetAnchor('BOTTOMLEFT',0,0)
backdrop:Handle("OnTouchDown", TouchDown)
backdrop:Handle("OnTouchUp", TouchUp)
backdrop:Handle("OnDoubleTap", DoubleTap)
backdrop:Handle("OnEnter", Enter)
backdrop:Handle("OnLeave", Leave)
backdrop:EnableInput(true)