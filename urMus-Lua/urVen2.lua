-- urVen2.lua
-- by Aaven, Jul 2011
-- based on urVen.lua
-- p.s. menu becomes global

SetPage(18)
FreeAllRegions()
DPrint("Welcome to urVen2 =)")

---------------- constant -------------------
MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
HEIGHT_MENU_OPT = 30

STICK_MARGIN = 20
HEIGHT_LINE = 30

local regions = {}
local recycledregions = {}
local auto_stick_enabled = 0
local pics = {"vinyl.png","Ornament1.png","Pirate1.png","Play.png","Right.png"}

local moving_default_speed = "8" -- 3 to 10, slow to fast
local moving_default_dir = "45" -- degree
local boundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundaries {minx,maxx,miny,maxy}

local SixteenPositions = {} -- SixteenPositions(p1)(p2): ee:SetAnchor(p2,er,p1)
function InitializeUrStick()  
    local k = 1
    for i = 1,4 do
        SixteenPositions[i] = {}
    end
    SixteenPositions[1][4] = {"TOPLEFT","BOTTOMRIGHT"}
    SixteenPositions[2][4] = {"TOPLEFT","BOTTOMLEFT"}
    SixteenPositions[3][4] = {"TOPRIGHT","BOTTOMRIGHT"}
    SixteenPositions[4][4] = {"TOPRIGHT","BOTTOMLEFT"}
    SixteenPositions[1][3] = {"TOPLEFT","TOPRIGHT"}
    SixteenPositions[2][3] = {"TOPLEFT","TOPLEFT"}
    SixteenPositions[3][3] = {"TOPRIGHT","TOPRIGHT"}
    SixteenPositions[4][3] = {"TOPRIGHT","TOPLEFT"}
    SixteenPositions[1][2] = {"BOTTOMLEFT","BOTTOMRIGHT"}
    SixteenPositions[2][2] = {"BOTTOMLEFT","BOTTOMLEFT"}
    SixteenPositions[3][2] = {"BOTTOMRIGHT","BOTTOMRIGHT"}
    SixteenPositions[4][2] = {"BOTTOMRIGHT","BOTTOMLEFT"}
    SixteenPositions[1][1] = {"BOTTOMLEFT","TOPRIGHT"}
    SixteenPositions[2][1] = {"BOTTOMLEFT","TOPLEFT"}
    SixteenPositions[3][1] = {"BOTTOMRIGHT","TOPRIGHT"}
    SixteenPositions[4][1] = {"BOTTOMRIGHT","TOPLEFT"}
end
InitializeUrStick()

----------- global helper functions ------------

function VSetTexture(v)
    v.t:SetSolidColor(v.r,v.g,v.b,v.a)
    v.t:SetTexture(v.bkg)
end

function VVSetTexture(newv,oldv)
    newv.r = oldv.r
    newv.g = oldv.g
    newv.b = oldv.b
    newv.a = oldv.a
    newv.bkg = oldv.bkg
    newv.t:SetBlendMode(oldv.t:BlendMode())
    VSetTexture(newv)
end

