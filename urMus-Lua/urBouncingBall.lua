-- urBouncingBall.lua
-- by Aaven, Jul 2011

FreeAllRegions()
DPrint("welcome to urMoving")

-------- user inputs ---------
size_ball = 30
speed = 10 -- 3 to 10, slow to fast
dir = math.pi/4 -- degree
bounding_list = {} -- bounding objects
boundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundaries {miny,maxy,minx,maxx}
bouncing_ball_boundary = {-10000,ScreenHeight(),0,ScreenWidth()}

signal = "OnTouchDown" -- start/stop signal

row = 10
col = 8
w = ScreenWidth()/col
h = w*0.3

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
        DPrint("this is impossible")
        r.touch = "none"
    end
end

function StartMoving(r,e)
    r.touch = "none"
    for k,v in pairs (r.list) do
        if r:RegionOverlap(v) then
            TouchEdge(r,v)
            
            if r.touch == "top" then
                r.dy = -math.abs(r.dy)
            elseif r.touch == "right" then
                r.dx = -math.abs(r.dx)
            elseif r.touch == "bottom" then
                r.dy = math.abs(r.dy)
            elseif r.touch == "left" then
                r.dx = math.abs(r.dx)
            end
            
            if v ~= r.list[1] then 
                v:Hide()
                table.remove(r.list,k)
                
                if #r.list == 1 then
                    DPrint("Congrats! You Win!")
                    r:Handle("OnUpdate",nil)
                    r.moving = 0
                    r.list[1]:EnableMoving(false)
                end
            end
            break
        end
    end
    
    
    if r.touch == "none" then
        if r:Bottom() <= 0 then
            DPrint("Sorry =( You lose!")
            r:Handle("OnUpdate",nil)
            r.backdrop:Handle("OnMove",nil)
            r.moving = 0
            r.list[1]:EnableMoving(false)
        elseif r:Bottom() <= r.bound[1] then
            DPrint("none bottom"..r.bound[1])
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
    
    r.x = r.x + r.dx
    r.y = r.y + r.dy
    r:SetAnchor("CENTER",r.x,r.y)
end

function StartOrStopMoving(self)
    self:Handle("OnUpdate",nil)
    if self.moving == 1 then
        self.moving = 0
        --DPrint("stop")
    else
        self.moving = 1
        --DPrint("start")
        self:Handle("OnUpdate",StartMoving)
    end
end

function CreateTile(x,y)
    local r = Region('region','tile',UIParent)
    r.t = r:Texture(0,0,0,255)
    r:SetWidth(w)
    r:SetHeight(h)
    r:SetAnchor("TOPLEFT",x,y)
    
    local r1 = Region('region','tile',UIParent)
    r1.t = r1:Texture(0,255,0,255)
    r1:SetWidth(w-4)
    r1:SetHeight(h-3)
    r1:SetAnchor("CENTER",r,"CENTER")
    r1:Show()
    
    r:Show()
    
    return r
end

function CreateTiles(bounding_list)
    list = {}
    r1 = math.ceil(row/2)-1
    r2 = math.floor(row/2)-1
    c1 = col-1
    c2 = col-2
    for i = 0,r1 do
        list[i*2+1] = {}
        for j = 0,c1 do
            local tile = CreateTile(w*j,ScreenHeight()-h*2*i)
            list[i*2+1][j] = tile
            table.insert(bounding_list,tile)
        end
    end
    
    for i = 0,r2 do
        list[i*2+2] = {}
        for j = 0,c2 do
            local tile = CreateTile(w*j+w/2,ScreenHeight()-h*2*i-h)
            list[i*2+2][j] = tile
            table.insert(bounding_list,tile)
        end
    end
    
    return list
end

function MovePlayer(self, x, y, dx, dy)
    if x < self.p:Width()/2 then
        self.p:SetAnchor("BOTTOMLEFT",0,0)
    elseif  x > ScreenWidth()-self.p:Width()/2 then
        self.p:SetAnchor("BOTTOMRIGHT",ScreenWidth(),0)
    else
        self.p:SetAnchor("BOTTOM",x,0)
    end
end

------------------------------------------------
function TouchDown(self)
  --  DPrint("touchdown")
    local x,y = InputPosition()
    
    CreateTiles(bounding_list)
    
    local p1 = Region('region','red',UIParent)
    p1.t = p1:Texture(255,0,0,255)
    p1:SetWidth(30)
    p1:SetHeight(300)
    p1:SetAnchor("RIGHT",ScreenWidth(),ScreenHeight()/2)
    p1:EnableInput(true)
    p1:EnableMoving(true)
    --p1:Show()
    
    local p2 = Region('region','blue',UIParent)
    p2.t = p2:Texture(0,0,255,255)
    p2:SetWidth(30)
    p2:SetHeight(300)
    p2:SetAnchor("LEFT",0,ScreenHeight()/2)
    p2:EnableInput(true)
    p2:EnableMoving(true)
    --p2:Show()
        
    local p = Region('region','player',UIParent)
    p.t = p:Texture(200,0,150,255)
    p:SetWidth(300)
    p:SetHeight(30)
    p:SetAnchor("BOTTOM",ScreenWidth()/2,0)
    --p:EnableInput(true)
    p:EnableMoving(true)
    p:Show()
    table.insert(bounding_list,1,p)
    self.p = p
    
    local region = Region()
    region.t = region:Texture(255,255,255,255)
    region:SetWidth(size_ball)
    region:SetHeight(size_ball)
    region:SetAnchor("CENTER",x,y)
    region:EnableInput(true)
    region:Show()
    
    region.dx = math.tan(dir)
    region.dy = speed/region.dx 
    region.dx = speed*region.dx
--    x,y = region:Center()
    region.x=x
    region.y=y
    region.list = bounding_list -- {p1,p2}
    region.bound = bouncing_ball_boundary -- boundary 
    region.moving = 0
    region.backdrop = self
    
    -- region:Handle(signal,StartOrStopMoving)
    StartOrStopMoving(region)
    
    self:Handle("OnTouchDown",nil)
    self:Handle("OnMove",MovePlayer)
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