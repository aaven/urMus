-- urMoving.lua
-- by Aaven, Jul 2011

FreeAllRegions()
DPrint("welcome to urMoving")

-------- user inputs ---------
ball_size = 30
player_w = 300
player_h = 30
speed = 10 -- 3 to 10, slow to fast
dir = math.pi/4 -- degree
bounding_list = {} -- bounding objects
pboundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundaries {miny,maxy,minx,maxx}
boundary = {pboundary[1]+player_h,pboundary[2]-player_h,pboundary[3]+player_h,pboundary[4]-player_h}
no_boundary = {0,ScreenHeight(),0,ScreenWidth()}
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
        if r:Bottom() <= r.bound[1] or r:Left() <= r.bound[3] or r:Top() >= r.bound[2] or r:Right() >= r.bound[4] then
            DPrint("Sorry =( You lose!")
               r:Handle("OnUpdate",nil)
               r.backdrop:Handle("OnMove",nil)
            r.moving = 0
            r.list[1]:EnableMoving(false)
            r.list[2]:EnableMoving(false)
            r.list[3]:EnableMoving(false)
            r.list[4]:EnableMoving(false)
        end
    end
end

function StartOrStopMoving(self)
    self:Handle("OnUpdate",nil)
    if self.moving == 1 then
        self.moving = 0
        DPrint("stop")
    else
        self.moving = 1
        DPrint("start")
        self:Handle("OnUpdate",StartMoving)
    end
end

function UpdatePlayer(self,x,y,dx,dy)
    if x < pboundary[3] + player_w/2 then
        self.p[3]:SetAnchor("BOTTOMLEFT",pboundary[3],pboundary[1])
        self.p[4]:SetAnchor("TOPLEFT",pboundary[3],pboundary[2])
    elseif x > pboundary[4] - player_w/2 then
        self.p[3]:SetAnchor("BOTTOMRIGHT",pboundary[4],pboundary[1])
        self.p[4]:SetAnchor("TOPRIGHT",pboundary[4],pboundary[2])
    else
        self.p[3]:SetAnchor("BOTTOM",x,pboundary[1])
        self.p[4]:SetAnchor("TOP",x,pboundary[2])
    end
    
    if y < pboundary[1] + player_w/2 then
        self.p[1]:SetAnchor("BOTTOMLEFT",pboundary[3],pboundary[1])
        self.p[2]:SetAnchor("BOTTOMRIGHT",pboundary[4],pboundary[1])
    elseif y > pboundary[2] - player_w/2 then
        self.p[1]:SetAnchor("TOPLEFT",pboundary[3],pboundary[2])
        self.p[2]:SetAnchor("TOPRIGHT",pboundary[4],pboundary[2])
    else
        self.p[1]:SetAnchor("LEFT",pboundary[3],y)
        self.p[2]:SetAnchor("RIGHT",pboundary[4],y)
    end
end
------------------------------------------------
    
function TouchDown(self)
  --  DPrint("touchdown")
    x,y = InputPosition()
    
    p1 = Region('region','red',UIParent)
    p1.t = p1:Texture(255,0,0,255)
    p1:SetWidth(player_h)
    p1:SetHeight(player_w)
    p1:SetAnchor("LEFT",pboundary[3],(pboundary[2]+pboundary[1])/2)
    p1:EnableInput(true)
  --  p1:EnableMoving(true)
    p1:Show()
    
    p2 = Region('region','red',UIParent)
    p2.t = p2:Texture(255,0,0,255)
    p2:SetWidth(player_h)
    p2:SetHeight(player_w)
    p2:SetAnchor("RIGHT",pboundary[4],(pboundary[2]+pboundary[1])/2)
    p2:EnableInput(true)
  --  p2:EnableMoving(true)
    p2:Show()
    
    p3 = Region('region','blue',UIParent)
    p3.t = p3:Texture(0,0,255,255)
    p3:SetWidth(player_w)
    p3:SetHeight(player_h)
    p3:SetAnchor("TOP",(pboundary[3]+pboundary[4])/2,pboundary[2])
   -- p3:EnableInput(true)
    p3:EnableMoving(true)
    p3:Show()
    
    p4 = Region('region','blue',UIParent)
    p4.t = p4:Texture(0,0,255,255)
    p4:SetWidth(player_w)
    p4:SetHeight(player_h)
    p4:SetAnchor("BOTTOM",(pboundary[3]+pboundary[4])/2,pboundary[1])
   -- p4:EnableInput(true)
    p4:EnableMoving(true)
    p4:Show()
    
    self.p = {p1,p2,p3,p4}
    table.insert(bounding_list,1,p1)
    table.insert(bounding_list,2,p2)
    table.insert(bounding_list,3,p3)
    table.insert(bounding_list,4,p4)
    
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
--    x,y = region:Center()
    region.x=x
    region.y=y
    region.list = bounding_list
    region.bound = no_boundary 
    region.moving = 0
    region.backdrop = self
    
    --region:Handle(signal,StartOrStopMoving)
    StartOrStopMoving(region)
    
    self:Handle("OnTouchDown",nil)
    self:Handle("OnMove",UpdatePlayer)
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