function Unstick(v)
    output = ""
    local er = v.sticker
    local id = v.id
    local flag = 0
    if er ~= -1 then -- it is sticked to other
        output = output.."a: "..v.sticker:Name().." releases "..v:Name()..". "
        for k,ee in pairs(regions[er].stickee) do
            if ee == id then
                table.remove(regions[er].stickee,k)
            end
        end
        v.sticker = -1
        v:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
        v:EnableMoving(true)
        v:EnableInput(true)
        v:EnableResizing(true)
        v.group = id
        flag = 1
    end
    if (#v.stickee > 0) then
        output = output.."b: "..v:Name().." releases"
        flag = 1
        for k,ee in pairs(v.stickee) do -- other is sticked to it
            output = output.." R#"..ee
            regions[ee].sticker = -1
            regions[ee]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
            regions[ee]:EnableMoving(true)
            regions[ee]:EnableInput(true)
            regions[ee]:EnableResizing(true)
            regions[ee].group = regions[ee].id
        end
        while #v.stickee > 0 do
            table.remove(v.stickee)
        end
    end
    
    if flag == 0 then
        DPrint(v:Name().." nothing to unstick")
    else
        DPrint(output)
    end
end


function Highlight(r)
    r.t:SetTexture(100,100,100,255)
end

function UnHighlight(r)
    r.t:SetTexture(200,200,200,255)
end

------- backdrop ------
function TouchDown(self)
    CloseMenuBar()
    
    local region = CreateorRecycleregion('region', 'backdrop', UIParent)
    local x,y = InputPosition()
    region:Show()
    region:SetAnchor("CENTER",x,y)
    DPrint(region:Name().." created, centered at "..x..", "..y)
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

local backdrop = Region('region', 'backdrop', UIParent)
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
backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
backdrop:EnableClipping(true)

------------ notification component set --------------
function FadeNotification(self, elapsed)
    if self.staytime > 0 then
        self.staytime = self.staytime - elapsed
        return
    end
    if self.fadetime > 0 then
        self.fadetime = self.fadetime - elapsed
        self.alpha = self.alpha - self.alphaslope * elapsed
        self:SetAlpha(self.alpha)
    else
        self:Hide()
        self:Handle("OnUpdate", nil)
    end
end

function ShowNotification(note)
    notificationregion.textlabel:SetLabel(note)
    notificationregion.staytime = 1.5
    notificationregion.fadetime = 2.0
    notificationregion.alpha = 1
    notificationregion.alphaslope = 2
    notificationregion:Handle("OnUpdate", FadeNotification)
    notificationregion:SetAlpha(1.0)
    notificationregion:Show()
end

local notificationregion=Region('region', 'notificationregion', UIParent)
notificationregion:SetWidth(ScreenWidth())
notificationregion:SetHeight(48*2)
notificationregion:SetLayer("TOOLTIP")
notificationregion:SetAnchor('BOTTOMLEFT',0,ScreenHeight()/2-24) 
notificationregion:EnableClamping(true)
notificationregion:Show()
notificationregion.textlabel=notificationregion:TextLabel()
notificationregion.textlabel:SetFont("Trebuchet MS")
notificationregion.textlabel:SetHorizontalAlign("CENTER")
notificationregion.textlabel:SetLabel("")
notificationregion.textlabel:SetFontHeight(48)
notificationregion.textlabel:SetColor(255,255,255,190)

------------  color wheel -------------
color_w = 256
color_h = 256
color_x = 0
color_y = 0

function UpdateColor(self,x,y,dx,dy)
    local xx = (x+dx-color_x)*1530/color_w
    local yy = y+dy-color_y*255/color_h
    local r=0
    local g=0
    local b=0
    self.region.a=yy
    
    if xx < 255 then
        r = 255
        g = xx
        b = 0
    elseif xx < 510 then
        r = 510 - xx
        g = 255
        b = 0
    elseif xx < 765 then
        r = 0
        g = 255
        b = xx - 510
    elseif xx < 920 then
        r = 0 
        g = 920 - xx
        b = 255
    elseif xx < 1175 then
        r = xx - 920
        g = 0
        b = 255
    else
        r = 255
        g = 0
        b = 1530 - xx
    end
    
    self.region.r = r*self.region.a/255
    self.region.g = g*self.region.a/255
    self.region.b = b*self.region.a/255
    
    VSetTexture(self.region)
    DPrint("x"..xx.." y"..yy.." r"..self.region.r.." g"..self.region.g.." b"..self.region.b.." a"..self.region.a)
end

function CloseColorWheel(wheel)
    wheel:Hide()
    wheel:EnableInput(false)
end

local color_wheel = Region('region','colorwheel',UIParent)
color_wheel.t = color_wheel:Texture()
color_wheel.t:SetTexture('color_map.png')--255,255,255,255
color_wheel:SetWidth(color_w)
color_wheel:SetHeight(color_h)
color_wheel:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",color_x,color_y)
color_wheel:MoveToTop()
color_wheel:EnableInput(false)
color_wheel:EnableMoving(false)
color_wheel:EnableResizing(false)
color_wheel:Handle("OnMove",UpdateColor)
color_wheel:Handle("OnDoubleTap",CloseColorWheel)

------------ Menu Class -------------
Menu = {}
Menu.__index = Menu
function Menu:OpenMenu() 
    if self.open == 0 then
        for i = 1,self.num do
            self[i]:EnableInput(true)
            self[i]:MoveToTop()
            self[i]:Show()
        end
        self.open = 1
    end
end

function Menu:CloseMenu() 
    if self.open == 1 then
        for i = 1,self.num do
            self[i]:Hide()
            self[i]:EnableInput(false)
        end
        
        if self.openopt ~= -1 then
            if #self[self.openopt].menu > 0 then
                self[self.openopt].menu:CloseMenu()
            end
            
            self.openopt = -1
        end
        self.open = 0
    end
end

function Menu:MoveMenuToTop() 
    if self.open == 1 then
        for i = 1,self.num do
            self[i]:MoveToTop()
            if #self[i].menu > 0 then
                if self[i].menu.open == 1 then
                    self[i].menu:MoveMenuToTop()
                end
            end
        end
    end
end

function OpenOrCloseMenu(self)
    if self.menu.open == 0 then
        DPrint("open option")
        self.menu:OpenMenu()
    else 
        DPrint("close option")
        self.menu:CloseMenu()
    end
end

function OptEventFunc(self)
    -- close other opened option
    Highlight(self)
    if self.parent.openopt ~= self.k and self.parent.openopt ~= -1 and #self.parent[self.parent.openopt].menu > 0 then
        self.parent[self.parent.openopt].menu:CloseMenu()
    end
    self.parent.openopt = self.k
    self.func(self)
end

function Menu:CreateOption(pair)
    local opt = Region() 
    opt.parent = self
    opt.menu = {}
    opt.boss = self.caller.boss
    opt.tl = opt:TextLabel()
    opt.tl:SetLabel(pair[1])
    opt.tl:SetFontHeight(14)
    opt.tl:SetColor(0,0,0,255) 
    opt.tl:SetHorizontalAlign("JUSTIFY")
    opt.tl:SetShadowColor(255,255,255,255)
    opt.tl:SetShadowOffset(1,1)
    opt.tl:SetShadowBlur(1)
    opt:SetWidth(self.w)
    opt:SetHeight(self.h)
    opt.t = opt:Texture(200,200,200,255)
    opt.t:SetTexture(self.bkg) -- TODO how to fill rgb value
    opt.t:SetBlendMode("BLEND")
    opt.func = pair[2]
    
    if #pair[3] > 0 then
        opt.menu = Menu.Create(opt,"",pair[3],"TOPLEFT","TOPRIGHT")
        opt.func = OpenOrCloseMenu
    end
    opt:Handle("OnTouchDown",OptEventFunc)
    opt:Handle("OnTouchUp",UnHighlight)
    opt:Handle("OnLeave",UnHighlight)
    
    return opt
end

function Menu.Create(region,background,list,anchor,relanchor)
-- side:left or right or inside. offsets are for menu position
    
    local menu = {}
    setmetatable(menu,Menu)
    menu.w = MIN_WIDTH_MENU
    menu.h = HEIGHT_MENU_OPT
    menu.caller = region
    menu.bkg = background
    menu.open = 0
    menu.list = list
    menu.num = #list
    menu.openopt = -1
    
    local len = 0
    for i = 1,menu.num do
        if len < string.len(list[i][1]) then
            len = string.len(list[i][1])
        end
    end
    
    if len >= 20 then -- TODO too long name cant be displayed
        menu.w = MAX_WIDTH_MENU
    elseif len > 10 then
        menu.w = len*10
    end
    
    menu[1] = menu:CreateOption(list[1])
    menu[1].k = 1
    menu[1]:SetAnchor(anchor,menu.caller,relanchor)
    menu[1]:Hide()
    
    for i = 2,menu.num do
        menu[i] = menu:CreateOption(list[i])
        menu[i].k = i
        menu[i]:SetAnchor("BOTTOMLEFT",menu[i-1],"TOPLEFT")
        menu[i]:Hide()
    end
    
    return menu
end


------------- menu functions, call by menu option --------------
text_size_list = {"8","10","12","14","16","20","24","28","32","36"}
text_position_list = {"top left","top center","top right","middle left","middle center","middle right","bottom left","bottom center","bottom right"}
text_position_hor_list = {"LEFT","CENTER","RIGHT","LEFT","CENTER","RIGHT","LEFT","CENTER","RIGHT"}
text_position_ver_list = {"TOP","TOP","TOP","MIDDLE","MIDDLE","MIDDLE","BOTTOM","BOTTOM","BOTTOM"}
blend_mode_list = {"DISABLED", "BLEND", "ALPHAKEY", "ADD", "MOD", "SUB"}

function MenuAbout(self)
    local vv = self.boss.v
    output = vv:Name()..", sticker #"..vv.sticker..", stickees"
    if #vv.stickee == 0 then
        output = output.." #-1"
    else
        for k,ee in pairs (vv.stickee) do
            output = output.." #"..ee
        end
    end
    DPrint(output)
end

function MenuPictureRandomly(self)
    local vv = self.boss.v
    vv.bkg = pics[math.random(1,5)]
    vv.t:SetTexture(vv.bkg)
    DPrint(vv:Name().." background pic: "..vv.bkg)
end

function MenuColorRandomly(self)
    local vv = self.boss.v
    DPrint(vv:Name().." change color")
    vv.r = math.random(0,255)
    vv.g = math.random(0,255)
    vv.b = math.random(0,255)
    vv.a = math.random(0,255)
    vv.t:SetSolidColor(vv.r,vv.g,vv.b,vv.a)
end

function MenuClearToWhite(self)
    local vv = self.boss.v
    DPrint(vv:Name().." clear to white")
    vv.r = 255
    vv.g = 255
    vv.b = 255
    vv.a = 255
    vv.t:SetTexture(255,255,255,255)
end

function MenuUnstick(self)
    Unstick(self.boss.v)
    UnHighlight(self)
    CloseMenuBar()
end

function MenuRecycleSelf(self) -- remove v
    Unstick(self.boss.v)
    
    local vv = self.boss.v
    PlainVRegion(vv)
    vv:EnableInput(false)
    vv:EnableMoving(false)
    vv:EnableResizing(false)
    vv:Hide()
    vv.usable = 0

    table.insert(recycledregions, vv.id)
    DPrint(vv:Name().." removed")
    
    UnHighlight(self)
    CloseMenuBar()
end

function MenuStickControl(self)
    if auto_stick_enabled == 1 then
        DPrint("AutoStick disabled")
        auto_stick_enabled = 0
    else
        DPrint("AutoStick enabled")
        auto_stick_enabled = 1
    end
end

function MenuDuplicate(self)
    local newv = CreateorRecycleregion('region', 'backdrop', UIParent)
    local oldv = self.boss.v
    -- size
    newv:SetWidth(oldv:Width())
    newv:SetHeight(oldv:Height())
    -- color
    VVSetTexture(newv,oldv)
    -- text 
    newv.tl:SetFontHeight(oldv.tl:FontHeight())
    newv.tl:SetHorizontalAlign(oldv.tl:HorizontalAlign())
    newv.tl:SetVerticalAlign(oldv.tl:VerticalAlign())
    newv.tl:SetLabel(newv.tl:Label())
    -- position
    local x,y = oldv:Center()
    local h = 10 + oldv:Height()
    newv:Show()
    newv:SetAnchor("CENTER",x,y-h)
    DPrint(newv.tl:Label().." Color: ("..newv.r..", "..newv.g..", "..newv.b..", "..newv.a.."). Background pic: "..newv.bkg..". Blend mode: "..newv.t:BlendMode())
    --UnHighlight(self)
    --CloseMenuBar()
end

function MenuTextSize(self)
    DPrint("change font: "..text_size_list[self.k])
    local size = tonumber(text_size_list[self.k]) * 5/3
    local vv = self.boss.v
    vv.tl:SetFontHeight(size)
    vv.tl:SetLabel(vv.tl:Label())
end

function MenuTextPosition(self)
    local vv = self.boss.v
    vv.tl:SetHorizontalAlign(text_position_hor_list[self.k])
    vv.tl:SetVerticalAlign(text_position_ver_list[self.k])
    vv.tl:SetLabel(vv.tl:Label())
end

function MenuText(self)
    DPrint("Current text size: " .. self.boss.v.tl:FontHeight() .. ", position: " .. self.boss.v.tl:VerticalAlign() .. " & " .. self.boss.v.tl:HorizontalAlign())
end

function MenuChangeColor(self)
    color_wheel:Show()
    color_wheel.region = self.boss.v
    color_wheel:EnableInput(true)
    UnHighlight(self)
    CloseMenuBar()
end

function MenuTransparency(self)
    DPrint("Current blend mode: " .. self.boss.v.t:BlendMode())
end

function MenuBlendMode(self)
    DPrint("Change to blend mode: " .. blend_mode_list[self.k])
    self.boss.v.t:SetBlendMode(blend_mode_list[self.k])
end

function MenuMoving(self)
    OpenMyDialog(self.boss.v)
    UnHighlight(self)
    CloseMenuBar()
end
          
------------------- user customized data/functions ------------------
function_list = {}

function_list[1] = {"Try me", {
                                {"about",MenuAbout,{}},
                                {"rand pic",MenuPictureRandomly,{}},
                                {"rand color",MenuColorRandomly,{}},
                                {"clear bkg",MenuClearToWhite,{}},
                                {"transparency control",MenuTransparency,{
                                                            {blend_mode_list[1],MenuBlendMode,{}},
                                                            {blend_mode_list[2],MenuBlendMode,{}},
                                                            {blend_mode_list[3],MenuBlendMode,{}},
                                                            {blend_mode_list[4],MenuBlendMode,{}},
                                                            {blend_mode_list[5],MenuBlendMode,{}},
                                                            {blend_mode_list[6],MenuBlendMode,{}}
                                                        }},
                                {"unstick",MenuUnstick,{}},
                                {"remove v",MenuRecycleSelf,{}},
                                {"autostick control",MenuStickControl,{}}
                            }
                    }
                    
function_list[2] = {"Edit", {
                                {"color wheel",MenuChangeColor,{}},
                                {"duplicate",MenuDuplicate,{}},
                                {"text position",MenuText,{
                                                            {text_position_list[1],MenuTextPosition,{}},
                                                            {text_position_list[2],MenuTextPosition,{}},
                                                            {text_position_list[3],MenuTextPosition,{}},
                                                            {text_position_list[4],MenuTextPosition,{}},
                                                            {text_position_list[5],MenuTextPosition,{}},
                                                            {text_position_list[6],MenuTextPosition,{}},
                                                            {text_position_list[7],MenuTextPosition,{}},
                                                            {text_position_list[8],MenuTextPosition,{}},
                                                            {text_position_list[9],MenuTextPosition,{}}
                                                        }},
                                {"text font",MenuText,{
                                                            {text_size_list[1],MenuTextSize,{}},
                                                            {text_size_list[2],MenuTextSize,{}},
                                                            {text_size_list[3],MenuTextSize,{}},
                                                            {text_size_list[4],MenuTextSize,{}},
                                                            {text_size_list[5],MenuTextSize,{}},
                                                            {text_size_list[6],MenuTextSize,{}},
                                                            {text_size_list[7],MenuTextSize,{}},
                                                            {text_size_list[8],MenuTextSize,{}},
                                                            {text_size_list[9],MenuTextSize,{}},
                                                            {text_size_list[10],MenuTextSize,{}}
                                                        }},
                                                            
                            }
                    }
                            
function_list[3] = {"Take Action!", {
                                {"move",MenuMoving,{}}
                            }
                    }
                    
------------ menu bar events ------------
function OpenOrCloseMenubarItem(self) -- call by menubar(i) 
    local bar = self.boss
    if self.menu.open == 0 then
        if bar.openmenu ~= -1 then
            bar[bar.openmenu].menu:CloseMenu()
        end
        DPrint("open menu item")
        bar.openmenu = self.k
        self.menu:OpenMenu()
    else 
        DPrint("close menu item")
        bar.openmenu = -1
        self.menu:CloseMenu()
    end
end

------------ global menu -------------
local menubar = {}
menubar.menus = function_list
menubar.v = nil -- caller v
menubar.openmenu = -1
menubar.show = 0

for k,name in pairs (menubar.menus) do
    local r = Region('region','menu',UIParent)
    r.tl = r:TextLabel()
    r.tl:SetLabel(menubar.menus[k][1])
    r.tl:SetFontHeight(16)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r.t = r:Texture(250,250,250,255)
    r.k = k
    r.boss = menubar
    r.menu = Menu.Create(r,"",menubar.menus[k][2],"BOTTOMLEFT","TOPLEFT")
    r:SetWidth(ScreenWidth()/#menubar.menus)
    r:SetHeight(HEIGHT_LINE)
    r:EnableInput(false)
    r:EnableMoving(false)
    r:EnableResizing(false)
    r:Handle("OnTouchDown",OpenOrCloseMenubarItem)
    menubar[k] = r
end

menubar[1]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT")
for i=2,#menubar do
    menubar[i]:SetAnchor("LEFT",menubar[i-1],"RIGHT")
    menubar[i]:Hide()
end
menubar[1]:Hide()

----------- keyboard ------------
local key_margin = 5
local key_w = (ScreenWidth() - key_margin * 11) / 10
local key_h = key_w * 0.9

Keyboard = {}
Keyboard.__index = Keyboard

function KeyTouchDown(self)
    DPrint(self.faces[self.parent.face])
    self.parent.typingarea.tl:SetLabel(self.parent.typingarea.tl:Label()..self.faces[self.parent.face])
    Highlight(self)
    for i = 1,4 do
        for j = 1,#self.parent[i] do
            self.parent[i][j]:MoveToTop()
        end
    end
end

function KeyTouchUp(self)
    UnHighlight(self)
end

function Keyboard:CreateKey(ch1,ch2,ch3,w)
    local key = Region('region', 'key', UIParent)
    key.parent = self
    key.faces = {ch1,ch2,ch3} -- 1: low case, 2: upper case, 3: back number
    key.t = key:Texture(200,200,200,255)
    key.tl = key:TextLabel()
    key.tl:SetLabel(ch1)
    key.tl:SetFontHeight(20)
    key.tl:SetColor(0,0,0,255) 
    key.tl:SetHorizontalAlign("JUSTIFY")
    key.tl:SetShadowColor(255,255,255,255)
    key.tl:SetShadowOffset(1,1)
    key.tl:SetShadowBlur(1)
    key:SetHeight(key_h)
    key:SetWidth(w)
    key:Handle("OnTouchDown",KeyTouchDown)
    key:Handle("OnTouchUp",KeyTouchUp)
    key:Handle("OnLeave",KeyTouchUp)
    return key
end

function Keyboard:CreateKBLine(str1,str2,str3,line,w) -- as a private function, do not use outside class, only called by Keyboard.Create
    self[line] = {}
    self[line].num = string.len(str1)
    self[line][1] = self:CreateKey(string.char(str1:byte(1)),string.char(str2:byte(1)),string.char(str3:byte(1)),w)
    
    for i=2,self[line].num do
        self[line][i] = self:CreateKey(string.char(str1:byte(i)),string.char(str2:byte(i)),string.char(str3:byte(i)),w)
        self[line][i]:SetAnchor("TOPLEFT",self[line][i-1],"TOPRIGHT",key_margin,0)
    end
end

function Keyboard:UpdateFaces(face)
    self.face = face
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j].tl:SetLabel(self[i][j].faces[face])
        end
    end
    UnHighlight(self[3][10])
end

function KeyTouchDownShift(self)
    if self.parent.face == 1 then
        DPrint("1")
        self.parent:UpdateFaces(2)
        Highlight(self)
    elseif self.parent.face == 2 then
        DPrint("2")
        self.parent:UpdateFaces(1)
        UnHighlight(self)
    end
end

function KeyTouchDownFlip(self)
    Highlight(self)
    if self.parent.face == 3 then
        self.parent:UpdateFaces(1)
    else
        self.parent:UpdateFaces(3)
    end
end

function KeyTouchDownBack(self)
    Highlight(self)
    local s = self.parent.typingarea.tl:Label()
    if s ~= "" then
        DPrint(s)
        self.parent.typingarea.tl:SetLabel(s:sub(1,s:len()-1))
    end
end

function KeyTouchDownClear(self)
    Highlight(self)
    self.parent.typingarea.tl:SetLabel("")
end

function Keyboard.Create(area)
    local kb = {}
    setmetatable(kb, Keyboard)
    kb.open = 0
    kb.typingarea = area
    kb.w = ScreenWidth()
    kb.face = 1 -- 1: low case, 2: upper case, 3: back number
    kb:CreateKBLine("qwertyuiop","QWERTYUIOP","1234567890",1,key_w)
    kb:CreateKBLine("asdfghjkl","ASDFGHJKL","-/:;()$&@",2,key_w)
    kb:CreateKBLine("zxcvbnm,.","ZXCVBNM!?","_\\|~<>+='",3,key_w)
    -- kb(3) has SHIFT key
    kb[3][10] = kb:CreateKey("shift","shift","disable",key_w)
    kb[3][10]:SetAnchor("TOPLEFT",kb[3][9],"TOPRIGHT",key_margin,0)
    kb[3][10]:Handle("OnTouchDown",KeyTouchDownShift)
    kb[3][10]:Handle("OnTouchUp",nil)
    kb[3][10]:Handle("OnLeave",nil)
    kb[3].num = kb[3].num + 1
    kb[4] = {}
    kb[4].num = 3
    kb[4][1] = kb:CreateKey("123","123","abc",key_w*2)
    kb[4][2] = kb:CreateKey(" "," "," ",key_w*5.5)
    kb[4][3] = kb:CreateKey("<=","<=","<=",key_w*2.2)
    kb[4][4] = kb:CreateKey("clear","clear","clear",key_w*0.7)
    kb[4][2]:SetAnchor("TOPLEFT",kb[4][1],"TOPRIGHT",key_margin,0)
    kb[4][3]:SetAnchor("TOPLEFT",kb[4][2],"TOPRIGHT",key_margin,0)
    kb[4][4]:SetAnchor("TOPLEFT",kb[4][3],"TOPRIGHT",key_margin,0)
    kb[4][1]:Handle("OnTouchDown",KeyTouchDownFlip)
    kb[4][3]:Handle("OnTouchDown",KeyTouchDownBack)
    kb[4][4]:Handle("OnTouchDown",KeyTouchDownClear)
    
    kb[4][1]:SetAnchor("BOTTOMLEFT",key_margin,key_margin)
    kb[3][1]:SetAnchor("BOTTOMLEFT",kb[4][1],"TOPLEFT",0,key_margin)
    kb[2][1]:SetAnchor("BOTTOMLEFT",kb[3][1],"TOPLEFT",key_w/2,key_margin)
    kb[1][1]:SetAnchor("BOTTOMLEFT",kb[2][1],"TOPLEFT",0-key_w/2,key_margin)
    
    kb.h = #kb * (key_h+key_margin)
    
    return kb
end

function Keyboard:Show(face)
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j]:EnableInput(true)
            self[i][j]:Show()
            self[i][j]:MoveToTop()
            self[i][j].tl:SetLabel(self[i][j].faces[face])
        end
    end
    UnHighlight(self[3][10])
    self.face = face
    self.open = 1
end

function Keyboard:Hide()
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j]:EnableInput(false)
            self.face = 1
            self[i][j].tl:SetLabel(self[i][j].faces[1])
            self[i][j]:Hide()
        end
    end
    self.open = 0
end

local mykb = Keyboard.Create()

function OpenOrCloseKeyboard(self)
    if mykb.open == 0 then 
        -- self.tl:SetLabel("")
        -- self.tl:SetHorizontalAlign("LEFT")
        mykb.typingarea = self
        CloseColorWheel(color_wheel)
        DPrint("to open")
        mykb:Show(1)
        backdrop:SetClipRegion(0,mykb.h,ScreenWidth(),ScreenHeight())
    else 
        DPrint("to close")
        mykb:Hide()
        backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
    end
end

function OpenOrCloseNumericKeyboard(self)
    if mykb.open == 0 then 
        mykb.typingarea = self
        CloseColorWheel(color_wheel)
        DPrint("to open")
        mykb:Show(3)
        backdrop:SetClipRegion(0,mykb.h,ScreenWidth(),ScreenHeight())
    else 
        DPrint("to close")
        mykb:Hide()
        backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
    end
end

---------------------- moving --------------------------
function TouchObject(r,other)
    local bb = r:Bottom() + r.dy
    local tt = r:Top() + r.dy
    local ll = r:Left() + r.dx
    local rr = r:Right() + r.dx
    local b2 = other:Bottom()
    local t2 = other:Top()
    local l2 = other:Left()
    local r2 = other:Right()

    if (l2 < ll and ll < r2 or l2 < rr and rr < r2) and (b2 < tt and tt < t2 or b2 < bb and bb < t2) then
        -- two regions is about to overlap
        if bb <= t2 and tt >= t2 and r:Bottom() >= t2 then
            DPrint("bottom")
            r.y = r.y + t2 - bb + r.dy
            r.dy = math.abs(r.dy)
            r.touch = "bottom"
        elseif ll <= r2 and rr >= r2 and r:Left() >= r2 then
            DPrint("left")
            r.x = r.x + r2 - ll + r.dx
            r.dx = math.abs(r.dx)
            r.touch = "left"
        elseif tt >= b2 and bb <= b2 and r:Top() <= b2 then
            DPrint("top")
            r.y = r.y + b2 - tt + r.dy
            r.dy = -math.abs(r.dy)
            r.touch = "top"
        elseif rr >= l2 and ll <= l2 and r:Right() <= l2 then
            DPrint("right")
            r.x = r.x + l2- rr + r.dx
            r.dx = -math.abs(r.dx)
            r.touch = "right"
        end
    end
end

function TouchBound(r)
    if r:Bottom() + r.dy <= r.bound[1] then
        DPrint("bottom")
        r.y = r.y + r.bound[1] - r:Bottom()
        r.dy = math.abs(r.dy)
        r.touch = "bottom"
    elseif r:Left() + r.dx <= r.bound[3] then
        DPrint("left")
        r.x = r.x + r.bound[3] - r:Left()
        r.dx = math.abs(r.dx)
        r.touch = "left"
    elseif r:Top() + r.dy >= r.bound[2] then
        DPrint("top")
        r.y = r.y + r.bound[2] - r:Top()
        r.dy = -math.abs(r.dy)
        r.touch = "top"
    elseif r:Right() + r.dx >= r.bound[4] then
        DPrint("right")
        r.x = r.x + r.bound[4] - r:Right()
        r.dx = -math.abs(r.dx)
        r.touch = "right"
    end
end

function StartMovingEvent(r,e)
    if r.touch ~= "none" then
        r.x = r.x + r.dx
        r.y = r.y + r.dy
        r.touch = "none"
    else
        for k,i in pairs (r.movelist) do
            TouchObject(r,regions[i])
            if r.touch ~= "none" then
                break
            end
        end
    
        if r.touch == "none" then
            TouchBound(r)
            if r.touch == "none" then
                r.x = r.x + r.dx
                r.y = r.y + r.dy
            end
        end
    end
    
    r:SetAnchor("CENTER",r.x,r.y)
end

function StartMoving(self)
    self:Handle("OnUpdate",nil)
    self.x,self.y = self:Center()
    self.moving = 1
    self.touch = "none"
    self:Handle("OnUpdate",StartMovingEvent)
end

function OKclicked(self)
    local dd = self.parent
    d1 = tonumber(dd[1][2].tl:Label())
    d2 = tonumber(dd[2][2].tl:Label())
    if d1 <= 0 or d1 >= 13 then
        DPrint("Speed must be in the range (0,13]")
        return
    end
    if d2 >= 360 or d2 < 0 then
        DPrint("Direction must be in the range [0,360)")
        return
    end

    local region = dd.caller
    local deg = d2 * math.pi / 180
    region.dy = d1*math.sin(deg)
    region.dx = d1*math.cos(deg)
    region.movelist = dd.obj
    region.bound = boundary 

    CloseMyDialog()
    StartMoving(region)
end

function CANCELclicked(self)
    local dd = self.parent
    CloseMyDialog()
end

local mydialog = {}
mydialog.title = Region('region','dialog',UIParent)
mydialog.title.t = mydialog.title:Texture(240,240,240,255)
mydialog.title.tl = mydialog.title:TextLabel()
mydialog.title.tl:SetLabel("Move! Touch the region to stop moving.")
mydialog.title.tl:SetFontHeight(16)
mydialog.title.tl:SetColor(0,0,0,255) 
mydialog.title.tl:SetHorizontalAlign("JUSTIFY")
mydialog.title.tl:SetShadowColor(255,255,255,255)
mydialog.title.tl:SetShadowOffset(1,1)
mydialog.title.tl:SetShadowBlur(1)
mydialog.title:SetWidth(400)
mydialog.title:SetHeight(50)
mydialog.title:SetAnchor("CENTER",UIParent,"CENTER")
mydialog.hint = {{"speed (1 to 13, slow to fast)",moving_default_speed},{"direction (degrees)",moving_default_dir},{"select objects to bounce from",""},{"OK","CANCEL"}}
mydialog.obj = {}
mydialog.ready = 0
for i = 1,#mydialog.hint do
    mydialog[i] = {}
    mydialog[i][1] = Region('region','dialog',UIParent)
    mydialog[i][1].tl = mydialog[i][1]:TextLabel()
    mydialog[i][1].tl:SetLabel(mydialog.hint[i][1])
    mydialog[i][1].tl:SetFontHeight(16)
    mydialog[i][1].tl:SetColor(0,0,0,255) 
    mydialog[i][1].tl:SetHorizontalAlign("JUSTIFY")
    mydialog[i][1].tl:SetShadowColor(255,255,255,255)
    mydialog[i][1].tl:SetShadowOffset(1,1)
    mydialog[i][1].tl:SetShadowBlur(1)
    mydialog[i][1].t = mydialog[i][1]:Texture(200,200,200,255)
    mydialog[i][1]:SetWidth(250)
    mydialog[i][1]:SetHeight(50)
    mydialog[i][1]:EnableInput(false)
    mydialog[i][1]:EnableMoving(false)
    mydialog[i][1]:EnableResizing(false)
    
    mydialog[i][2] = Region('region','dialog',UIParent)
    mydialog[i][2].tl = mydialog[i][2]:TextLabel()
    mydialog[i][2].tl:SetLabel(mydialog.hint[i][2])
    mydialog[i][2].tl:SetFontHeight(16)
    mydialog[i][2].tl:SetColor(0,0,0,255) 
    mydialog[i][2].tl:SetHorizontalAlign("JUSTIFY")
    mydialog[i][2].tl:SetShadowColor(255,255,255,255)
    mydialog[i][2].tl:SetShadowOffset(1,1)
    mydialog[i][2].tl:SetShadowBlur(1)
    mydialog[i][2].t = mydialog[i][2]:Texture(200,200,200,255)
    mydialog[i][2]:SetWidth(150)
    mydialog[i][2]:SetHeight(50)
    mydialog[i][2]:EnableMoving(false)
    mydialog[i][2]:EnableResizing(false)
    mydialog[i][2]:Handle("OnTouchDown",OpenOrCloseNumericKeyboard)
    
    mydialog[i][2]:SetAnchor("LEFT",mydialog[i][1],"RIGHT")
end
i = #mydialog.hint
mydialog[i][1]:EnableInput(true)
mydialog[i][1]:Handle("OnTouchDown",OKclicked)
mydialog[i][2]:Handle("OnTouchDown",CANCELclicked)
mydialog[i][1].parent = mydialog
mydialog[i][2].parent = mydialog
mydialog[3][2]:Handle("OnTouchDown",nil)

mydialog[1][1]:SetAnchor("TOPLEFT",mydialog.title,"BOTTOMLEFT")

for i = 2,#mydialog.hint do
    mydialog[i][1]:SetAnchor("TOPLEFT",mydialog[i-1][1],"BOTTOMLEFT")
end

function OpenMyDialog(v)
    mydialog.title:Show()
    mydialog.title:MoveToTop()
    mydialog.caller = v
    DPrint(v.id)
    while #mydialog.obj > 0 do
        table.remove(mydialog.obj)
    end
    while #v.movelist > 0 do
        table.remove(v.movelist)
    end
    mydialog[1][2].tl:SetLabel("8")
    mydialog[2][2].tl:SetLabel("45")
    mydialog[3][2].tl:SetLabel("")
    for i = 1,#mydialog.hint do
        mydialog[i][1]:Show()
        mydialog[i][2]:Show()
        mydialog[i][1]:MoveToTop()
        mydialog[i][2]:MoveToTop()
        mydialog[i][2]:EnableInput(true)
    end
    mydialog[#mydialog.hint][1]:EnableInput(true)
    mydialog.ready = 1
    backdrop:EnableInput(false)
end

function CloseMyDialog()
    mydialog.title:Hide()
    for i = 1,#mydialog.hint do
        mydialog[i][1]:Hide()
        mydialog[i][2]:Hide()
        mydialog[i][2]:EnableInput(false)
    end
    
    mydialog[#mydialog.hint][1]:EnableInput(false)
    mykb:Hide()
    mydialog.ready = 0
    backdrop:EnableInput(true)
end

function BeBouncedObject(self)
    found = 0
    if mydialog.ready == 1 then
        for k,i in pairs(mydialog.obj) do
            if i == self.id then
                found = 1
                break
            end
        end
        if found == 0 then
            table.insert(mydialog.obj,self.id)
            mydialog[3][2].tl:SetLabel(mydialog[3][2].tl:Label()..self:Name().." ")
        end
    end
end


------------- trashbin -------------
local trashbin = Region('region','trashbin',UIParent)
trashbin.t = trashbin:Texture("trashbin.png")
trashbin:SetWidth(100)
trashbin:SetHeight(100)
trashbin:SetAnchor("TOP",UIParent,"TOP")
trashbin.yes = 0

function OverlapTrashbin(self)
    if self:RegionOverlap(trashbin) then
        DPrint("Do you want to remove "..self:Name().."?")
        self.t:SetTexture(255,0,0,250)
        trashbin.yes = 1
    else
        DPrint("you can move to the trashbin to remove the object")
        VSetTexture(self)
        trashbin.yes = 0
    end
end

function MoveToTrashbin(v)
    Unstick(v)
    
    PlainVRegion(v)
    v:EnableInput(false)
    v:EnableMoving(false)
    v:EnableResizing(false)
    v:Hide()
    v.usable = 0

    table.insert(recycledregions, v.id)
    DPrint(v:Name().." removed")
    CloseMenuBar()
end

function HoldToTrigger(self, elapsed)
    x,y = self:Center()
    
    if self.holdtime <= 0 then
        self.x = x 
        self.y = y
        DPrint("Menu Opened")
        OpenMenuBar(self)
        trashbin:Show()
        self:Handle("OnUpdate",OverlapTrashbin)
    else 
        if math.abs(self.x - x) > 10 or math.abs(self.y - y) > 10 then
            self:Handle("OnUpdate",nil)
        end
        self.holdtime = self.holdtime - elapsed
    end
end

function HoldTrigger(self)
    self.holdtime = 0.5
    self.x,self.y = self:Center()
    self:Handle("OnUpdate",HoldToTrigger)
end

function DeTrigger(self)
    self:Handle("OnUpdate",nil)
    if trashbin.yes == 1 then
        MoveToTrashbin(self)
        trashbin.yes = 0
    end
    trashbin:Hide()
end

-------------- anchor --------------
function LockOrUnlock(self)
    if anchorv.caller.fixed == 1 then
        DPrint("unlock")
        anchorv:Texture("unlock.png")
        anchorv.caller.fixed = 0
        anchorv.caller:EnableMoving(true)
        anchorv.caller:EnableResizing(true)
    else
        DPrint("lock")
        anchorv:Texture("lock.png")
        anchorv.caller.fixed = 1
        anchorv.caller:EnableMoving(false)
        anchorv.caller:EnableResizing(false)
    end
end

anchorv = Region('region','anchor',UIParent)
anchorv:EnableInput(true)
anchorv:Handle("OnTouchDown",LockOrUnlock)
anchorv:SetWidth(30)
anchorv:SetHeight(30)


----------- basic v events --------------
function CloseMenubarHelper()
    if menubar.show == 1 then
        for i = 1,#menubar do
            menubar[i]:Hide()
            menubar[i]:EnableInput(false)
        end
        menubar.show = 0
        backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
    end
end

function CloseMenuBar(self)
    if menubar.openmenu ~= -1 then
        menubar[menubar.openmenu].menu:CloseMenu()
        menubar.openmenu = -1 
    end
    CloseMenubarHelper()
    menubar.v = nil
end

function OpenMenuBar(self)
    if menubar.show == 0 then
        for i = 1,#menubar do
            menubar[i]:Show()
            menubar[i]:EnableInput(true)
            menubar[i]:MoveToTop()
        end
        menubar.v = self
        menubar.show = 1
        CloseColorWheel(color_wheel)
        mykb:Hide()
        backdrop:SetClipRegion(0,HEIGHT_MENU_OPT,ScreenWidth(),ScreenHeight())
    end
end

function SelectObj(self)
    DPrint(self:Name().." selected")
    self:MoveToTop()
end

function StickToClosestAnchorPoint(ee,er)
    local hw = er:Width()/2
    local hh = er:Height()/2
    local eex,eey = ee:Center()
    local erx = er:Left()
    local ery = er:Bottom()
    local dx = math.ceil((eex - erx)/hw) + 1
    local dy = math.ceil((eey - ery)/hh) + 1
    if dx > 4 then dx = 4 end
    if dx < 1 then dx = 1 end
    if dy > 4 then dy = 4 end
    if dy < 1 then dy = 1 end

    ee:SetAnchor(SixteenPositions[dx][dy][2],er,SixteenPositions[dx][dy][1])
    table.insert(er.stickee,ee.id)
    ee.sticker = er.id
    ee:EnableMoving(false)

    output = SixteenPositions[dx][dy][1].."+"..SixteenPositions[dx][dy][2].." new stickee "..ee:Name().."! sticker "..er:Name().." now has stickees: "
    for k,i in pairs(er.stickee) do
        output = output.." R#"..i
    end
    DPrint(output)
end

function AutoCheckStick(self)
  --  DPrint("in AutoCheckStick")
    if auto_stick_enabled == 1 then
        local large = Region()
        local x = self:Left() - STICK_MARGIN
        local y = self:Top() + STICK_MARGIN
        large:SetWidth(self:Width() + STICK_MARGIN * 2)
        large:SetHeight(self:Height() + STICK_MARGIN * 2)
        large:SetAnchor("TOPLEFT",x,y)
        
        for k,v in pairs (regions) do -- v is sticker, self is stickee
            if v ~= self and v.usable == 1 then
                DPrint("there are other regions")
                if v.sticker ~= self.id and self.sticker ~= v.id and v.group ~= self.group then
                    DPrint("there are other regions to stick to")
                    if v:RegionOverlap(large) then
                        DPrint("they overlap")
                        if not v:RegionOverlap(self) then
                            if self.sticker == -1 then
                                StickToClosestAnchorPoint(self,v)
                                self.group = v.group
                            end
                        end
                    end
                end
            end
        end
    end
end

function CloseSharedStuff(self)
    -- close keyboard
    if self ~= mykb.typingarea then
        mykb:Hide()
    end
    
    -- close color wheel
    color_wheel:Hide()
    color_wheel:EnableInput(false)
    
    -- close menubar
    CloseMenuBar()
end


function AddAnchorIcon(self)
    if self.fixed == 1 then
        anchorv:Texture("lock.png")
    else
        anchorv:Texture("unlock.png")
    end
    anchorv:SetAnchor("TOPLEFT",self,"TOPLEFT")
    anchorv:MoveToTop()
    anchorv:Show()
    anchorv.caller = self
end

----------- background region events -----------
------------ v event -------------

function VDoubleTap(self)
    --ChangeColor(self)
    for i = 1,#self.eventlist["OnDoubleTap"] do
        self.eventlist["OnDoubleTap"][i](self)
    end
end

function VTouchUp(self)
    for i = 1,#self.eventlist["OnTouchUp"] do
        self.eventlist["OnTouchUp"][i](self)
    end
end

function VTouchDown(self)
    if mydialog.ready == 1 then
        BeBouncedObject(self)
    else
        for i = 1,#self.eventlist["OnTouchDown"] do
            self.eventlist["OnTouchDown"][i](self)
        end
    end
end

function PlainVRegion(r)
    -- initialize for events and signals
    r.eventlist = {}
    r.eventlist["OnTouchDown"] = {HoldTrigger,CloseSharedStuff,SelectObj,AddAnchorIcon}
    r.eventlist["OnTouchUp"] = {AutoCheckStick,DeTrigger} 
    r.eventlist["OnDoubleTap"] = {OpenOrCloseKeyboard} -- ChangeColor
    r.eventlist["OnUpdate"] = {} -- TODO: not needed??
    r.eventlist["OnMove"] = {}
    r.eventlist["OnShow"] = {}
    r.eventlist["OnHide"] = {}
    r.eventlist["OnLongTap"] = {}
    r.signallist = {} -- customized signal
    
    -- initialize for stick
    r.group = r.id
    r.sticker = -1
    r.stickee = {}
    
    -- initialize for moving
    r.moving = 0
    r.dx = 0
    r.dy = 0
    r.movelist = {}
    r.bound = boundary
    
    -- initialize texture, label and size
    r.r = 255
    r.g = 255
    r.b = 255
    r.a = 255
    r.bkg = ""
    r.t:SetTexture(r.r,r.g,r.b,r.a)
    r.tl:SetLabel(r:Name())
    r.tl:SetFontHeight(16)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetVerticalAlign("MIDDLE")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r:SetWidth(200)
    r:SetHeight(200)
    
    -- anchor
    r.fixed = 0
    AddAnchorIcon(r)
end

function VRegion(ttype,name,parent,id)
    local r = Region(ttype,"R#"..id,parent)
    r.tl = r:TextLabel()
    r.t = r:Texture()
    
    -- initialize for regions{} and recycledregions{}
    r.usable = 1
    r.id = id
    PlainVRegion(r)
    
    r:EnableMoving(true)
    r:EnableResizing(true)
    r:EnableInput(true)
    
    r:Handle("OnDoubleTap",VDoubleTap)
    r:Handle("OnTouchDown",VTouchDown)
    r:Handle("OnTouchUp",VTouchUp)
    
    return r
end

function CreateorRecycleregion(ftype, name, parent)
    local region
    if #recycledregions > 0 then
        region = regions[recycledregions[#recycledregions]]
        table.remove(recycledregions)
        region:EnableMoving(true)
        region:EnableResizing(true)
        region:EnableInput(true)
        region.usable = 1
    else
        region = VRegion(ftype, name, parent, #regions+1)
        table.insert(regions,region)
    end
    return region
end

------------------------------------------------------------------
local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4)
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()